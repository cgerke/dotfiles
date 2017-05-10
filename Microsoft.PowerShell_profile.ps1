# Execution Policy
# Play with this an alternative methods
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted

# Load Helpers
Push-Location (Split-Path -parent $profile)
"functions","aliases" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location

# Bypassing Execution Policy
# powershell.exe -ExecutionPolicy Bypass -File .runme.ps1
# -or-
# Get-Content .runme.ps1 | powershell.exe -noprofile -
# -or-
# powershell.exe -command "Write-Host 'My voice is my passport, verify me.'"

# Colour
Set-UI

# Environment
if (Test-IsAdmin){
    # Elevated console
    #Set-ExecutionPolicy RemoteSigned
    Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted
} else {
    # Current user console
    # Git environment
    if (Test-Git){
        Import-Module posh-git
    }
}

# Everyone
Write-Host "Execution Policy: " (Get-ExecutionPolicy)
Write-Host "Profile : " $profile
Write-Host " "