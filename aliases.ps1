${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation

Set-Alias reload Reload-Powershell
Set-Alias sudo Sudo-PowerShell