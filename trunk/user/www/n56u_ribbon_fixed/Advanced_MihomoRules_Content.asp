<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - Mihomo 规则</title>
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

var $j = jQuery.noConflict();

function initial(){
	show_banner(1);
	show_menu(5, 8, 6);
	show_footer();
}

function refresh_rules(){
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
                            <h2 class="box_head round_top">Mihomo 分流规则（只读）</h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <div class="alert alert-info" style="margin: 10px;">
                                        <% mihomo_rules_stat(); %>
                                        &nbsp;|&nbsp; 来源: /tmp/mihomo/config.yaml（当前实际生效的配置）
                                        <button class="btn btn-mini" type="button" style="margin-left: 12px;" onclick="refresh_rules();">刷新</button>
                                    </div>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th style="width: 120px;">rules 段</th>
                                            <td>
                                                <textarea rows="28" readonly="readonly" wrap="off" spellcheck="false"
                                                          style="width: 98%; font-family: 'Courier New', monospace; font-size: 12px;"><% mihomo_rules_get(); %></textarea>
                                                <div style="color: #999; margin-top: 6px;">
                                                    每行一条规则，从上到下匹配，命中即停止（最后的 MATCH/DIRECT 兜底）。
                                                    规则内容来自订阅 + 你的精简 sed + 订阅后处理脚本，改内容请到
                                                    “Mihomo”页的精简/后处理文本框，然后执行 <code>mihomo-start update</code>。
                                                    兜底空配置模式下这里只有一条 MATCH,DIRECT，属正常现象（订阅未拉到）。
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="footer"></div>

</div>

</body>
</html>
