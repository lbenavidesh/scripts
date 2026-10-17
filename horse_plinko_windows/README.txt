HPCC4 WINDOWS PREP — TWO SMALL SCRIPTS

01-audit.ps1: Read-only local users/admins, firewall status, listening TCP ports,
services, non-Microsoft scheduled tasks, and recent failed logins. Some sections
may be unavailable without admin access. No competition data is copied to Mac.

02-change-local-passwords.ps1: Prompted, optional password changes for LOCAL
Windows users plinktern and jmoney. No passwords hardcoded. Requires elevated
PowerShell. Does not modify domain accounts or Jenkins/MariaDB passwords.

IMPORTANT PACKET RULES:
- If jmoney password changes, immediately update NEIGH > Users with new password
  for that box; save and verify RDP scoring. Never disable jmoney.
- Changing plinktern default password early is recommended by packet.
- Keep RDP available, and keep Jenkins on Assembly and MariaDB on Manifest working.
- Do not indiscriminately disable services, block ports, change application
  credentials, export logs to Mac, or upload competition data.
- Check rules with White Team for uncertainty; Black Team for technical problems.

HOW TO RUN FROM WINDOWS POWERSHELL (NOT MAC TERMINAL):
1) Transfer these scripts INTO your Windows VM by an approved method.
2) Open Windows PowerShell as Administrator.
3) cd to the folder containing these files.
4) .\01-audit.ps1
5) If appropriate and ready to update NEIGH: .\02-change-local-passwords.ps1

If execution is blocked, inspect Get-ExecutionPolicy -List before changing policy.
A temporary Process-scope RemoteSigned policy may be possible if permitted.
