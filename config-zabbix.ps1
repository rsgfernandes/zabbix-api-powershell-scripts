#rodrigofernandes@outlook.com
#the instanceID variable can be changed for different values to set the host name in zabbix config filepath
#here, i used a call to AWS to collect the instance-id
$instanceID = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id
$filepath="C:\Zabbix\conf\zabbix_agentd.win.conf"
$config_zabbix=Get-Content $filepath
$config_zabbix[4]="Hostname=$instanceID"  
echo $config_zabbix | Out-File -FilePath $filepath -Encoding ascii
net start "Zabbix Agent"