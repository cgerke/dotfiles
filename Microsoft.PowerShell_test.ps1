<# these should be modules dude, write em! #>
function Get-CheatSheet {
    param (
        [Parameter(Mandatory=$true,HelpMessage="`t Get-Module -ListAvailable for parameters...")]
	    [ValidateNotNullOrEmpty()]$ModuleName
    )
    
    try {
    # adjust the name of the module
    # code will list all commands shipped by that module
    # list of all modules: Get-Module -ListAvailable
    # $ModuleName = "PrintManagement"
    $Title = "$ModuleName Commands"
    $OutFile = "$env:temp\commands.html"
$StyleSheet = @"
<title>$Title</title>
<style>
h1, th { text-align: center; font-family: Segoe UI; color:#0046c3;}
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
    $Header = "<h1 align='center'>$title</h1>"
    Get-Command -Module $moduleName | 
    Get-Help | 
    Select-Object -Property Name, Synopsis |
    ConvertTo-Html -Title $Title -Head $StyleSheet -PreContent $Header |
    Set-Content -Path $OutFile
    Invoke-Item -Path $OutFile

    } catch {
        Get-Module -ListAvailable

    }
}

function Reset-Google {
    If (Test-Path 'HKCU:\Software\Policies\Google') {
        sudo Remove-Item -Path "HKCU:\Software\Policies\Google" -Confirm
    }
}

# File sharing helpers
 function Enable-FPS {
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
}

function Disable-FPS {
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=No
}

# Mailbox stats
function Get-MailStats {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$UserObject
    )
    
    try {
        Get-MailboxFolderStatistics -Identity $UserObject | Select-Object identity,name,foldersize,FolderAndSubfolderSize,itemsinfolder | Export-Csv c:\temp\$UserObject.csv -NoTypeInformation
    } catch {
        return $false
    }
}

