<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - Mihomo</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/popup.js"></script>

<script>
<% login_state_hook(); %>
<% mihomo_running(); %>

var $j = jQuery.noConflict();

function initial(){
	show_banner(1);
	show_menu(5, 8, 5);
	show_footer();

	init_itoggle('mh_enable');
	init_itoggle('mh_autostart');
	init_itoggle('mh_fakeip');
	init_itoggle('mh_slim');
	slim_text_init();

	if (!login_safe())
		E('btn_apply').disabled = true;

	if (!mihomo_running())
		E('mh_state_hint').innerHTML = '（当前没有进程在跑）';
}

function trim_str(s){
	return s.replace(/^\s+|\s+$/g, '');
}

function radio_value(name){
	var els = document.getElementsByName(name);
	for (var i = 0; i < els.length; i++)
		if (els[i].checked)
			return els[i].value;
	return '0';
}

/* ================= 表单提交 ================= */

function validForm(){
	if (!login_safe()){
		alert('当前不是局域网/HTTPS 安全会话，不允许修改 Mihomo');
		return false;
	}
	if (radio_value('mh_enable') == '1'){
		if (trim_str(document.form.mh_sub_url.value) == ''){
			alert('已勾选“启用”，但订阅地址为空。\n没有配置 mihomo 起不来。');
			document.form.mh_sub_url.focus();
			return false;
		}
		var u = trim_str(document.form.mh_sub_url.value);
		if (u.indexOf('://') < 0){
			alert('订阅地址看起来不完整，需要带协议头，例如：\nhttps://example.com/link/xxxx?clash=3');
			document.form.mh_sub_url.focus();
			return false;
		}
	}
	return true;
}

/* mode: 'apply' 只保存并重启(用已有配置, 不联网)
         'update' 保存后重新拉订阅(联网, 慢, 会重建配置) */
function submit_form(mode){
	if (!validForm())
		return;

	if (mode == 'update'){
		if (!confirm('将重新下载订阅并重建配置。\n下载期间代理会短暂中断, 订阅较大时可能需要 10-30 秒。继续吗?'))
			return;
	}

	showLoading();

	document.form.mh_action.value = mode;
	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "Advanced_Mihomo_Content.asp";
	document.form.next_page.value = "";
	document.form.submit();
}

function applyRule(){
	submit_form('apply');
}

/* 保存后处理脚本: 先落盘, 有变动时后台会顺带重拉一次订阅 */
function save_sed(){
	if (!login_safe()){
		alert('当前不是局域网/HTTPS 安全会话，不允许修改 Mihomo');
		return;
	}
	var t = document.form.mh_sed_text;
	if (t.value.length > 8192){
		alert('脚本太长（' + t.value.length + ' 字节），上限 8192 字节。');
		return;
	}
	showLoading();
	document.form.mh_sed_save.value = '1';
	document.form.mh_action.value = 'apply';
	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "Advanced_Mihomo_Content.asp";
	document.form.next_page.value = "";
	document.form.submit();
}

function updateSub(){
	submit_form('update');
}

/* 由 Advanced_Mihomo_action.asp 回调 */
function mihomo_apply_done(ok, msg){
	hideLoading();
	if (ok)
		setTimeout(function(){ location.reload(); }, 200);
	else
		alert(msg);
}

/* ================= 订阅精简 (sed 文本框) ================= */

/* 文本框为空 = 用内置默认精简; 非空 = 整段替代内置精简 (sed -f 语法) */
function slim_text_init(){
	var t = document.getElementById('mh_slim_text');
	if (t && trim_str(t.value) === '')
		t.placeholder = SLIM_REF;
}

function slim_clear(){
	if (!confirm('清空后恢复内置默认精简, 确定清空?'))
		return;
	var t = document.getElementById('mh_slim_text');
	t.value = '';
	t.placeholder = SLIM_REF;
}

