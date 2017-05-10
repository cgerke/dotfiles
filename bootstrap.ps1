Set-Location (Resolve-Path .\).Path

#PowerShell Profile
$profileDir = Join-Path $env:USERPROFILE "\Documents\WindowsPowerShell"
if (![System.IO.Directory]::Exists($profileDir)) {
    Write-Host "Creating " $profileDir
    [System.IO.Directory]::CreateDirectory($profileDir)
} else {
    Write-Host "$profileDir exists."
}

# PowerShell Modules
$modulesDir = Join-Path $env:USERPROFILE "\Documents\WindowsPowerShell\Modules"
if (![System.IO.Directory]::Exists($modulesDir)) {
    Write-Host "Creating " $modulesDir
    [System.IO.Directory]::CreateDirectory($modulesDir)
} else {
    Write-Host "$modulesDir exists."
}

if (test-path ./Modules){
    Write-Host "Copy ./Modules to " $modulesDir
    Copy-Item -Path ./Modules/* -Destination $modulesDir -recurse -Force
} else {
    Write-Host "./Modules not available."
}

Write-Host "Copying ./Microsoft.PowerShell_*.ps1 to " $profileDir
Copy-Item -Path ./Microsoft.PowerShell_*.ps1 -Destination $profileDir

# Git
Write-Host "Copying ./.gitconfig to " $env:USERPROFILE
Copy-Item -Path ./.gitconfig -Destination $env:USERPROFILE
