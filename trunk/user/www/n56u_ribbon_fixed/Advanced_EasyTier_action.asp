<!DOCTYPE html>
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<script>
/* update_variables() 会往里写这三种回调，这里给他们空实现，避免 JS 报错 */
function done_committing(){}
function done_validating(action){}
function no_changes_and_no_committing(){}
function restart_needed_time(second){}
</script>
</head>

<body>
<% update_variables(); %>
<% easytier_action(); %>
<% asus_nvram_commit(); %>
</body>
</html>