/* 只读参考: 内置默认精简的动作清单 (与 mihomo-start 内置实现对应) */
var SLIM_REF = [
'# 内置默认精简(文本框留空时自动执行)的动作:',
'#   1. rules 去重               (跨行处理, 脚本内置 awk)',
'#   2. 截断 MATCH 之后的规则     (同上)',
'#   3. 关闭 sniffer             (跨行处理, 内置 awk)',
'#   4. dns.nameserver 只留前 3 条 (跨行处理, 内置 awk)',
'#   5. geo-auto-update 关闭, 等效 sed:',
'#        s/^geo-auto-update:.*/geo-auto-update: false/',
'#',
'# 注意: 你写了内容后, 上面 1-5 全部不再执行, 需要的行为要自己写。',
'# 每行一条 sed 命令, 对订阅配置生效。常用示例:',
'#   s/^log-level:.*/log-level: info/',
'#   /- {name:.*香港-01/d        # 删除名字含 香港-01 的节点行',
'#   s/香港-01/香港01/g          # 批量改名'
].join('\n');
function refresh_state(){
	location.reload();
}

function open_panel(){
	window.open(document.getElementById('mh_panel_url').innerHTML, '_blank');
}
</script>
</head>

<body onload="initial();" onUnLoad="return unload_body();">

