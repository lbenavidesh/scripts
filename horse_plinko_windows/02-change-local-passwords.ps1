# Horse Plinko Windows: interactively rotate local Windows accounts ONLY.
# Do NOT put passwords in this file. Does NOT change application passwords.
# IMPORTANT: after changing jmoney here, immediately update NEIGH > Users.
# Start from an elevated PowerShell session on the intended Windows box.
$ErrorActionPreference = 'Stop'
$me = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]$me
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error 'Open PowerShell using Run as administrator on the assigned Windows VM.'
    exit 1
}
Write-Host "This machine: $env:COMPUTERNAME" -ForegroundColor Cyan
Write-Host 'Confirm you are on your ASSIGNED Windows machine.'
Write-Host 'Scoring note: jmoney must stay enabled and its new password must be entered in NEIGH > Users.' -ForegroundColor Yellow
Write-Host 'Application passwords (Jenkins / MariaDB) are separate.' -ForegroundColor Yellow
$confirm = Read-Host 'Type YES to continue'
if ($confirm -cne 'YES') { Write-Host 'Cancelled'; exit }
foreach ($account in @('plinktern','jmoney')) {
    try { $user = Get-LocalUser -Name $account -ErrorAction Stop }
    catch { Write-Warning "Local user '$account' not found. No changes made for it. Confirm whether the account is domain-managed."; continue }
    $choice = Read-Host "Change LOCAL Windows password for $account now? (y/N)"
    if ($choice -ne 'y') { Write-Host "Skipped $account"; continue }
    $pw1 = Read-Host "Enter NEW password for $account" -AsSecureString
    $pw2 = Read-Host "Re-enter NEW password for $account" -AsSecureString
    $bstr1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw1)
    $bstr2 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw2)
    try {
        $a = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr1)
        $b = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr2)
        if ([string]::IsNullOrWhiteSpace($a) -or $a -cne $b) { Write-Warning "Passwords blank or did not match: SKIPPED $account"; continue }
        Set-LocalUser -Name $account -Password $pw1 -ErrorAction Stop
        Write-Host "Updated Windows password for $account" -ForegroundColor Green
        if ($account -eq 'jmoney') { Write-Host 'ACTION REQUIRED NOW: update jmoney password under NEIGH > Users for THIS Windows box, save, then verify RDP scoring.' -ForegroundColor Yellow }
    }
    catch { Write-Warning "Password change failed for ${account}: $_" }
    finally {
        if ($bstr1 -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1) }
        if ($bstr2 -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2) }
        $a = $null; $b = $null; $pw1 = $null; $pw2 = $null
    }
}
Write-Host 'Done. Check NEIGH Details and confirm remote access. Do not disable scoring users.'
