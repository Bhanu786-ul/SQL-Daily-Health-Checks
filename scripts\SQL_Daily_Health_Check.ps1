$ReportFolder = "C:\ansible_workdir\SQL_Daily_checks"

if (!(Test-Path $ReportFolder))
{
    New-Item -ItemType Directory -Path $ReportFolder -Force
}

$DateStamp = Get-Date -Format "yyyyMMdd_HHmmss"

$ReportFile = "$ReportFolder\MSSQL_SHC_$DateStamp.txt"

$Results = @()

$Results += "============================================="
$Results += "SQL DAILY HEALTH CHECK REPORT"
$Results += "============================================="
$Results += "Server Name : $env:COMPUTERNAME"
$Results += "Date        : $(Get-Date)"
$Results += ""

# SQL Service Status

$SqlService = Get-Service MSSQLSERVER -ErrorAction SilentlyContinue

if($SqlService)
{
    $Results += "SQL Service Status : $($SqlService.Status)"
}
else
{
    $Results += "SQL Service : Not Found"
}

# SQL Agent

$SqlAgent = Get-Service SQLSERVERAGENT -ErrorAction SilentlyContinue

if($SqlAgent)
{
    $Results += "SQL Agent Status : $($SqlAgent.Status)"
}
else
{
    $Results += "SQL Agent : Not Found"
}

# Disk Space

$Results += ""
$Results += "Drive Information"

Get-PSDrive -PSProvider FileSystem | ForEach-Object {

    $FreeGB = [math]::Round($_.Free/1GB,2)

sults += "$($_.Name): Free Space = $FreeGB GB"
}

$Results += ""
$Results += "Health Check Completed"

$Results | Out-File $ReportFile

$Results | ForEach-Object {
    Write-Output $_
}
