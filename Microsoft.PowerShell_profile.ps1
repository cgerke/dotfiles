
<# Preferences #>
$DebugPreference = "SilentlyContinue" # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" # Support TLS

<# Globals #>
$PSDirectory = (Get-Item $profile).DirectoryName

<# Alias / 1-Liner #>
${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:Reload-Powershell} = { & $profile }
${function:Get-Sudo} = { Start-Process powershell -ArgumentList "-executionpolicy bypass" -Verb RunAs }

<# PATH #>
function Set-EnvPath([string] $path ) {
    if ( -not [string]::IsNullOrEmpty($path) ) {
        if ( (Test-Path $path) -and (-not $env:PATH.contains($path)) ) {
            #Write-Host "PATH" $path -ForegroundColor Cyan
            $env:PATH += ';' + "$path"
       }
    }
 }

<# Profile Helpers #>
function Get-Profile {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/cgerke/dotfiles/master/Microsoft.PowerShell_profile.ps1" -OutFile "$profile"
}

function Restart-Powershell {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    [System.Diagnostics.Process]::Start($newProcess);
    exit
}

 function Test-IsAdmin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

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
<# End Profile Helpers #>

<# . Source #>
Push-Location (Split-Path -parent $profile)
"organisation" | Where-Object {Test-Path "Microsoft.PowerShell_$_.ps1"} | ForEach-Object -process {
    Invoke-Expression ". .\Microsoft.PowerShell_$_.ps1"; Write-Host Microsoft.PowerShell_$_.ps1
}
Pop-Location
<# End . Source #>

<# Support Helpers #>
function Get-ADMemberCSV {
    <#
    .SYNOPSIS
    Export AD group members to CSV.
    .DESCRIPTION
    Export AD group members to CSV.
    .EXAMPLE
    Get-ADMemberCSV -GroupObj MyAdGroup
    .PARAMETER GroupObj
    The group name. Just one.
    #>
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$GroupObj
    )

    try {
        Get-ADGroupMember "$GroupObj" | Export-CSV -path "c:\temp\$GroupObj.csv"
        explorer c:\temp
    } catch {
        return $false
    }
}

function Import-Excel
{
  param (
    [string]$FileName,
    [string]$WorksheetName,
    [bool]$DisplayProgress = $true
  )

  if ($FileName -eq "") {
    throw "Please provide path to the Excel file"
    Exit
  }

  if (-not (Test-Path $FileName)) {
    throw "Path '$FileName' does not exist."
    exit
  }

  #$FileName = Resolve-Path $FileName
  $excel = New-Object -com "Excel.Application"
  $excel.Visible = $false
  $workbook = $excel.workbooks.open($FileName)

  if (-not $WorksheetName) {
    Write-Warning "Defaulting to the first worksheet in workbook."
    $sheet = $workbook.ActiveSheet
  } else {
    $sheet = $workbook.Sheets.Item($WorksheetName)
  }
  
  if (-not $sheet)
  {
    throw "Unable to open worksheet $WorksheetName"
    exit
  }
  
  $sheetName = $sheet.Name
  $columns = $sheet.UsedRange.Columns.Count
  $lines = $sheet.UsedRange.Rows.Count
  
  Write-Warning "Worksheet $sheetName contains $columns columns and $lines lines of data"
  
  $fields = @()
  
  for ($column = 1; $column -le $columns; $column ++) {
    $fieldName = $sheet.Cells.Item.Invoke(1, $column).Value2
    if ($fieldName -eq $null) {
      $fieldName = "Column" + $column.ToString()
    }
    $fields += $fieldName
  }
  
  $line = 2
  
  for ($line = 2; $line -le $lines; $line ++) {
    $values = New-Object object[] $columns
    for ($column = 1; $column -le $columns; $column++) {
      $values[$column - 1] = $sheet.Cells.Item.Invoke($line, $column).Value2
    }  
  
    $row = New-Object psobject
    $fields | foreach-object -begin {$i = 0} -process {
      $row | Add-Member -MemberType noteproperty -Name $fields[$i] -Value $values[$i]; $i++
    }
    $row
    $percents = [math]::round((($line/$lines) * 100), 0)
    if ($DisplayProgress) {
      Write-Progress -Activity:"Importing from Excel file $FileName" -Status:"Imported $line of total $lines lines ($percents%)" -PercentComplete:$percents
    }
  }
  $workbook.Close()
  $excel.Quit()
}

