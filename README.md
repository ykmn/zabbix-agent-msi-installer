# Zabbix Agent MSI Remote Install script

BAT-script for easy Zabbix Agent MSI package installation/update on remote Windows host. You may use it if you can't use Group Policy deployment.

1. Set correct Agent version and Zabbix server IP editing following strings in script:
`set ZAGENT=zabbix_agent-3.4.7`
`set ZSERIP=172.16.100.100`
2. Download latest Sysinternals PsExec: https://docs.microsoft.com/en-us/sysinternals/downloads/psexec and put it to script folder.
3. Run script with remote computer name as parameter:
`agentinstall \\COMPUTERNAME`
Script downloads x86 and x64 Zabbix Agent .msi from http://www.suiviperf.com/zabbix/ to script folder.
4. Enter remote computer admin credentials as DOMAIN\user or just press Enter if you have admin permissions on remote computer.
5. Check messages.

Script connects remote c$ share, creates C:\temp folder, copy .msi to remote folder, stops Zabbix Agent service, install .msi and starts service again.

28.12.2017 Roman Ermakov <r.ermakov@emg.fm>
