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

# Sublime
$sublimeDir = Join-Path $env:USERPROFILE "\AppData\Roaming\Sublime Text 3"
Copy-Item -Path ./sublime -Destination $sublimeDir -recurse -Force

# Git
Copy-Item -Path ./.gitconfig -Destination $env:USERPROFILE