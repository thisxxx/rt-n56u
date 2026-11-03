<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - EasyTier</title>
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
<% easytier_running(); %>

var $j = jQuery.noConflict();

	function initial(){
	show_banner(1);
	show_menu(5, 8, 4);
	show_footer();

	init_itoggle('et_enable');
	init_itoggle('et_autostart');
	init_itoggle('et_dhcp');
	init_itoggle('et_tun');

	if (!login_safe())
		E('btn_apply').disabled = true;

	if (!easytier_running())
		E('et_state_hint').innerHTML = '（当前没有进程在跑）';
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

/* 可重复字段是"空格分隔的一串值", 直接躺在 input 里, 提交时原样发给后端。
   前端什么都不用拆/拼 —— 拆词是 easytier-start 的事, 拼 argv 也是它的事。
   唯一要做的是把明显写错的东西挡在提交之前。 */
function et_check_multi(){
	var names = ['et_peers', 'et_subnets', 'et_private_groups'];
	var titles = { et_peers: '对等节点', et_subnets: '子网代理', et_private_groups: '私有组' };
	var i, v;

	for (i = 0; i < names.length; i++){
		v = document.form[names[i]].value;
		/* 用 | 当分隔符是上一版的事, 这里提示一下, 免得有人照老文档填 */
		if (v.indexOf('|') >= 0){
			alert('“' + titles[names[i]] + '”里不要写竖线 |。\n多个值请用空格分隔, 例如: 192.168.2.0/24 192.168.3.0/24');
			document.form[names[i]].focus();
			return false;
		}
	}
	return true;
}

/* ================= 表单提交 ================= */

function validForm(){
	if (!login_safe()){
		alert('当前不是局域网/HTTPS 安全会话，不允许修改 EasyTier');
		return false;
	}
	if (radio_value('et_enable') == '1'){
		if (trim_str(document.form.et_network_name.value) == ''){
			alert('已勾选“启用”，但“网络名”没填。\n不填网络名 EasyTier 起不来。');
			document.form.et_network_name.focus();
			return false;
		}
		/* 本机 IPv4 允许留空: 不指定虚拟网段地址, EasyTier 照样能加入网络做中继 / 子网代理 */
	}
	return true;
}

function applyRule(){
	if (!validForm())
		return;
	if (!et_check_multi())
		return;

	showLoading();

	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "Advanced_EasyTier_Content.asp";
	document.form.next_page.value = "";
	document.form.submit();
}

/* 由 Advanced_EasyTier_action.asp 回调 */
function easytier_apply_done(ok, msg){
	hideLoading();
	if (ok)
		setTimeout(function(){ location.reload(); }, 200);
	else
		alert(msg);
}

function refresh_state(){
	location.reload();
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

    <form method="post" name="form" id="ruleForm" action="/Advanced_EasyTier_action.asp" target="hidden_frame">

    <input type="hidden" name="current_page" value="Advanced_EasyTier_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="EasyTierConf;">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

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
                            <h2 class="box_head round_top">EasyTier 组网</h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <div class="alert alert-info" style="margin: 10px;">
                                        二进制: /usr/bin/easytier-core（命令行里叫 easytier-lite）&nbsp;|&nbsp;
                                        控制脚本: /usr/bin/easytier-start&nbsp;|&nbsp;
                                        日志: /tmp/easytier.log
                                    </div>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">

                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;">开关</th>
                                        </tr>

                                        <tr>
                                            <th width="45%">启用 EasyTier</th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="et_enable_on_of">
                                                        <input type="checkbox" id="et_enable_fake" <% nvram_match_x("", "et_enable", "1", "value=1 checked"); %><% nvram_match_x("", "et_enable", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="et_enable" id="et_enable_1" <% nvram_match_x("", "et_enable", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="et_enable" id="et_enable_0" <% nvram_match_x("", "et_enable", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                                <span id="et_state_hint" style="color: #999; margin-left: 8px;"></span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>开机自动启动</th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="et_autostart_on_of">
                                                        <input type="checkbox" id="et_autostart_fake" <% nvram_match_x("", "et_autostart", "1", "value=1 checked"); %><% nvram_match_x("", "et_autostart", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="et_autostart" id="et_autostart_1" <% nvram_match_x("", "et_autostart", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="et_autostart" id="et_autostart_0" <% nvram_match_x("", "et_autostart", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                                <span style="color: #999; margin-left: 8px;">开机后由 rc 调 easytier-start autostart</span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;">参数</th>
                                        </tr>

                                        <tr>
                                            <th>网络名 <code>--network-name</code></th>
                                            <td>
                                                <input type="text" class="input" size="48" maxlength="128" name="et_network_name" value="<% nvram_get_x("","et_network_name"); %>" placeholder="必填，例如 mynet">
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>网络密钥 <code>--network-secret</code></th>
                                            <td>
                                                <input type="password" class="input" size="48" maxlength="128" name="et_network_secret" id="et_network_secret" value="<% nvram_get_x("","et_network_secret"); %>" placeholder="留空表示无密钥">
                                                <button style="margin-left: -5px;" class="btn" type="button" onclick="passwordShowHide('et_network_secret')"><i class="icon-eye-close"></i></button>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>本机 IPv4 <code>--ipv4</code><br><span style="font-weight: normal; color: #999;">可留空</span></th>
                                            <td>
                                                <input type="text" class="input" size="32" maxlength="32" name="et_ipv4" value="<% nvram_get_x("","et_ipv4"); %>" placeholder="10.126.126.1/24，留空=不分配虚拟 IP">
                                                <div style="color: #999; margin-top: 4px;">留空则不指定虚拟网段地址，仍可加入网络做中继 / 子网代理。</div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>DHCP 自动分配虚拟 IP <code>-d</code><br><span style="font-weight: normal; color: #999;">仅 IPv4 留空时生效</span></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="et_dhcp_on_of">
                                                        <input type="checkbox" id="et_dhcp_fake" <% nvram_match_x("", "et_dhcp", "1", "value=1 checked"); %><% nvram_match_x("", "et_dhcp", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="et_dhcp" id="et_dhcp_1" <% nvram_match_x("", "et_dhcp", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="et_dhcp" id="et_dhcp_0" <% nvram_match_x("", "et_dhcp", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                                <span style="color: #999; margin-left: 8px;">IPv4 留空时勾选，由网络内开了 DHCP 的节点自动分一个虚拟 IP，本机就不用手填</span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>虚拟网卡 <code>--tun</code><br><span style="font-weight: normal; color: #999;">默认关</span></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="et_tun_on_of">
                                                        <input type="checkbox" id="et_tun_fake" <% nvram_match_x("", "et_tun", "1", "value=1 checked"); %><% nvram_match_x("", "et_tun", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="et_tun" id="et_tun_1" <% nvram_match_x("", "et_tun", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="et_tun" id="et_tun_0" <% nvram_match_x("", "et_tun", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                                <span style="color: #999; margin-left: 8px;">创建虚拟网卡，需要本机有虚拟 IP（手填 IPv4 或勾 DHCP）；两者都没选时开了也不生效（脚本自动忽略）。只当中继 / 子网代理就不用开</span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>对等节点 <code>-p</code><br><span style="font-weight: normal; color: #999;">可多份，多个用空格分隔</span></th>
                                            <td>
                                                <input type="text" class="input" size="60" style="width: 92%;" maxlength="512" name="et_peers" value="<% nvram_get_x("","et_peers"); %>" placeholder="tcp://公网节点:11010 tcp://另一个节点:11010">
                                                <div style="color: #999; margin-top: 4px;">多个值用空格分隔，例：tcp://a:11010 tcp://b:11010（单个值里不能有空格）</div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>子网代理 <code>-n</code><br><span style="font-weight: normal; color: #999;">可多份，多个用空格分隔</span></th>
                                            <td>
                                                <input type="text" class="input" size="60" style="width: 92%;" maxlength="512" name="et_subnets" value="<% nvram_get_x("","et_subnets"); %>" placeholder="192.168.2.0/24 192.168.3.0/24">
                                                <div style="color: #999; margin-top: 4px;">多个值用空格分隔，例：192.168.2.0/24 192.168.3.0/24（单个值里不能有空格）</div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>私有组 <code>--private-group</code><br><span style="font-weight: normal; color: #999;">可多份，多个用空格分隔</span></th>
                                            <td>
                                                <input type="text" class="input" size="60" style="width: 92%;" maxlength="512" name="et_private_groups" value="<% nvram_get_x("","et_private_groups"); %>" placeholder="朋友网络#朋友密钥 公司#另一个密钥">
                                                <div style="color: #999; margin-top: 4px;">多个值用空格分隔，例：朋友网络#朋友密钥 公司#另一个密钥<br>格式是 <b>网络名#密钥</b>；<b>密钥里不能有空格</b>，否则会被拆成两组</div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;">运行状态</th>
                                        </tr>

                                        <tr>
                                            <th>进程</th>
                                            <td>
                                                <% easytier_status(); %>
                                                <button class="btn btn-mini" type="button" style="margin-left: 12px;" onclick="refresh_state();"><#CTL_refresh#></button>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>日志末尾 40 行</th>
                                            <td>
                                                <textarea rows="12" readonly="readonly" wrap="off" class="span12" style="font-family:'Courier New', Courier, mono; font-size:12px;"><% easytier_log(); %></textarea>
                                            </td>
                                        </tr>

                                    </table>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <td style="border: 0 none;">
                                                <center>
                                                    <input type="button" id="btn_apply" class="btn btn-primary" style="width: 219px" onclick="applyRule();" value="<#CTL_apply#>"/>
                                                </center>
                                            </td>
                                        </tr>
                                    </table>

                                    <div class="alert" style="margin: 10px; background-color: #F7F7F9; border: 1px solid #E1E1E8;">
                                        <b>参数速查（只读，免得忘了怎么填）</b>
<pre style="margin: 8px 0 0 0; font-size: 12px; line-height: 1.5;"># 单组
easytier-lite \
  --network-name 你的网络名 \
  --network-secret 你的密钥 \
  --ipv4 10.126.126.1/24 \
  -p tcp://公网节点:11010 \
  -n 192.168.2.0/24 \
  --private-group "朋友网络#朋友密钥"

# 多节点 + 多子网 + 多私有组
easytier-lite \
  --network-name 你的网络名 \
  --network-secret 你的密钥 \
  --ipv4 10.126.126.1/24 \
  -p tcp://公网节点1:11010 -p tcp://公网节点2:11010 \
  -n 192.168.2.0/24 -n 192.168.3.0/24 \
  --private-group "朋友网络#朋友密钥" --private-group "公司#另一个密钥"

# 需要虚拟网卡时追加 --tun; 不想手填 IP 就用 -d 让网络内 DHCP 节点自动分配
easytier-lite \
  --network-name 你的网络名 \
  --network-secret 你的密钥 \
  -d --tun \
  -p tcp://公网节点:11010</pre>
                                        <div style="margin-top: 6px; color: #777;">
                                            说明: 本页只把 <b>已填</b> 的项拼进命令行；留空的项不会传。
                                            “对等节点”“子网代理”“私有组”三个框里<b>填几个值就重复几次</b> <code>-p</code> / <code>-n</code> / <code>--private-group</code>，值之间用<b>空格</b>分隔。
                                            单个值内部不能有空格（脚本按空格拆词，拆不开的写法会变成两个参数）。
                                            <b>虚拟网卡 --tun 默认关</b>：不开就只当中继 / 子网代理（最省内存）；要进虚拟网被别的节点访问才开。
                                            本机 IP 三种选法：<b>① 手填「本机 IPv4」</b>；② IPv4 留空 + 勾选「DHCP 自动分配 (-d)」，由网络内开 DHCP 的节点分一个；
                                            ③ 两个都不选，本机没有虚拟 IP，仅当中继 / 子网代理用（此时即使开了 --tun 也会被脚本自动忽略）。
                                            实际可执行版本每次“应用”后生成在 /tmp/easytier/run.sh。
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

    </form>

    <div id="footer"></div>
</div>
</body>
</html>
