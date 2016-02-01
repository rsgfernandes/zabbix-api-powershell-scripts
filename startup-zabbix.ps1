#rodrigofernandes@outlook.com
#zabbix endpoint connection
$ZABBIX_USER="type your zabbix user"
$ZABBIX_PASS="type your zabbix password"
$uri="http://yourzabbixurl/api_jsonrpc.php"
$hostipaddress=((ipconfig | findstr [0-9].\.)[0]).Split()[-1]
$filepath='c:\windows\temp\zabbix-hostid.txt'
$host_group_name="type your hostgroup name here"

#check if zabbix is already enabled 
if (Test-Path $filepath) {
echo 'Zabbix already configured'
}
else {

#zabbix api authentication
$JsonAuth="{`"jsonrpc`": `"2.0`",`"method`": `"user.login`",`"params`": {`"user`": `"$ZABBIX_USER`",`"password`": `"$ZABBIX_PASS`"},`"id`": 0}"
$auth=Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JsonAuth
$sessao=$auth.result

#get hostgroup infos

$JsonHostGroupInfo="{`"jsonrpc`": `"2.0`",`"method`": `"hostgroup.get`",`"params`": {`"selectInterfaces`": `"extend`",`"filter`": {`"name`":`"$host_group_name`"}}, `"auth`": `"$sessao`",`"id`": 1}"
$PostGetHostGroupInfo=Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JsonHostGroupInfo
$hostgroupinfo=$PostGetHostGroupInfo.result
$host_group_id=$hostgroupinfo.groupid



#get hosts from a group

$JsonGetHostsFromGroup="{`"jsonrpc`": `"2.0`",`"method`": `"host.get`",`"params`": {`"groupids`": `"$host_group_id`"}, `"auth`": `"$sessao`",`"id`": 1}"
$PostGetHostsFromGroup=Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JsonGetHostsFromGroup
$hosts_status=$PostGetHostsFromGroup.result | select host,hostid,status

#get the first disabled host in group

$getfirstdisabled=$hosts_status | select-string -pattern "status=1" | Select-Object -First 1
$breaksemicolon=$getfirstdisabled.Line.Split(';')
$firstdisabled=$breaksemicolon -replace'[@{}]'
$host_disabled=$firstdisabled[0] -replace '[host=]'
$hostid_enabled=$firstdisabled[1] -replace '[ hostid=]'


#get host infos

$JsonHostInfo="{`"jsonrpc`": `"2.0`",`"method`": `"host.get`",`"params`": {`"selectInterfaces`": `"extend`",`"filter`": {`"host`":`"$host_disabled`"}}, `"auth`": `"$sessao`",`"id`": 1}"
$PostGetHostInfo=Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JsonHostInfo
$hostinfo=$PostGetHostInfo.result
$host_interface_id=$hostinfo.interfaces.interfaceid
$host_interface_ip=$hostinfo.interfaces.ip



#change host ip

$JsonChangeHostIp="{`"jsonrpc`": `"2.0`",`"method`": `"hostinterface.update`",`"params`": {`"interfaceid`": `"$host_interface_id`",`"ip`": `"$hostipaddress`"}, `"auth`": `"$sessao`",`"id`": 1}"
Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JsonChangeHostIp


#enable host monitoring

$JsonEnableMonitoring="{`"jsonrpc`": `"2.0`",`"method`": `"host.update`",`"params`": {`"hostid`": `"$hostid_enabled`",`"status`": `"0`"}, `"auth`": `"$sessao`",`"id`": 1}"
Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body $JsonEnableMonitoring
echo $hostid_enabled | Out-File -FilePath $filepath
}