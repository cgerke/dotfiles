<# Preferences #>
$DebugPreference = "SilentlyContinue"

<# Aliases / 1liners #>
${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:Get-Sudo} = { Start-Process powershell -ArgumentList "-executionpolicy bypass" -Verb RunAs }

<# PATH #>
function Set-EnvPath([string] $path ) {
    if ( -not [string]::IsNullOrEmpty($path) ) {
       if ( (Test-Path $path) -and (-not $env:PATH.contains($path)) ) {
           Write-Host "Updating PATH" $path -ForegroundColor Cyan
          $env:PATH += ';' + "$path"
       }
    }
 }

<# Prompt #>
function prompt {
    # https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt
    $origLastExitCode = $LastExitCode
    Write-Host "Profile : $profile"
    Write-Host "Execution Policy: " (Get-ExecutionPolicy)

    if (Get-GitStatus){
        if (Get-Command git -TotalCount 1 -ErrorAction SilentlyContinue) {
            Set-EnvPath((Get-Item "Env:ProgramFiles").Value + "\Git\bin")
            Write-Host (git --version) -ForegroundColor Cyan
        }
    }

    if (Test-IsAdmin) {  # if elevated
        Write-Host "(Elevated $env:USERNAME ) " -NoNewline -ForegroundColor Red
    } else {
        Write-Host "$env:USERNAME " -NoNewline
    }

    Write-Host "$env:COMPUTERNAME " -NoNewline -ForegroundColor Magenta
    Write-Host $ExecutionContext.SessionState.Path.CurrentLocation -ForegroundColor Yellow -NoNewline
    Write-VcsStatus
    $LASTEXITCODE = $origLastExitCode
    "`n`n$('PS>' * ($nestedPromptLevel + 1)) "
}

<# Notes #>
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

# . Source 
<# Push-Location (Split-Path -parent $profile)
"test" | Where-Object {Test-Path "Microsoft.PowerShell_$_.ps1"} | ForEach-Object -process {
    Invoke-Expression ". .\Microsoft.PowerShell_$_.ps1"; Write-Host Microsoft.PowerShell_$_.ps1
}
Pop-Location #>

<# MOVE TO MODULES #>
# Report file/path length issues
function Get-FilePathLength($path) {
    (Get-Childitem -LiteralPath $path -Recurse) | 
    Where-Object {$_.FullName.length -ge 248 } |
    Format-Table -Wrap @{Label='Path length';Expression={$_.FullName.length}}, FullName
 }

# Test elevation
function Test-IsAdmin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
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

# LAPS helpers
# Module this http://www.tomsitpro.com/articles/powershell-modules,2-846.html
Set-Alias laps Get-LAPS
function Get-LAPS {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$ComputerObject
    )
    
    try {
        Get-ADComputer $ComputerObject -Properties ms-Mcs-AdmPwd | Select-Object name, ms-Mcs-AdmPwd
    } catch {
        return $false
    }
}

function Get-LAPSExpiry{
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$ComputerName
    )

    $PwdExp = Get-ADComputer $ComputerName -Properties ms-MCS-AdmPwdExpirationTime
    $([datetime]::FromFileTime([convert]::ToInt64($PwdExp.'ms-MCS-AdmPwdExpirationTime',10)))
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

# Support helpers
function Get-Remote {
    Start-Process C:\Windows\CmRcViewer.exe
}



# Non-policy account
function Get-NonPolicy {
    $thisDomain = (Get-WmiObject Win32_ComputerSystem).Domain
    runas /user:$thisDomain\cgerke "powershell.exe -executionpolicy bypass"
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