# Formatted network stats
# Example : Get-NetworkStatistics | Where-Object {$_.ProcessName -eq 'CiscoJabber'} | Format-Table
function Get-NetworkStatistics
{ 
    $properties = 'Protocol','LocalAddress','LocalPort' 
    $properties += 'RemoteAddress','RemotePort','State','ProcessName','PID'

    netstat -ano | Select-String -Pattern '\s+(TCP|UDP)' | ForEach-Object {

        $item = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)

        if($item[1] -notmatch '^\[::') 
        {            
            if (($la = $item[1] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') 
            { 
               $localAddress = $la.IPAddressToString 
               $localPort = $item[1].split('\]:')[-1] 
            } 
            else 
            { 
                $localAddress = $item[1].split(':')[0] 
                $localPort = $item[1].split(':')[-1] 
            } 

            if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') 
            { 
               $remoteAddress = $ra.IPAddressToString 
               $remotePort = $item[2].split('\]:')[-1] 
            } 
            else 
            { 
               $remoteAddress = $item[2].split(':')[0] 
               $remotePort = $item[2].split(':')[-1] 
            } 

            New-Object PSObject -Property @{ 
                PID = $item[-1] 
                ProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name 
                Protocol = $item[0] 
                LocalAddress = $localAddress 
                LocalPort = $localPort 
                RemoteAddress =$remoteAddress 
                RemotePort = $remotePort 
                State = if($item[0] -eq 'tcp') {$item[3]} else {$null} 
            } | Select-Object -Property $properties 
        } 
    } 
}

 # Wifi helpers
function Get-WIFI($SSID) {
    (netsh wlan show profiles)
} 
function Remove-WIFI($SSID) {
   (netsh wlan delete profile name=$SSID)
} 

# Reload ps on-demand
function Restart-Powershell {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

# Reset offline files database
function Reset-Offline {
    Push-Location
    Set-Location HKLM:
    Set-ItemProperty ".\SYSTEM\CurrentControlSet\services\CSC\Parameters" -name "FormatDatabase" -Value 1 -PropertyType "DWord"
    Pop-Location
}

# Reset windows search index
function Reset-SearchIndex {
    if (Test-Administrator) {
        Stop-Service Wsearch
        Start-Sleep -s 5
        Get-ChildItem C:\ProgramData\Microsoft\Search\Data\Applications\Windows\
        Rename-Item C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb Windows.edb.bak
        Get-ChildItem C:\ProgramData\Microsoft\Search\Data\Applications\Windows\
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

# Reset network stack
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

 # Set power profile
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


<# Implicit Remoting
Use tools without installing or modifying the local workstation by
importing a session from a host that has them. Needs testing.
#>
function Get-ImplicitModule($endpoint, $module) {
    $endpointsession=New-PSSession -ComputerName $endpoint
    Import-PSSession -Session $endpointsession -Module $module
}

function Get-Ping
{
    param
    (
        # make parameter pipeline-aware
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]]
        $ComputerName,
        $TimeoutMillisec = 1000
    )

    begin
    {
        # use this to collect computer names that were sent via pipeline
        [Collections.ArrayList]$bucket = @()
    
        # hash table with error code to text translation
        $StatusCode_ReturnValue = 
        @{
            0='Success'
            11001='Buffer Too Small'
            11002='Destination Net Unreachable'
            11003='Destination Host Unreachable'
            11004='Destination Protocol Unreachable'
            11005='Destination Port Unreachable'
            11006='No Resources'
            11007='Bad Option'
            11008='Hardware Error'
            11009='Packet Too Big'
            11010='Request Timed Out'
            11011='Bad Request'
            11012='Bad Route'
            11013='TimeToLive Expired Transit'
            11014='TimeToLive Expired Reassembly'
            11015='Parameter Problem'
            11016='Source Quench'
            11017='Option Too Big'
            11018='Bad Destination'
            11032='Negotiating IPSEC'
            11050='General Failure'
        }
    
    
        # hash table with calculated property that translates
        # numeric return value into friendly text
        $statusFriendlyText = @{
            # name of column
            Name = 'Status'
            # code to calculate content of column
            Expression = { 
                # take status code and use it as index into
                # the hash table with friendly names
                # make sure the key is of same data type (int)
                if ($_.StatusCode -eq $null) {
                    "Null StatusCode"
                }
                else {
                    $StatusCode_ReturnValue[([int]$_.StatusCode)]
                }
            }
        }

        # Calculated property that returns $true when status -eq 0
        $IsOnline = @{
            Name = 'Online'
            Expression = { $_.StatusCode -eq 0 }
        }

        # do DNS resolution when system responds to ping
        $DNSName = @{
            Name = 'DNSName'
            Expression = { if ($_.StatusCode -eq 0) { 
                    if ($_.Address -like '*.*.*.*') 
                    { [Net.DNS]::GetHostByAddress($_.Address).HostName  } 
                    else  
                    { [Net.DNS]::GetHostByName($_.Address).HostName  } 
                }
            }
        }
    }
    
    process
    {
        # add each computer name to the bucket
        # we either receive a string array via parameter, or 
        # the process block runs multiple times when computer
        # names are piped
        $ComputerName | ForEach-Object {
            $null = $bucket.Add($_)
        }
    }
    
    end
    {
        # convert list of computers into a WMI query string
        $query = $bucket -join "' or Address='"
        
        Get-WmiObject -Class Win32_PingStatus -Filter "(Address='$query') and timeout=$TimeoutMillisec" |
        Select-Object -Property Address, $IsOnline, $DNSName, $statusFriendlyText
    }
}

<# Bootstrap #>
function Set-Bootstrap{
    #Windows Registry Editor Version 5.00
    #
    #[HKEY_CURRENT_USER\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
    #"ShowSecondsInSystemClock"=dword:00000001
    Push-Location
    Set-Location HKCU:
    New-ItemProperty ".\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name "ShowSecondsInSystemClock" -Value 1 -PropertyType "DWord"
    Set-ItemProperty ".\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name "ShowSecondsInSystemClock" -Value 1
    Pop-Location

    #Windows Registry Editor Version 5.00
    #
    #[HKEY_CURRENT_USER\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
    #"ShowSecondsInSystemClock"=dword:00000001
    Push-Location
    Set-Location HKLM:
    New-ItemProperty ".\Software\Microsoft\Windows\CurrentVersion\Explorer" -name "drivelettersfirst" -Value 1 -PropertyType "DWord"
    Set-ItemProperty ".\Software\Microsoft\Windows\CurrentVersion\Explorer" -name "drivelettersfirst" -Value 1
    Pop-Location
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

<#
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

#>

Function Set-FileTime
{
    Param (
        [Parameter(mandatory=$true)]
        [string[]]$path,
        [Parameter(mandatory=$true)]
        [datetime]$date = (Get-Date)
    )

    Get-ChildItem -Path $path |

    ForEach-Object {
        $_.CreationTime = $date
        $_.LastWriteTime = $date
    }
}
