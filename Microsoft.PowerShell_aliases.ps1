${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation

Set-Alias laps Get-Laps
Set-Alias reload Reload-Powershell