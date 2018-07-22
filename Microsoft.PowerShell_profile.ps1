
<# Preferences #>
$DebugPreference = "SilentlyContinue" # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" # Support TLS

<# Alias / 1-Liner #>
${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:Reload-Powershell} = { & $profile }
${function:Get-Sudo} = { Start-Process powershell -ArgumentList "-executionpolicy bypass" -Verb RunAs }

<# PATH #>
function Set-EnvPath([string] $path ) {
    if ( -not [string]::IsNullOrEmpty($path) ) {
        if ( (Test-Path $path) -and (-not $env:PATH.contains($path)) ) {
            #Write-Host "PATH" $path -ForegroundColor Cyan
            $env:PATH += ';' + "$path"
       }
    }
 }

<# Profile Helpers #>
 function Test-IsAdmin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
<# End Profile Helpers #>

<# . Source #> 
Push-Location (Split-Path -parent $profile)
"organisation" | Where-Object {Test-Path "Microsoft.PowerShell_$_.ps1"} | ForEach-Object -process {
    Invoke-Expression ". .\Microsoft.PowerShell_$_.ps1"; Write-Host Microsoft.PowerShell_$_.ps1
}
Pop-Location
<# End . Source #>

<# Support Helpers #>
function Get-LAPS {
    <#
    .SYNOPSIS
    https://technet.microsoft.com/en-us/mt227395.aspx
    .DESCRIPTION
    Query Active Directory for the local administrator password of a ComputerObj.
    .EXAMPLE
    Get-LAPS -ComputerObj mycomputer-1
    .PARAMETER ComputerObj
    The computer name to query. Just one.
    #>
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]$ComputerObj
    )
    
    try {
        Get-ADComputer $ComputerObj -Properties ms-Mcs-AdmPwd | Select-Object name, ms-Mcs-AdmPwd
    } catch {
        return $false
    }
}; Set-Alias laps Get-LAPS

function Get-LAPSExpiry{
    <#
    .SYNOPSIS
    https://technet.microsoft.com/en-us/mt227395.aspx
    .DESCRIPTION
    Query Active Directory for the local administrator password expiry date for a ComputerObj.
    .EXAMPLE
    Get-LAPSExpiry -ComputerObj mycomputer-1
    .PARAMETER ComputerObj
    The computer name to query. Just one.
    #>
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$ComputerObj
    )

    $PwdExp = Get-ADComputer $ComputerObj -Properties ms-MCS-AdmPwdExpirationTime
    $([datetime]::FromFileTime([convert]::ToInt64($PwdExp.'ms-MCS-AdmPwdExpirationTime',10)))
}

function Get-PowershellAs {
    <#
    .SYNOPSIS
    Run a powershell process as a specified user.
    .DESCRIPTION
    Run a powershell process as a specified user, typically an AD non-policy or elevated permissions account.
    .EXAMPLE
    Get-PowershellAs -UserObj myuser
    .PARAMETER UserObj
    The user name to "run as"
    #>
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]$UserObj
    )
    $DomainObj = (Get-WmiObject Win32_ComputerSystem).Domain
    if ( $DomainObj -eq 'WORKGROUP' ){
        $DomainObj = (Get-WmiObject Win32_ComputerSystem).Name
    }
    runas /user:$DomainObj\$UserObj "powershell.exe -executionpolicy bypass"
}; Set-Alias pa Get-PowershellAs
<# End Support Helpers #>

<# Prompt #>
function prompt {
    # https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt
    $origLastExitCode = $LastExitCode
    Write-Host "Profile : $profile :"(Get-ExecutionPolicy)

    if (Get-GitStatus){
        if (Get-Command git -TotalCount 1 -ErrorAction SilentlyContinue) {
            Set-EnvPath((Get-Item "Env:ProgramFiles").Value + "\Git\bin")
            Write-Host (git --version) -ForegroundColor Cyan
        }
    }

    if (Test-IsAdmin) {  # if elevated
        Write-Host "(Elevated $env:USERNAME ) " -NoNewline -ForegroundColor Red
    } else {
        Write-Host "$env:USERNAME " -NoNewline -ForegroundColor Blue
    }

    Write-Host "$env:COMPUTERNAME " -NoNewline -ForegroundColor DarkCyan
    Write-Host $ExecutionContext.SessionState.Path.CurrentLocation -ForegroundColor Cyan -NoNewline
    Write-VcsStatus
    $LASTEXITCODE = $origLastExitCode
    "`n`n$('PS>' * ($nestedPromptLevel + 1)) "
}

<# Notes #>

# Build a better function
# https://technet.microsoft.com/en-us/library/hh360993.aspx?f=255&MSPPError=-2147217396

# Research ways of using execution policy
# Set-ExecutionPolicy RemoteSigned -scope CurrentUser

# Logging example
<# Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    "PowerShell exited at {0}" -f (Get-Date) | 
        Out-File -FilePath "C:\temp\powershell.log" -Append
    Get-History | 
        Out-File -FilePath "C:\temp\powershell.log" -Append
} #>

# Importing modules
<# $ProfilePath = split-path -parent $PROFILE
$Modules = @("posh-git", "PSPath", "PSSudo")
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
} #>

