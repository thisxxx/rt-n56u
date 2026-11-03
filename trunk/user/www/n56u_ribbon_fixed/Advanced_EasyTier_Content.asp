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
	init_itoggle('et_no_listener');

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
	else {
		/* 失败时也要刷新: 日志区和运行状态都还是"应用之前"的内容,
		 * 提示语里却让人去看日志 —— 不刷新等于让人看旧日志, 排不了错 */
		alert(msg);
		setTimeout(function(){ location.reload(); }, 300);
	}
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
                                                <span style="color: #999; margin-left: 8px;">建虚拟网卡，需要本机有虚拟 IP（手填 IPv4 或勾 DHCP）；只当中继 / 子网代理就不用开</span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>主机名 <code>--hostname</code><br><span style="font-weight: normal; color: #999;">选填</span></th>
                                            <td>
                                                <input type="text" class="input" size="32" maxlength="64" name="et_hostname" value="<% nvram_get_x("","et_hostname"); %>" placeholder="k2p-客厅，留空=用系统名">
                                                <div style="color: #999; margin-top: 4px;">本节点在 EasyTier 网络里的显示名，纯透传；留空则不传该参数，由内核用系统主机名。</div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>监听地址 <code>-l</code><br><span style="font-weight: normal; color: #999;">可多份，留空=默认</span></th>
                                            <td>
                                                <input type="text" class="input" size="60" style="width: 92%;" maxlength="512" name="et_listeners" value="<% nvram_get_x("","et_listeners"); %>" placeholder="tcp://0.0.0.0:11010 udp://0.0.0.0:11010">
                                                <div style="color: #999; margin-top: 4px;">
                                                    多个值用空格分隔，一个值一个 <code>-l</code>。
                                                    <b>留空时不传该参数</b>，lite 的缺省值是 <code>tcp+udp 0.0.0.0:11010</code>（公网可直连的节点就留空）。
                                                    勾了下面「不监听」时，这里填了也会被忽略。
                                                </div>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>不监听 <code>--no-listener</code><br><span style="font-weight: normal; color: #999;">默认关</span></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="et_no_listener_on_of">
                                                        <input type="checkbox" id="et_no_listener_fake" <% nvram_match_x("", "et_no_listener", "1", "value=1 checked"); %><% nvram_match_x("", "et_no_listener", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" name="et_no_listener" id="et_no_listener_1" <% nvram_match_x("", "et_no_listener", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" name="et_no_listener" id="et_no_listener_0" <% nvram_match_x("", "et_no_listener", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                                <span style="color: #999; margin-left: 8px;">只主动出连、不接受入连（纯客户端 / 只出不进）；勾上后不再下发 <code>-l</code></span>
                                            </td>
                                        </tr>

                                        <tr>
                                            <th>日志级别 <code>--console-log-level</code><br><span style="font-weight: normal; color: #999;">默认不传</span></th>
                                            <td>
                                                <select class="input" name="et_log_level" style="width: 180px;">
                                                    <option value="" <% nvram_match_x("","et_log_level","","selected"); %>>（不传，用程序默认）</option>
                                                    <option value="error" <% nvram_match_x("","et_log_level","error","selected"); %>>error（只报错）</option>
                                                    <option value="warn" <% nvram_match_x("","et_log_level","warn","selected"); %>>warn</option>
                                                    <option value="info" <% nvram_match_x("","et_log_level","info","selected"); %>>info</option>
                                                    <option value="debug" <% nvram_match_x("","et_log_level","debug","selected"); %>>debug</option>
                                                    <option value="trace" <% nvram_match_x("","et_log_level","trace","selected"); %>>trace（最详细，日志涨得快）</option>
                                                </select>
                                                <div style="color: #999; margin-top: 4px;">控制台日志级别，只影响写进 /tmp/easytier.log 的详细程度；排查连接问题时临时调到 debug。</div>
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
                                        <b>easytier-lite 全部可用参数</b>
                                        <div style="margin-top: 4px; color: #777; font-size: 12px;">
                                            本固件用的是 <b>lite 精简版</b>，命令行解析是手写的（不含 clap），只认下表这些参数。
                                            它<b>遇到不认识的参数会直接退出</b>并打印 <code>unknown argument ...; try --help</code>，所以别往里塞完整版的参数。
                                        </div>
                                        <table style="margin-top: 8px; font-size: 12px; border-collapse: collapse; width: 100%;">
                                            <tr style="background: #EFEFF3;">
                                                <th style="text-align: left; padding: 3px 6px; border-bottom: 1px solid #DDD;">参数</th>
                                                <th style="text-align: left; padding: 3px 6px; border-bottom: 1px solid #DDD;">短名</th>
                                                <th style="text-align: left; padding: 3px 6px; border-bottom: 1px solid #DDD;">含义</th>
                                                <th style="text-align: left; padding: 3px 6px; border-bottom: 1px solid #DDD;">本页</th>
                                            </tr>
                                            <tr><td style="padding: 2px 6px;"><code>--network-name</code></td><td style="padding: 2px 6px;">—</td><td style="padding: 2px 6px;">网络名，<b>必填</b>，同一个网络内必须一致</td><td style="padding: 2px 6px;">可填</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--network-secret</code></td><td style="padding: 2px 6px;">—</td><td style="padding: 2px 6px;">网络密钥，需与其它节点一致</td><td style="padding: 2px 6px;">可填</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--ipv4</code></td><td style="padding: 2px 6px;">—</td><td style="padding: 2px 6px;">静态虚拟地址，带掩码如 <code>10.126.126.1/24</code>；留空则不传</td><td style="padding: 2px 6px;">可填</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--dhcp</code></td><td style="padding: 2px 6px;"><code>-d</code></td><td style="padding: 2px 6px;">由网络内开 DHCP 的节点自动分配虚拟 IP（<b>不是</b>守护进程）</td><td style="padding: 2px 6px;">开关</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--tun</code></td><td style="padding: 2px 6px;">—</td><td style="padding: 2px 6px;">创建虚拟网卡（<b>默认不建</b>，加了才建），需先有虚拟 IP</td><td style="padding: 2px 6px;">开关</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--peers</code></td><td style="padding: 2px 6px;"><code>-p</code></td><td style="padding: 2px 6px;">对等节点地址，如 <code>tcp://公网节点:11010</code>，可重复</td><td style="padding: 2px 6px;">可填</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--proxy-networks</code></td><td style="padding: 2px 6px;"><code>-n</code></td><td style="padding: 2px 6px;">子网代理，可重复；支持映射写法 <code>本网段-&gt;对端网段</code></td><td style="padding: 2px 6px;">可填</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--private-group</code></td><td style="padding: 2px 6px;">—</td><td style="padding: 2px 6px;">私有模式白名单 <code>"网络名#密钥"</code>，可重复</td><td style="padding: 2px 6px;">可填</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--hostname</code></td><td style="padding: 2px 6px;">—</td><td style="padding: 2px 6px;">本节点显示名，纯透传，留空则用系统名</td><td style="padding: 2px 6px;">可填</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--listeners</code></td><td style="padding: 2px 6px;"><code>-l</code></td><td style="padding: 2px 6px;">监听地址，可重复；<b>不填时缺省 <code>tcp+udp 0.0.0.0:11010</code></b></td><td style="padding: 2px 6px;">可填</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--no-listener</code></td><td style="padding: 2px 6px;">—</td><td style="padding: 2px 6px;">不监听，只主动出连（纯客户端 / 只出不进），与 <code>-l</code> 互斥</td><td style="padding: 2px 6px;">开关</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--console-log-level</code></td><td style="padding: 2px 6px;">—</td><td style="padding: 2px 6px;">控制台日志级别，只认 <code>error</code> / <code>warn</code> / <code>info</code> / <code>debug</code> / <code>trace</code></td><td style="padding: 2px 6px;">下拉</td></tr>
                                            <tr><td style="padding: 2px 6px;"><code>--help</code> / <code>--version</code></td><td style="padding: 2px 6px;"><code>-h</code> / <code>-V</code></td><td style="padding: 2px 6px;">在 SSH 里确认当前二进制的版本与可用参数</td><td style="padding: 2px 6px;">—</td></tr>
                                        </table>
                                        <div style="margin-top: 4px; color: #777; font-size: 12px;">
                                            上表参数本页均已覆盖，填了才会拼进命令行。
                                        </div>

                                        <div style="margin-top: 8px;"><b>常用写法</b></div>
<pre style="margin: 6px 0 0 0; font-size: 12px; line-height: 1.5;"># 1) 手填 IP + 一个对等节点 + 代理自己网段（最常见的旁路由 / 子网互访）
easytier-lite \
  --network-name 你的网络名 \
  --network-secret 你的密钥 \
  --ipv4 10.126.126.1/24 \
  -p tcp://公网节点:11010 \
  -n 192.168.2.0/24

# 2) 多节点 + 多子网 + 多私有组（值重复几次就是几个参数）
easytier-lite \
  --network-name 你的网络名 \
  --network-secret 你的密钥 \
  --ipv4 10.126.126.1/24 \
  -p tcp://公网节点1:11010 -p tcp://公网节点2:11010 \
  -n 192.168.2.0/24 -n 192.168.3.0/24 \
  --private-group "朋友网络#朋友密钥" --private-group "公司#另一个密钥"

# 3) 子网映射：把对端 10.0.0.0/24 映射到本机可达的 192.168.2.0/24
easytier-lite \
  --network-name 你的网络名 \
  --network-secret 你的密钥 \
  -n 192.168.2.0/24-&gt;10.0.0.0/24

# 4) 不想手填 IP：-d 让网络内开了 DHCP 的节点自动分配（--ipv4 必须留空）
easytier-lite \
  --network-name 你的网络名 \
  --network-secret 你的密钥 \
  -d \
  -p tcp://公网节点:11010

# 5) 要进虚拟网才加 --tun（默认不建），且必须已经有虚拟 IP（手填或 -d）
easytier-lite \
  --network-name 你的网络名 \
  --network-secret 你的密钥 \
  -d --tun \
  -p tcp://公网节点:11010

# 6) 纯中继 / 只出不进：不加 IP、不加 --tun，再关掉监听
easytier-lite \
  --network-name 你的网络名 \
  --network-secret 你的密钥 \
  --no-listener \
  -p tcp://公网节点:11010</pre>
                                        <div style="margin-top: 6px; color: #777;">
                                            <b>本页怎么拼命令行</b>：只把<b>已填 / 已勾</b>的项拼进去，留空的不传。
                                            “对等节点”“子网代理”“私有组”三个框里<b>填几个值就重复几次</b> <code>-p</code> / <code>-n</code> / <code>--private-group</code>，值之间用<b>空格</b>分隔；
                                            单个值内部不能有空格，否则会被拆成两个参数。
                                            <br>
                                            <b>本机 IP 三选一（互斥）</b>：<b>① 手填「本机 IPv4」</b> → 传 <code>--ipv4</code>；
                                            ② IPv4 留空 + 勾「DHCP 自动分配 (-d)」→ 只传 <code>-d</code>；
                                            ③ 两个都不选 → 本机没有虚拟 IP，仅当中继 / 子网代理用。填了 IPv4 又勾 -d 时<b>以静态 IP 为准</b>，不会两个都传。
                                            <br>
                                            <b>虚拟网卡 <code>--tun</code> 默认关</b>：不开就只当中继 / 子网代理（最省内存）；要进虚拟网被别的节点访问才开。
                                            没有虚拟 IP 时即使勾了也不启用，脚本会写一行日志说明。
                                            <br>
                                            <b>监听口</b>：不填 <code>-l</code> 时默认监听 <code>tcp+udp 0.0.0.0:11010</code>，公网可直连的节点需要保留；只想出连不想被连，勾「不监听 <code>--no-listener</code>」。
                                            两者<b>互斥</b>：勾了不监听，就算「监听地址」里填了内容也不会下发（日志会写明已忽略）。
                                            <br>
                                            <b>主机名 / 日志级别</b>：主机名只是显示名，留空不影响连通；日志级别留空即用程序默认，排查连不上时临时调 <code>debug</code>，平时建议 <code>warn</code> 或 <code>info</code>，因为 <code>trace</code> 会让日志涨得很快。
                                            <br>
                                            实际执行的命令每次“应用”后生成在 <code>/tmp/easytier/run.sh</code>，跑起来后可用 <code>tail -f /tmp/easytier.log</code> 看启动参数与错误。
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
