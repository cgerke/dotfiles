Set-Location (Resolve-Path .\).Path

#PowerShell Profile
$profileDir = Join-Path $env:USERPROFILE "\Documents\WindowsPowerShell"
if (![System.IO.Directory]::Exists($profileDir)) {
    [System.IO.Directory]::CreateDirectory($profileDir)
}

# PowerShell Modules
$modulesDir = Join-Path $env:USERPROFILE "\Documents\WindowsPowerShell\Modules"
if (![System.IO.Directory]::Exists($modulesDir)) {
    [System.IO.Directory]::CreateDirectory($modulesDir)
}
Copy-Item -Path ./Modules/* -Destination $modulesDir -recurse -Force
Copy-Item -Path ./*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"

# Git
Copy-Item -Path ./.gitconfig -Destination $env:USERPROFILE
