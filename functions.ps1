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