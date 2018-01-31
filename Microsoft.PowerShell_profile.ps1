# Preferences
$DebugPreference = "SilentlyContinue"

<# Helper Functions #>

# Append paths to the env PATH
function Append-Path([string] $path ) {
    if ( -not [string]::IsNullOrEmpty($path) ) {
       if ( (Test-Path $path) -and (-not $env:PATH.contains($path)) ) {
           Write-Host "Appending Path" $path
          $env:PATH += ';' + "$path"
       }
    }
 }

 # File sharing helpers
 function Enable-FPS {
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
}

function Disable-FPS {
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=No
}

# Report file/path length issues
function Get-FilePathLength($path) {
    (Get-Childitem -LiteralPath $path -Recurse) | 
    Where {$_.FullName.length -ge 248 } |
    Format-Table -Wrap @{Label='Path length';Expression={$_.FullName.length}}, FullName
 }

# LAPS password finder
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

 # Wifi helpers
function Get-WIFI($SSID) {
    (netsh wlan show profiles)
} 
function Remove-WIFI($SSID) {
   (netsh wlan delete profile name=$SSID)
} 

 # Reload ps on-demand
 function Reload-Powershell {
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

# Setup openshh. Test this, make it smarter
function Setup-SSH {
    # Test pipe
    #Get-WindowsCapability -Online | ? Name -like 'OpenSSH*' | Add-WindowsCapability -Online
    Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'

    # Install the OpenSSH Client
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

    # Install the OpenSSH Server
    # Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
}

# Test elevation
function Test-IsAdmin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Test execution policy
function Test-ExecutionPolicy {
    if((Get-Executionpolicy) -eq 'RemoteSigned') {
        Write-Host "Maybe relax with 'RemoteSigned' : Set-ExecutionPolicy RemoteSigned -scope CurrentUser"
    }
}

 # Test auto loading modules
function Test-PSVersion {
    if (Test-Path variable:psversiontable) {
        Write-Output "Auto loading modules will be available."
        $psversiontable.psversion
    } else {
        Write-Output "Auto loading modules won't be available."
        return $false
    }
}

# Test reg values
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

<# dot source #>
Push-Location (Split-Path -parent $profile)
"functions","aliases","organisation" | Where-Object {Test-Path "Microsoft.PowerShell_$_.ps1"} | ForEach-Object -process {
    Invoke-Expression ". .\Microsoft.PowerShell_$_.ps1"; #Write-Host Microsoft.PowerShell_$_.ps1
}
Pop-Location

<# Modules #>
$ProfilePath = split-path -parent $PROFILE
#$Modules = @("posh-git", "PSPath", "PSSudo")
if($Modules -ne $null) {
    foreach ($Module in $Modules) {
        if (!(Test-Path $ProfilePath\Modules\$Module)) {
            Write-Host "Installing module $Module"; PowerShellGet\Install-Module $Module -Scope CurrentUser
        }
        if (Get-Module -ListAvailable -Name $Module) {
            Write-Host "Importing module $Module"; Import-Module $Module
        }
    }

    # Maybe check its imported?
    Set-PSReadlineOption -EditMode Emacs
}

<# Manually loading modules. Legacy to be removed. #>
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

<# HUD #>
# Git https://github.com/dahlbyk/posh-git
if (Get-Command git -TotalCount 1 -ErrorAction SilentlyContinue) {
    Write-Host (git --version); Append-Path((Get-Item "Env:ProgramFiles").Value + "\Git\bin")
}

# Profile
Write-Host "Execution Policy: " (Get-ExecutionPolicy)
Write-Host "Profile : " $profile

# Prompt
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
