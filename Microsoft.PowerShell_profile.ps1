# Execution Policy - play with alternatives
# powershell.exe -ExecutionPolicy Bypass -File .runme.ps1
# -or-
# Get-Content .runme.ps1 | powershell.exe -noprofile -
# -or-
# powershell.exe -command "Write-Host 'My voice is my passport, verify me.'"
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted

# Load Helpers
Push-Location (Split-Path -parent $profile)
"functions","aliases" | Where-Object {Test-Path "*_$_.ps1"} | ForEach-Object -process {
    Write-Host *_$_.pst1; Invoke-Expression ". .\*_$_.ps1"
}
Pop-Location

# Elevated
if (Test-IsAdmin){
    Write-Host "Administrator"
} else {
    # https://github.com/dahlbyk/posh-git
    try {
        $git = (git --version)
        Write-Host $git
        Import-Module posh-git
        Append-Path((Get-Item "Env:ProgramFiles").Value + "\Git\bin")
    } catch {
        Write-Host "Git not found, will install."
        # Install git using PowerShellGet (-gt PS2)
        If ($PSVersionTable.PSVersion.Major -gt 2) { 
            PowerShellGet\Install-Module posh-git -Scope CurrentUser
            Update-Module posh-git
        }
    }
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