function Get-FilePathLength {
    <#
    .SYNOPSIS
    Count file path characters.
    .DESCRIPTION
    Help identifying 260 chars.
    .EXAMPLE
    Get-FilePathLength -FolderPath C:\temp
    .PARAMETER FolderPath
    The folder path to query. Just one.
    #>
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$FolderPath
    )
    Get-ChildItem -Path $FolderPath -Recurse -Force |
        #Where-Object {$_.FullName.length -ge 248 } |
        Select-Object -Property FullName, @{Name="FullNameLength";Expression={($_.FullName.Length)}} |
        Sort-Object -Property FullNameLength -Descending
}

function Get-Log {
    <#
    .SYNOPSIS
    Captain's log.
    .DESCRIPTION
    A running commentary of interesting events.
    .EXAMPLE
    Get-Log
    #>
    try {
        notepad "$PSDirectory\log.txt"
    } catch {
        return $false
    }
}; Set-Alias qq Get-Log

function Get-LAPS {
    <#
    .SYNOPSIS
    https://technet.microsoft.com/en-us/mt227395.aspx
    .DESCRIPTION
    Query Active Directory for the local administrator password of a ComputerObj.
    .EXAMPLE
    Get-LAPS -ComputerObj mycomputer-1
    .PARAMETER ComputerObj
    The computer name to query. Just one.
    #>
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]$ComputerObj
    )

    try {
        Get-ADComputer $ComputerObj -Properties ms-Mcs-AdmPwd | Select-Object name, ms-Mcs-AdmPwd
    } catch {
        return $false
    }
}; Set-Alias laps Get-LAPS

function Get-LAPSExpiry{
    <#
    .SYNOPSIS
    https://technet.microsoft.com/en-us/mt227395.aspx
    .DESCRIPTION
    Query Active Directory for the local administrator password expiry date for a ComputerObj.
    .EXAMPLE
    Get-LAPSExpiry -ComputerObj mycomputer-1
    .PARAMETER ComputerObj
    The computer name to query. Just one.
    #>
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$ComputerObj
    )

    $PwdExp = Get-ADComputer $ComputerObj -Properties ms-MCS-AdmPwdExpirationTime
    $([datetime]::FromFileTime([convert]::ToInt64($PwdExp.'ms-MCS-AdmPwdExpirationTime',10)))
}
function Get-MSIProdCode {
    <#
    .SYNOPSIS
    List all installed msi product codes.
    .DESCRIPTION
    List all installed msi product codes.
    .EXAMPLE
    Get-MSIProdCode
    #>
    get-wmiobject Win32_Product | Format-Table IdentifyingNumber, Name | Out-String -stream
    Write-Host "`nFilter with (sls) : | Select-String 'STRING'`n"
}

