#rodrigofernandes@outlook.com
$downloadedfilespath="C:\Windows\Temp\Zabbix"
$downloadedzabbixpath="C:\Windows\Temp\Zabbix\zabbix"
$installdestination="C:\"
$installedzabbixpath="C:\zabbix"
$bucketname="type your bucketname here"
$keyprefix="type the key prefix here"

#download files from S3 Bucket
Read-S3Object -BucketName $bucketname -KeyPrefix $keyprefix -Folder $downloadedfilespath

#config firewall rules
netsh advfirewall firewall add rule name="Zabbix Agent" dir=in action=allow protocol=TCP localport=10050
netsh advfirewall firewall add rule name="Zabbix Agent" dir=out action=allow protocol=TCP localport=10050
netsh advfirewall firewall add rule name="Zabbix Agent" dir=in action=allow protocol=UDP localport=10050
netsh advfirewall firewall add rule name="Zabbix Agent" dir=out action=allow protocol=UDP localport=10050

#install application
Move-Item -Path $downloadedzabbixpath -Destination $installdestination
Move-Item -Path $downloadedfilespath\startup-zabbix.ps1 -Destination $installedzabbixpath\startup-zabbix.ps1
Move-Item -Path C:\Windows\Temp\Zabbix\config-zabbix.ps1 -Destination $installedzabbixpath\config-zabbix.ps1

#run zabbix configuration script
powershell.exe -noprofile -executionpolicy Unrestricted -file $installedzabbixpath\config-zabbix.ps1

#start host monitoring on zabbix script
powershell.exe -noprofile -executionpolicy Unrestricted -file $installedzabbixpath\startup-zabbix.ps1