function script:Append-Path([string] $path ) {
    if ( -not [string]::IsNullOrEmpty($path) ) {
       if ( (Test-Path $path) -and (-not $env:PATH.contains($path)) ) {
           Write-Host "Appending Path" $path
          $env:PATH += ';' + "$path"
       }
    }
 }
 
 # Test if auto loading modules is available.
 function Get-PSVersion {
     if (Test-Path variable:psversiontable) {
         $psversiontable.psversion
     } else {
         return $false
     }
 }
 
 function Enable-FPS {
     netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
 }
 
 function Disable-FPS {
     netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=No
 }
 
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
 
 # function Get-PSVersion {
 #     if ($PSVersionTable.PSVersion.Major -lt 2) {
 #         Load-AD
 #     }
 # }; Get-PSVersion
 
 function Reload-Powershell {
     $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
     [System.Diagnostics.Process]::Start($newProcess);
     exit
 }

 function Get-FilePathLength($path) {
    (Get-Childitem -LiteralPath $path -Recurse) | 
    Where {$_.FullName.length -ge 248 } |
    Format-Table -Wrap @{Label='Path length';Expression={$_.FullName.length}}, FullName
 }
 
 function Get-WIFI($SSID) {
     (netsh wlan show profiles)
 } 
 function Remove-WIFI($SSID) {
  (netsh wlan delete profile name=$SSID)
 } 
 
 
 function Reset-SearchIndex {
     if (Test-Administrator) {
         Stop-Service Wsearch
         Start-Sleep -s 5
         dir C:\ProgramData\Microsoft\Search\Data\Applications\Windows\
         Rename-Item C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb Windows.edb.bak
         dir C:\ProgramData\Microsoft\Search\Data\Applications\Windows\
         Start-Sleep -s 5
         Start-Service Wsearch
         control /name Microsoft.IndexingOptions
 
         #Alternate
         #Push-Location
         #Set-Location HKLM:
         #Set-ItemProperty ".\SOFTWARE\Microsoft\Windows Search" -name "SetupCompletedSuccessfully" -Value 0 -PropertyType "DWord"
         #Pop-Location
 
     } else {
         Write-Host "Must be elevated."
     }
 }
 
 function Reset-Stack {
     if (Test-IsAdmin) {
         ipconfig /flushdns
         nbtstat -R
         nbtstat -RR
         netsh int ipv4 reset
         netsh int ipv6 reset
         netsh int ip reset
         netsh int tcp reset
         netsh winsock reset
     } else {
         Write-Host "Must be elevated."
     }
 }
 
 function Reset-Offline {
     Push-Location
     Set-Location HKLM:
     Set-ItemProperty ".\SYSTEM\CurrentControlSet\services\CSC\Parameters" -name "FormatDatabase" -Value 1 -PropertyType "DWord"
     Pop-Location
 }
 
 function Set-Power {
     # powercfg -L # to get the Available list of all Power Settings  schemes
     # powercfg -GETACTIVESCHEME
     #Existing Power Schemes (* Active)
     #-----------------------------------
     #Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
     #Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance) *
     #Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)
     $DesiredProfile = "Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance)".Split()
     $CurrentProfile = $(powercfg -GETACTIVESCHEME).Split()
     if ($CurrentProfile[3] -ne $DesiredProfile[3]) {
         powerCfg -SetActive $DesiredProfile[3]
     }
 }
 
 function Setup-SSH {
     # Test pipe
     #Get-WindowsCapability -Online | ? Name -like 'OpenSSH*' | Add-WindowsCapability -Online
     Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
 
     # Install the OpenSSH Client
     Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
 
     # Install the OpenSSH Server
     # Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
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
 
 function Test-ExecutionPolicy {
     if((Get-Executionpolicy) -eq 'RemoteSigned') {
         Write-Host "Relax with 'RemoteSigned' : Set-ExecutionPolicy RemoteSigned -scope CurrentUser"
     }
 }
 
 function Test-IsAdmin {
     $user = [Security.Principal.WindowsIdentity]::GetCurrent();
     (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
 }
 
 function Test-RegistryValue {
     param (
         [parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]$Path,
         [parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]$Value
     )
     
     try {
         Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
         return $true
     } catch {
         return $false
     }
 }
 
 function Get-Laps {
     param (
         [parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]$ComputerObject
     )
     
     try {
         Get-ADComputer $ComputerObject -Properties ms-Mcs-AdmPwd | select name, ms-Mcs-AdmPwd
     } catch {
         return $false
     }
 }
 Set-Alias laps Get-Laps
 
 function prompt {
     # https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt
     $origLastExitCode = $LastExitCode
     
     if (Test-IsAdmin) {  # if elevated
         Write-Host "(Elevated $env:USERNAME ) " -NoNewline -ForegroundColor Red
     } else {
         Write-Host "$env:USERNAME " -NoNewline -ForegroundColor Red
     }
 
     Write-Host "$env:COMPUTERNAME" -NoNewline -ForegroundColor Cyan
     Write-Host "" $ExecutionContext.SessionState.Path.CurrentLocation.Path -ForegroundColor Yellow
     $LastExitCode = $origLastExitCode
     "`n$('PS >') "
     Write-VcsStatus
 }