function Get-PowershellAs {
    <#
    .SYNOPSIS
    Run a powershell process as a specified user or as System NT
    .DESCRIPTION
    Run a powershell process as a specified user, a specific user elevated, or SYSTEM NT.
    .EXAMPLE
    Get-PowershellAs -UserObj myuser
    .EXAMPLE
    Get-PowershellAs -UserObj myuser -ElevatedObj
    .EXAMPLE
    Get-PowershellAs -UserObj myuser -SystemObj
    .PARAMETER UserObj
    Mandatory user name to "Run as"
    .PARAMETER SystemObj
    Optional parameter to run as System NT. Requires PSEXEC
    .PARAMETER ElevatedObj
    Optional parameter to run elevated (UAC).
    #>
    param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]$UserObj,
        [Parameter(Mandatory=$false)]
        [Switch]$SystemObj,
        [Parameter(Mandatory=$false)]
        [Switch]$ElevatedObj
    )

    $DomainObj = (Get-WmiObject Win32_ComputerSystem).Domain
    if ( $DomainObj -eq 'WORKGROUP' ){
        $DomainObj = (Get-WmiObject Win32_ComputerSystem).Name
    }

    if($SystemObj){
        $arglist = "Start-Process psexec -ArgumentList '-i -s powershell.exe -executionpolicy RemoteSigned' -Verb runAs"
    } else {
        $arglist = "Start-Process powershell.exe"
        if($ElevatedObj){
            $arglist = $arglist + " -Verb runAs"
        }
    }

    Start-Process powershell.exe -Credential "$DomainObj\$UserObj" -NoNewWindow -ArgumentList $arglist
}; Set-Alias pa Get-PowershellAs
<# End Support Helpers #>

<# HUD #>
Write-Host "$profile"
Write-Host (Get-ExecutionPolicy)

<# Prompt #>
function prompt {
    # https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt
    $origLastExitCode = $LastExitCode

    if (Get-GitStatus){
        if (Get-Command git -TotalCount 1 -ErrorAction SilentlyContinue) {
            Set-EnvPath((Get-Item "Env:ProgramFiles").Value + "\Git\bin")
            Write-Host (git --version) -ForegroundColor Cyan
        }
    }

    if (Test-IsAdmin) {  # if elevated
        Write-Host "(Elevated $env:USERNAME ) " -NoNewline -ForegroundColor Red
    } else {
        Write-Host "$env:USERNAME " -NoNewline -ForegroundColor Blue
    }

    Write-Host "$env:COMPUTERNAME " -NoNewline -ForegroundColor DarkCyan
    Write-Host $ExecutionContext.SessionState.Path.CurrentLocation -ForegroundColor Cyan -NoNewline
    Write-VcsStatus
    $LASTEXITCODE = $origLastExitCode
    "`n$('PS>' * ($nestedPromptLevel + 1)) "
}

<# Notes #>

# Build a better function
# https://technet.microsoft.com/en-us/library/hh360993.aspx?f=255&MSPPError=-2147217396

# Research ways of using execution policy
# Set-ExecutionPolicy RemoteSigned -scope CurrentUser

# function Get-evtx {
#     wevtutil epl application c:\temp\application.evtx
# }

# function Get_Health {
#     DISM /Online /Cleanup-Image /CheckHealth
#     DISM /Online /Cleanup-Image /ScanHealth
#     DISM /Online /Cleanup-Image /RestoreHealth
# }

# function Get-Remote {
#     Start-Process C:\Windows\CmRcViewer.exe
# }

# function Get-Uptime {
#     (Get-Date)-(Get-CimInstance Win32_OperatingSystem).lastbootuptime | Format-Table
# }

# function Get-Documentation {
#     <#
#     .SYNOPSIS
#     Quick access to edit documentation.
#     .DESCRIPTION
#     Lightweight documentation.
#     .EXAMPLE
#     Get-Documentation -DocObj printers
#     .PARAMETER DocObj
#     The document name. Just one.
#     #>
#     param (
#         [parameter(Mandatory=$true)]
#         [ValidateNotNullOrEmpty()]$DocObj
#     )
#     try {
#         Import-Csv "$PSDirectory\$DocObj.txt" | Format-Table | Out-String -stream
#         Write-Host "`nFilter with (sls) : | Select-String 'STRING'`n"
#     } catch {
#         Write-Host "No such document."
#         return $false
#     }

# }; Set-Alias gd Get-Documentation

# SSH
# Test pipe
#Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*' | Add-WindowsCapability -Online
# Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# Install the OpenSSH Client
#Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server
# Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Find the powershell way
# msinfo32 /nfo C:\TEMP\SYSSUM.NFO /categories +systemsummary
