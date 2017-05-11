function script:Append-Path([string] $path ) {
   if ( -not [string]::IsNullOrEmpty($path) ) {
      if ( (test-path $path) -and (-not $env:PATH.contains($path)) ) {
          Write-Host "Appending Path" $path
         $env:PATH += ';' + "$path"
      }
   }
}

function Set-AD{
    # https://technet.microsoft.com/en-us/library/ee617234.aspx
    try {
        if(Get-Module -list activedirectory){
            Import-Module ActiveDirectory
        } else {
            Write-Host "Cannot Import Active Directory Module without RSAT Tools"
        }
    } catch {
        Write-Host "Cannot Import Active Directory Module"
    }
}

function Reload-Powershell {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

function Sudo-PowerShell {
    if ($args.Length -eq 1) {
        start-process $args[0] -verb "runAs"
        write-host 'ok'
    }
    if ($args.Length -gt 1) {
        start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
    }
}

function Test-ExecutionPolicy {
    if((Get-Executionpolicy) -eq 'RemoteSigned') {
        Write-Host "Relax with 'RemoteSigned' : Set-ExecutionPolicy RemoteSigned -scope CurrentUser"
    }
}

function Test-IsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent();
        $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
        return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
    }

    <#
        .SYNOPSIS
            Checks if the current Powershell instance is running with elevated privileges or not.
        .EXAMPLE
            PS C:\> Test-IsAdmin
        .OUTPUTS
            System.Boolean
                True if the current Powershell is elevated, false if not.
    #>
}

function prompt {
    # https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt
    $origLastExitCode = $LastExitCode
    
    if (Test-IsAdmin) {  # if elevated
        Write-Host "(Elevated $env:USERNAME ) " -NoNewline -ForegroundColor Red
    } else {
        Write-Host "$env:USERNAME " -NoNewline -ForegroundColor DarkYellow
    }

    Write-Host "$env:COMPUTERNAME" -NoNewline -ForegroundColor Cyan
    Write-Host " " $ExecutionContext.SessionState.Path.CurrentLocation.Path -ForegroundColor Blue
    $LastExitCode = $origLastExitCode
    "`n$('PS >') "

    Write-VcsStatus
}