<div class="wrapper">
    <div class="container-fluid" style="padding-right: 0px">
        <div class="row-fluid">
            <div class="span3"><center><div id="logo"></div></center></div>
            <div class="span9" >
                <div id="TopBanner"></div>
            </div>
        </div>
    </div>

    <div id="Loading" class="popup_bg"></div>

    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

    <form method="post" name="form" id="ruleForm" action="/Advanced_Mihomo_action.asp" target="hidden_frame">

    <input type="hidden" name="current_page" value="Advanced_Mihomo_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="MihomoConf;">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">
    <input type="hidden" name="mh_action" value="apply">
    <input type="hidden" name="mh_sed_save" value="0">

    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span3">
                <!--Sidebar content-->
                <!--=====Beginning of Main Menu=====-->
                <div class="well sidebar-nav side_nav" style="padding: 0px;">
                    <ul id="mainMenu" class="clearfix"></ul>
                    <ul class="clearfix">
                        <li>
                            <div id="subMenu" class="accordion"></div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="span9">
                <!--Body content-->
                <div class="row-fluid">
                    <div class="span12">
                        <div class="box well grad_colour_dark_blue">
                            <h2 class="box_head round_top">Mihomo 代理内核</h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <div class="alert alert-info" style="margin: 10px;">
                                        二进制: /usr/bin/mihomo（未压缩原版, squashfs 按需分页）&nbsp;|&nbsp;
                                        控制脚本: /usr/bin/mihomo-start&nbsp;|&nbsp;
                                        日志: /tmp/mihomo.log
                                    </div>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">

                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;">开关</th>
                                        </tr>

                                        <tr>
                                            <th width="45%">启用 Mihomo</th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="mh_enable_on_of">
                                                        <input type="checkbox" id="mh_enable_fake" <% nvram_match_x("", "mh_enable", "1", "value=1 checked"); %><% nvram_match_x("", "mh_enable", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="mh_enable" id="mh_enable_1" <% nvram_match_x("", "mh_enable", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="mh_enable" id="mh_enable_0" <% nvram_match_x("", "mh_enable", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                                <span id="mh_state_hint" style="color: #999; margin-left: 8px;"></span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>开机自动启动</th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="mh_autostart_on_of">
                                                        <input type="checkbox" id="mh_autostart_fake" <% nvram_match_x("", "mh_autostart", "1", "value=1 checked"); %><% nvram_match_x("", "mh_autostart", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="mh_autostart" id="mh_autostart_1" <% nvram_match_x("", "mh_autostart", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="mh_autostart" id="mh_autostart_0" <% nvram_match_x("", "mh_autostart", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                                <span style="color: #999; margin-left: 8px;">开机后由 rc 调 mihomo-start autostart</span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>DNS fake-ip 模式<br><span style="font-weight: normal; color: #999;">默认关</span></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="mh_fakeip_on_of">
                                                        <input type="checkbox" id="mh_fakeip_fake" <% nvram_match_x("", "mh_fakeip", "1", "value=1 checked"); %><% nvram_match_x("", "mh_fakeip", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="mh_fakeip" id="mh_fakeip_1" <% nvram_match_x("", "mh_fakeip", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="mh_fakeip" id="mh_fakeip_0" <% nvram_match_x("", "mh_fakeip", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                                <span style="color: #999; margin-left: 8px;">开=客户端解析到 198.18.x.x 假 IP, 域名规则匹配最准; 切换会重建配置并重启 (点“更新订阅”或“应用”生效)</span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;">配置</th>
                                        </tr>

                                        <tr>
                                            <th>订阅地址<br><span style="font-weight: normal; color: #999;">clash / mihomo 格式</span></th>
                                            <td>
                                                <input type="text" class="input" size="60" style="width: 92%;" maxlength="480" name="mh_sub_url" value="<% nvram_get_x("","mh_sub_url"); %>" placeholder="https://example.com/link/xxxxxxx?clash=3">
                                                <div style="color: #999; margin-top: 4px;">
                                                    机场给的 Clash 订阅链接。改完点“应用”只保存不联网；想立刻拉新配置点“更新订阅”。
                                                </div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>转发端口<br><span style="font-weight: normal; color: #999;">固定</span></th>
                                            <td>
                                                <code>7892</code> TCP REDIRECT + UDP TPROXY（透明代理，局域网设备走这个）
                                                &nbsp;|&nbsp; <code>7893</code> mixed（HTTP/SOCKS，给浏览器手动填）
                                                &nbsp;|&nbsp; <code>8053</code> 内置 DNS
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>控制面板</th>
                                            <td>
                                                <span id="mh_panel_url"><% mihomo_panel_url(); %></span>
                                                <button class="btn btn-mini" type="button" style="margin-left: 12px;" onclick="open_panel();">在浏览器打开</button>
                                                <div style="color: #999; margin-top: 4px;">面板是 yacd，随 mihomo 一起编在固件里，不需要联网加载。</div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>订阅精简<br><span style="font-weight: normal; color: #999;">默认关</span></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="mh_slim_on_of">
                                                        <input type="checkbox" id="mh_slim_fake" <% nvram_match_x("", "mh_slim", "1", "value=1 checked"); %><% nvram_match_x("", "mh_slim", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="mh_slim" id="mh_slim_1" <% nvram_match_x("", "mh_slim", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="mh_slim" id="mh_slim_0" <% nvram_match_x("", "mh_slim", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                                <span style="margin-left: 8px;"><% mihomo_slim_state(); %></span>
                                                <div style="color: #999; margin-top: 4px;">
                                                    开启后拉订阅时做针对性裁剪。改动点“应用”会自动重建配置生效。
                                                </div>
                                                <div style="margin-top: 8px; padding-top: 6px; border-top: 1px dashed #DDD; color: #555;">
                                                    <div style="margin-bottom: 6px;">
                                                        自定义精简 <b>sed</b>（每行一条，对订阅配置执行；
                                                        <b>写了内容就整段替代内置精简，留空则用内置默认</b>）：
                                                        &nbsp;<button class="btn btn-mini" type="button" onclick="slim_clear();">清空(用内置默认)</button>
                                                    </div>
                                                    <textarea name="mh_slim_text" id="mh_slim_text" rows="9" wrap="off" spellcheck="false"
                                                              maxlength="4096"
                                                              style="width: 96%; font-family: 'Courier New', monospace; font-size: 12px;"><% nvram_get_x("","mh_slim_text"); %></textarea>
                                                    <div style="color: #999; margin-top: 4px;">
                                                        改完点页面底部“应用本页面设置”保存；下次拉订阅(或手动 mihomo-start update)生效。
                                                        sed 执行出错会自动回退内置精简，不会把订阅打碎。内置默认动作见文本框占位提示。
                                                    </div>
                                                </div>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>订阅后处理<br><span style="font-weight: normal; color: #999;">my_sed.sh</span></th>
                                            <td>
                                                <div style="color: #999; margin-bottom: 6px;">
                                                    <b>与上面的精简开关无关</b>：精简关着也照样执行。执行顺序在精简之后，
                                                    所以这里改的是“精简后的结果”。每次拉完订阅自动跑一次。
                                                    脚本里用 <code>$1</code> 拿配置文件路径（<code>/tmp/mihomo/config.yaml</code>）。
                                                </div>
                                                <textarea name="mh_sed_text" id="mh_sed_text" rows="10" wrap="off" spellcheck="false"
                                                          maxlength="8192" placeholder="# 例: 追加一条自定义分流规则&#10;#  sed -i '/^rules:/a\\  - DOMAIN-SUFFIX,example.com,PROXY' &quot;$1&quot;"
                                                          style="width: 96%; font-family: 'Courier New', monospace; font-size: 12px;"><% mihomo_sed_get(); %></textarea>
                                                <div style="margin-top: 6px;">
                                                    <button class="btn btn-mini btn-primary" type="button" onclick="save_sed();">保存脚本并生效</button>
                                                    <span style="margin-left: 8px; color: #999;">
                                                        保存即落盘（重启不丢），有改动会自动重拉一次订阅让改动立刻生效；清空后保存 = 关闭钩子。
                                                    </span>
                                                </div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;">运行状态</th>
                                        </tr>

                                        <tr>
                                            <th>进程</th>
                                            <td>
                                                <% mihomo_status(); %>
                                                <button class="btn btn-mini" type="button" style="margin-left: 12px;" onclick="refresh_state();"><#CTL_refresh#></button>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>日志末尾 40 行</th>
                                            <td>
                                                <textarea rows="12" readonly="readonly" wrap="off" class="span12" style="font-family:'Courier New', Courier, mono; font-size:12px;"><% mihomo_log(); %></textarea>
                                            </td>
                                        </tr>

                                    </table>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <td style="border: 0 none;">
                                                <center>
                                                    <input type="button" id="btn_update" class="btn" style="width: 150px; margin-right: 10px;" onclick="updateSub();" value="更新订阅"/>
                                                    <input type="button" id="btn_apply" class="btn btn-primary" style="width: 219px" onclick="applyRule();" value="<#CTL_apply#>"/>
                                                </center>
                                            </td>
                                        </tr>
                                    </table>

                                    <div class="alert" style="margin: 10px; background-color: #F7F7F9; border: 1px solid #E1E1E8;">
                                        <b>命令行速查（SSH 里直接用）</b>
<pre style="margin: 8px 0 0 0; font-size: 12px; line-height: 1.5;">mihomo-start update        拉订阅 + 重建配置 + 重启 (改完订阅地址后必做一次)
mihomo-start start         用现有配置启动
mihomo-start restart       重启 (不重新拉订阅)
mihomo-start stop          停止
mihomo-start status        看进程状态
mihomo-start slim on|off|status   订阅精简开关
mihomo-start fakeip on|off|status DNS fake-ip 模式开关 (on=假 IP, off=真实 IP)
mihomo-start autostart     仅在 mh_autostart=1 时启动 (开机钩子调用)</pre>
                                        <div style="margin-top: 6px; color: #777;">
                                            订阅地址两处都认，<b>页面里的优先</b>：nvram <code>mh_sub_url</code> &gt; <code>/etc/storage/mihomo/sub_url.txt</code>。
                                            自定义 sed 钩子可直接在上面的文本框里改（存到 <code>/etc/storage/mihomo/my_sed.sh</code>，保存时自动落盘），
                                            每次拉完订阅自动执行；执行顺序在精简之后，与精简开关无关。
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="footer"></div>

    </form>
</div>

</body>
</html>
