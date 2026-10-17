# Horse Plinko Windows: read-only inspection script.
# Run inside your assigned Windows Server in an elevated PowerShell window.
# Does not change configuration, save logs, or transfer competition data.
$ErrorActionPreference = 'Continue'
function Section($Name) { Write-Host "`n========== $Name ==========" -ForegroundColor Cyan }
Section 'Host and PowerShell identity'
hostname
whoami
Get-ComputerInfo | Select-Object WindowsProductName,WindowsVersion,OsBuildNumber
Section 'Local users (review; do not blindly disable)'
Get-LocalUser | Select-Object Name,Enabled,LastLogon,PasswordRequired | Format-Table -AutoSize
Section 'Local administrators (review unexpected membership)'
try { Get-LocalGroupMember -Group 'Administrators' | Select-Object Name,ObjectClass,PrincipalSource | Format-Table -AutoSize } catch { Write-Warning $_ }
Section 'Windows Firewall status (inspection only)'
Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Format-Table -AutoSize
Section 'Listening TCP ports (compare to required services before changing anything)'
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Sort-Object LocalPort | Select-Object LocalAddress,LocalPort,OwningProcess | Format-Table -AutoSize
Section 'Running services (do not disable scored services or collectors)'
Get-Service | Where-Object Status -eq 'Running' | Sort-Object DisplayName | Select-Object Name,DisplayName,Status | Format-Table -AutoSize
Section 'Scheduled tasks outside Microsoft task tree (review, do not delete blindly)'
Get-ScheduledTask | Where-Object {$_.TaskPath -notlike '\Microsoft\*'} | Select-Object TaskPath,TaskName,State | Format-Table -AutoSize
Section 'Recent local Windows logon failures (event 4625; may require admin)'
try { Get-WinEvent -FilterHashtable @{LogName='Security';Id=4625;StartTime=(Get-Date).AddHours(-4)} -MaxEvents 10 -ErrorAction Stop | Select-Object TimeCreated,Id,Message | Format-List } catch { Write-Warning 'No accessible matching events, or access denied.' }
Section 'Done'
Write-Host 'Read-only inspection complete. Review NEIGH scoring before making changes.' -ForegroundColor Green