<#  # Test auto loading modules
function Test-PSVersion {
    if (Test-Path variable:psversiontable) {
        Write-Output "Auto loading modules will be available."
        $psversiontable.psversion
    } else {
        Write-Output "Auto loading modules won't be available."
        return $false
    }
} #>

<# Download GIT
function Get-GitCurrentRelease() {
    [cmdletbinding()]
    Param(
        [ValidateNotNullorEmpty()]
        [string]$Uri = "https://api.github.com/repos/git-for-windows/git/releases/latest"
    )
    
    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"  
    
    } #begin
    
    Process {
        Write-Verbose "[PROCESS] Getting current release information from $uri"
        $data = Invoke-Restmethod -uri $uri -Method Get
    
        
        if ($data.tag_name) {
            [pscustomobject]@{
                Name = $data.name
                Version = $data.tag_name
                Released = $($data.published_at -as [datetime])
            }
        } 
    } #process
 
    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end
    
    # Download the latest 64bit version of Git for Windows
    $uri = 'http://git-scm.com/download/win'
    #path to store the downloaded file
    $path = $env:temp
    
    # get the web page
    $page = Invoke-WebRequest -Uri $uri -UseBasicParsing
    
    #get the download link
    $dl = ($page.links | where outerhtml -match 'git-.*-64-bit.exe' | select -first 1 * ).href
    
    #split out the filename
    $filename = split-path $dl -leaf
    
    #construct a filepath for the download
    $out = Join-Path -Path $path -ChildPath $filename
    
    #download the file
    Invoke-WebRequest -uri $dl -OutFile $out -UseBasicParsing
    
    #check it out
    Get-item $out
 
} #>

<# MOVE TO HELPERS #>

function Get-FilePathLength($path) {
    (Get-Childitem -LiteralPath $path -Recurse) | 
    Where-Object {$_.FullName.length -ge 248 } |
    Format-Table -Wrap @{Label='Path length';Expression={$_.FullName.length}}, FullName
 }
# AD helpers
function Get-ADMemberCSV {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$GroupObject
    )
    
    try {
        Get-ADGroupMember "$GroupObject" | Export-CSV -path "c:\temp\$GroupObject.csv"
        explorer c:\temp
    } catch {
        return $false
    }
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

function Get-Remote {
    Start-Process C:\Windows\CmRcViewer.exe
}

function Get-Uptime {
    (Get-Date)-(Get-CimInstance Win32_OperatingSystem).lastbootuptime | Format-Table
}

# Bootstrap
function Set-BootStrap {
    Set-BootstrapOrg
    
    # SSH
    # Test pipe
    Get-WindowsCapability -Online | ? Name -like 'OpenSSH.Client*' | Add-WindowsCapability -Online
    # Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

    # Install the OpenSSH Client
    #Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

    # Install the OpenSSH Server
    # Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    
    # Set IE
    Set-Location HKCU:
    New-Item -Path ".\Software\Microsoft\Internet Explorer" -Name "ContinuousBrowsing"
    New-ItemProperty ".\Software\Microsoft\Internet Explorer\ContinuousBrowsing" -Name "Enabled" -Value 1 -PropertyType "DWord"
    Set-ItemProperty ".\Software\Microsoft\Internet Explorer\ContinuousBrowsing" -Name "Enabled" -Value 1

    # Set Run
    Set-Location HKCU:
    Remove-Item '.\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU'
    New-Item -Path ".\Software\Microsoft\Windows\CurrentVersion\Explorer\" -Name "RunMRU"
    New-ItemProperty ".\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "MRUList" -Value "ab" -PropertyType "String"
    New-ItemProperty ".\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "a" -Value "powershell.exe -executionpolicy remotesigned\1" -PropertyType "String"
    New-ItemProperty ".\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" -Name "b" -Value "powershell.exe -executionpolicy bypass -command ""start-process powershell -ArgumentList '-ExecutionPolicy Bypass' -Verb Runas""\1" -PropertyType "String"    
}


# Reminders
function Get-evtx {
    wevtutil epl application c:\temp\application.evtx
}

function Get_Health {
    DISM /Online /Cleanup-Image /CheckHealth
    DISM /Online /Cleanup-Image /ScanHealth
    DISM /Online /Cleanup-Image /RestoreHealth
}

function Get-MSIProdCode {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$MSIName
    )
    
    try {
        if ( $MSIName = "All" ) {
            get-wmiobject Win32_Product | Format-Table IdentifyingNumber, Name
        } else {
            get-wmiobject Win32_Product | Where-Object {$_.Name -Like "*$MSIName*"}
        }
        
    } catch {
        return $false
    }
}

# Documentation
function Get-Documentation {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$DocName
    )
    
    try {
        Import-Csv "$PSDIR\$DocName.csv" | Format-Table
    } catch {
        Write-Host "No such document."
        return $false
    }
    
}

function Set-Documentation {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$DocName
    )
    
    try {
        explorer "$PSDIR\$DocName.csv"
    } catch {
        Write-Host "No such document."
        return $false
    }
    
}

function Get-Log {
    try {
        notepad "$PSDIR\log.txt"
    } catch {
        return $false
    }
    
}

