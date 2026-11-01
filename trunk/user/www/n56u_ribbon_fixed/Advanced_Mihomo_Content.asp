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
                                            <th>订阅精简<br><span style="font-weight: normal; color: #999;">mihomo-start slim</span></th>
                                            <td>
                                                <% mihomo_slim_state(); %>
                                                <div style="color: #999; margin-top: 4px;">
                                                    开启后会在拉取订阅后做针对性裁剪（规则去重、截断 MATCH 之后的死规则、
                                                    关 sniffer、nameserver 只留前几条）。SSH 里用 <code>mihomo-start slim on|off|status</code> 切换。
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
mihomo-start autostart     仅在 mh_autostart=1 时启动 (开机钩子调用)</pre>
                                        <div style="margin-top: 6px; color: #777;">
                                            订阅地址两处都认，<b>页面里的优先</b>：nvram <code>mh_sub_url</code> &gt; <code>/etc/storage/mihomo/sub_url.txt</code>。
                                            自定义 sed 钩子放在 <code>/etc/storage/mihomo/my_sed.sh</code>，每次拉完订阅自动执行，失败会回滚。
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
