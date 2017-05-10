# Execution Policy
# Play with this an alternative methods
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted

# Load Helpers
Push-Location (Split-Path -parent $profile)
"functions","aliases" | Where-Object {Test-Path "*_$_.ps1"} | ForEach-Object -process {
    Write-Host *_$_.pst1; Invoke-Expression ". .\*_$_.ps1"
}
Pop-Location

# Bypassing Execution Policy
# powershell.exe -ExecutionPolicy Bypass -File .runme.ps1
# -or-
# Get-Content .runme.ps1 | powershell.exe -noprofile -
# -or-
# powershell.exe -command "Write-Host 'My voice is my passport, verify me.'"

# Environment
Set-UI

# Helpers
Set-AD
Set-Git

# Elevated
if (Test-IsAdmin){
    Write-Host "Administrator"
}

# Everyone
Write-Host "Execution Policy: " (Get-ExecutionPolicy)
Write-Host "Profile : " $profile