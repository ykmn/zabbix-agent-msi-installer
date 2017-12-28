# Zabbix Agent MSI Remote Install script
======================================
28.12.2017 Roman Ermakov <r.ermakov@emg.fm>

BAT-script for easy Zabbix Agent MSI package installation/update on remote Windows host. You may use it if you can't use Group Policy deployment.

1. Download latest Zabbix Agent MSI package: http://www.suiviperf.com/zabbix/ and put zabbix_agent-\*_x64.msi and zabbix_agent-\*_x86.msi to script folder.
2. Download latest Sysinternals PsExec: https://docs.microsoft.com/en-us/sysinternals/downloads/psexec and put it to script folder.
3. Set correct Agent version and Zabbix server IP editing following strings in script:
`set ZAGENT=zabbix_agent-3.4.3
set ZSERIP=172.16.100.100`
4. Run script with remote computer name as parameter:
`agentinstall \\COMPUTERNAME`
5. Enter remote computer admin credentials as DOMAIN\user or just press Enter if you have admin permissions on remote computer.
6. Check messages.
> Script connects remote c$ share, creates C:\temp folder, copy .msi to remote folder, stops Zabbix Agent service, install .msi and starts service again.
