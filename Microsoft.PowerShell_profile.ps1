# Preferences
$DebugPreference = "SilentlyContinue"

<# Helpers #>

# Log ALL THE THINGS! well some of them.
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    "PowerShell exited at {0}" -f (Get-Date) | 
        Out-File -FilePath "C:\temp\powershell.log" -Append
    Get-History | 
        Out-File -FilePath "C:\temp\powershell.log" -Append
}

# Append paths to the env PATH
function Set-EnvPath([string] $path ) {
    if ( -not [string]::IsNullOrEmpty($path) ) {
       if ( (Test-Path $path) -and (-not $env:PATH.contains($path)) ) {
           Write-Host "Appending Path" $path -ForegroundColor Cyan
          $env:PATH += ';' + "$path"
       }
    }
 }

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
"aliases","organisation","test" | Where-Object {Test-Path "Microsoft.PowerShell_$_.ps1"} | ForEach-Object -process {
    Invoke-Expression ". .\Microsoft.PowerShell_$_.ps1"; #Write-Host Microsoft.PowerShell_$_.ps1
}
Pop-Location

<# Get Modules #>
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

# LAPS helpers
function Get-AdmPwd {
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

function Get-AdmPwdExpiry{
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

<# HUD #>
Write-Host "Execution Policy: " (Get-ExecutionPolicy)
Write-Host "Profile : " $profile

# Prompt
function prompt {
    # https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt
    $origLastExitCode = $LastExitCode

    if (Get-GitStatus){
        if (Get-Command git -TotalCount 1 -ErrorAction SilentlyContinue) {
            Write-Host (git --version) -ForegroundColor Cyan
            Set-EnvPath((Get-Item "Env:ProgramFiles").Value + "\Git\bin")
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
    "`n$('PS>' * ($nestedPromptLevel + 1)) "
}
