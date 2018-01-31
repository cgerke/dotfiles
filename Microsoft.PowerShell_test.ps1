# https://blogs.technet.microsoft.com/heyscriptingguy/2012/05/21/understanding-the-six-powershell-profiles/

# Execution Policy - play with alternatives
## Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
# powershell.exe -ExecutionPolicy Bypass -File .runme.ps1
# powershell.exe -command "Write-Host 'My voice is my passport, verify me.'"
# Get-Content .runme.ps1 | powershell.exe -noprofile -

# TODOs
# runas /user:<localmachinename>\administrator cmd
# psexec \\<localmachine> -u <localmachine>\Administrator -p <PASSWORD> /accepteula cmd /c "powershell -noninteractive -command gci c:\"
# Get software remote computer
# psexec \\<localmachine> -u <localmachine>\Administrator -p <PASSWORD> /accepteula cmd /c "powershell -noninteractive -command Get-WmiObject -Class Win32_Product"

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
