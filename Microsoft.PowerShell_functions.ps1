function script:Append-Path([string] $path ) {
   if ( -not [string]::IsNullOrEmpty($path) ) {
      if ( (Test-Path $path) -and (-not $env:PATH.contains($path)) ) {
          Write-Host "Appending Path" $path
         $env:PATH += ';' + "$path"
      }
   }
}

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

# function Set-AD{
#     # https://technet.microsoft.com/en-us/library/ee617234.aspx
#     try {
#         if(Get-Module -list activedirectory){
#             Import-Module ActiveDirectory
#         } else {
#             Write-Host "Cannot Import Active Directory Module without RSAT Tools"
#         }
#     } catch {
#         Write-Host "Cannot Import Active Directory Module"
#     }
# } 

function Reload-Powershell {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

function Test-ExecutionPolicy {
    if((Get-Executionpolicy) -eq 'RemoteSigned') {
        Write-Host "Relax with 'RemoteSigned' : Set-ExecutionPolicy RemoteSigned -scope CurrentUser"
    }
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