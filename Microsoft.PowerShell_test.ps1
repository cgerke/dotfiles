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

function Load-AD{
    # https://technet.microsoft.com/en-us/library/ee617234.aspx
    try {
        if(Get-Module -list activedirectory){
            if (Get-PSVersion){
                Import-Module ActiveDirectory
            }
        } else {
            Write-Host "Cannot Import Active Directory Module without RSAT Tools"
        }
    } catch {
        Write-Host "Cannot Import Active Directory Module"
    }
} 

function Test-DA {
    Write-Host "----------------------------------"
    Write-Host "Check IPv6 enabled Interfaces ===>"
    Write-Host "----------------------------------"
    netsh interface ipv6 show interface

    Write-Host "------------------------------------------------------------"
    Write-Host "Determine if the client is inside or outside of network ===>"
    Write-Host "------------------------------------------------------------"
    netsh dnsclient show state

    Write-Host "--------------------------------------------------------"
    Write-Host "DirectAccess status and general configuration state ===>"
    Write-Host "--------------------------------------------------------"
    netsh dns show state

    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "Name Resolution Policy Table (NRPT) that has been defined within Group Policy. ===>"
    Write-Host "-----------------------------------------------------------------------------------"
    netsh namespace show policy

    Write-Host "-----------------------------------------------------------------------------"
    Write-Host "Actual NRPT entries that are currently active on the DirectAccess client ===>"
    Write-Host "-----------------------------------------------------------------------------"
    netsh namespace show effectivepolicy

    Write-Host "------------------------------------------------------------------------"
    Write-Host "The current status of the IP-HTTPS interface, if used at that time. ===>"
    Write-Host "------------------------------------------------------------------------"
    netsh interface httpstunnel show interfaces

    Write-Host "------------------------------------------------------------------------------"
    Write-Host "The current status and configuration state of the local Windows Firewall. ===>"
    Write-Host "------------------------------------------------------------------------------"
    netsh advfirewall monitor show firewall

    Write-Host "------------------------------------------------------------------------------"
    Write-Host "Show the current Windows Firewall profile that is in use. ===>"
    Write-Host "------------------------------------------------------------------------------"
    netsh advfirewall show currentprofile

    if (Test-IsAdmin) {
        Write-Host "-------------------------------------------------------------------------------------"
        Write-Host "Current status of the Windows Firewall main mode security associations that are"
        Write-Host "present when DirectAccess infrastructure and intranet IPsec tunnels are active.. ===>"
        Write-Host "-------------------------------------------------------------------------------------"
        netsh advfirewall monitor show mmsa

        Write-Host "-------------------------------------------------------------------------------------"
        Write-Host "Current status of the Windows Firewall connection security rules which are used to "
        Write-Host "define the DirectAccess infrastructure and intranet IPsec tunnels."
        Write-Host "-------------------------------------------------------------------------------------"
        netsh advfirewall monitor show consec
    }

    # Check Direct Access connection security rules thru Windows Firewall Advance Security Settings > Connection Security Rules (should be 4)
    # Wf.msc

    # Check current Windows Security Associations (while successfully connected to Direct Access).
    # Windows Firewall Advance Security Main Mode Monitoring > Security Associations or use use "netsh advfirewall monitor show mmsa"
}