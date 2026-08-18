# SQL Daily Health Check

$ReportFolder = "C:\ansible_workdir\SQL_Daily_checks"

if (!(Test-Path $ReportFolder)) {
    New-Item -ItemType Directory -Path $ReportFolder -Force | Out-Null
}

$DateStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ReportFile = "$ReportFolder\MSSQL_SHC_$DateStamp.txt"

$Results = @()

$Results += "========================================="
$Results += "SQL DAILY HEALTH CHECK REPORT"
$Results += "========================================="
$Results += "Server Name : $env:COMPUTERNAME"
$Results += "Date        : $(Get-Date)"
$Results += ""

# SQL Service Status
$SqlService = Get-Service MSSQLSERVER -ErrorAction SilentlyContinue

if ($SqlService) {
    $Results += "SQL Service Status : $($SqlService.Status)"
}
else {
    $Results += "SQL Service Status : NOT FOUND"
}

# SQL Agent Status
$SqlAgent = Get-Service SQLSERVERAGENT -ErrorAction SilentlyContinue

if ($SqlAgent) {
    $Results += "SQL Agent Status : $($SqlAgent.Status)"
}
else {
    $Results += "SQL Agent Status : NOT FOUND"
}

$Results += ""
$Results += "========================================="
$Results += "DATABASE STATUS"
$Results += "========================================="

try {

    $DBStatus = Invoke-Sqlcmd -Query "
    SELECT name, state_desc
    FROM sys.databases
    ORDER BY name
    "

    foreach ($DB in $DBStatus) {

        $Results += "$($DB.name) : $($DB.state_desc)"
    }
}
catch {

    $Results += "Unable to fetch database status"
    $Results += $_.Exception.Message
}

$Results += ""
$Results += "========================================="
$Results += "BLOCKING SESSIONS"
$Results += "========================================="

try {

    $Blocking = Invoke-Sqlcmd -Query "
    SELECT
        session_id,
        blocking_session_id,
        wait_type,
        wait_time
    FROM sys.dm_exec_requests
    WHERE blocking_session_id <> 0
    "

    if ($Blocking.Count -eq 0) {

        $Results += "No Blocking Found"
    }
    else {

        foreach ($Block in $Blocking) {

            $Results += "Session ID: $($Block.session_id) | Blocking Session: $($Block.blocking_session_id) | Wait Type: $($Block.wait_type) | Wait Time: $($Block.wait_time)"
        }
    }
}
catch {

    $Results += "Unable to fetch blocking details"
    $Results += $_.Exception.Message
}

$Results += ""
$Results += "Health Check Completed Successfully"
$Results += "========================================="

# Save report to file
$Results | Out-File -FilePath $ReportFile -Encoding UTF8

# Display in PowerShell and AAP
$Results | ForEach-Object {
    Write-Output $_
}
