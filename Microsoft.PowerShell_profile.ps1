If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] “Administrator”))
{
    Write-Warning “You are not running with Administrator rights!”
    Write-Host ""
    Get-ExecutionPolicy
    Write-Host $profile
} else {
    $Host.UI.RawUI.ForegroundColor = "Red"
    Set-ExecutionPolicy RemoteSigned
}

Push-Location (Split-Path -parent $profile)
"functions","aliases" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location

# Git
If ($PSVersionTable.PSVersion.Major -gt 2) { 
    . (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
    . $env:github_posh_git\profile.example.ps1
}
$GitPath = Get-ChildItem -Recurse -Force "C:\Users\cgerke\AppData\Local\GitHub" -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $true) -and  ( $_.Name -like "*cmd*") } | % { $_.fullname }
$env:Path += ";$GitPath"