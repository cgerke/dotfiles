# Execution Policy - play with alternatives
# powershell.exe -ExecutionPolicy Bypass -File .runme.ps1
# powershell.exe -command "Write-Host 'My voice is my passport, verify me.'"
# Get-Content .runme.ps1 | powershell.exe -noprofile -
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted

# Debug
$DebugPreference = "SilentlyContinue"

# Load Helpers
Push-Location (Split-Path -parent $profile)
"functions","aliases" | Where-Object {Test-Path "*_$_.ps1"} | ForEach-Object -process {
    Write-Host *_$_.pst1; Invoke-Expression ". .\*_$_.ps1"
}
Pop-Location

# Modules
$Modules = @("posh-git", "PSPath", "PSSudo")
foreach ($Module in $Modules) {
    if (!(Test-Path $home\Documents\WindowsPowerShell\Modules\$Module)) {
        Write-Host "Installing module $Module"
        PowerShellGet\Install-Module $Module -Scope CurrentUser
    }
    if (Get-Module -ListAvailable -Name $Module) {
        Write-Host "Importing module $Module"
        Import-Module $Module
    }
}

# Git https://github.com/dahlbyk/posh-git
if (Get-Command git -TotalCount 1 -ErrorAction SilentlyContinue) {
    Write-Host (git --version)
    Append-Path((Get-Item "Env:ProgramFiles").Value + "\Git\bin")
}

# Everyone
Write-Host "Execution Policy: " (Get-ExecutionPolicy)
Write-Host "Profile : " $profile

# GUI
# $Host.UI.RawUI.WindowTitle = "Elevated"
# $Host.UI.RawUI.BackgroundColor = 'Black'
# $Host.UI.RawUI.ForegroundColor = 'White'
# $Host.PrivateData.ErrorForegroundColor = 'Red'
# $Host.PrivateData.ErrorBackgroundColor = $bckgrnd
# $Host.PrivateData.WarningForegroundColor = 'Magenta'
# $Host.PrivateData.WarningBackgroundColor = $bckgrnd
# $Host.PrivateData.DebugForegroundColor = 'Yellow'
# $Host.PrivateData.DebugBackgroundColor = $bckgrnd
# $Host.PrivateData.VerboseForegroundColor = 'Green'
# $Host.PrivateData.VerboseBackgroundColor = $bckgrnd
# $Host.PrivateData.ProgressForegroundColor = 'Cyan'
# $Host.PrivateData.ProgressBackgroundColor = $bckgrnd
# Clear-Host