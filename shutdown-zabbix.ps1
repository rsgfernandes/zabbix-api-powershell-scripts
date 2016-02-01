#rodrigofernandes@outlook.com
#zabbix endpoint connection
$ZABBIX_USER="tyoe your zabbix user"
$ZABBIX_PASS="type your zabbix password"
$uri="$uri="http://yourzabbixurl/api_jsonrpc.php""
$hostipaddress=((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
$filepath='c:\windows\temp\zabbix-hostid.txt'

#zabbix api authentication
$JsonAuth="{`"jsonrpc`": `"2.0`",`"method`": `"user.login`",`"params`": {`"user`": `"$ZABBIX_USER`",`"password`": `"$ZABBIX_PASS`"},`"id`": 0}"
$auth=Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JsonAuth
$sessao=$auth.result

#disable host monitoring
$hostid_enabled=Get-Content $filepath
$JsonDisableMonitoring="{`"jsonrpc`": `"2.0`",`"method`": `"host.update`",`"params`": {`"hostid`": `"$hostid_enabled`",`"status`": `"1`"}, `"auth`": `"$sessao`",`"id`": 1}"
Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JsonDisableMonitoring