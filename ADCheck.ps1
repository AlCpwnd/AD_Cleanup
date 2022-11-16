$UIInfo = $Host.UI.RawUI
$HostInfo = $Host.PrivateData

function Write-Info{
    Param(
        [Parameter(Mandatory,Position=0)][ValidateSet("Info","Warning","Error")]$Type,
        [Parameter(Mandatory,Position=1)]$Number,
        [Parameter(Mandatory,Position=2)]$Message
    )
    switch ($Type) {
        "Info" {Write-Host "`t[" -NoNewline; Write-Host "$Number" -ForegroundColor $UIInfo.BackgroundColor -BackgroundColor $UIInfo.ForegroundColor -NoNewline; Write-Host "] $Message"}
        "Error" {Write-Host "`t[" -NoNewline; Write-Host $Number -ForegroundColor $HostInfo.ErrorForegroundColor -BackgroundColor $HostInfo.ErrorBackgroundColor -NoNewline; Write-Host "] $Message"}
        "Warning" {Write-Host "`t[" -NoNewline; Write-Host $Number -ForegroundColor $HostInfo.WarningForegroundColor -BackgroundColor $HostInfo.WarningBackgroundColor -NoNewline; Write-Host "] $Message"}

    }
}

Write-Host ""
Write-Host ""
Write-Host "`tRecovering domain devices."
Write-Host ""
Write-Host ""

if(!(Get-Module -Name ActiveDirectory)){ # Module verification
    try{
        $Devices = Get-ADComputer -Filter * -Properties LastLogonDate -ErrorAction Stop
    }catch{
        Write-Host "ActiveDirectory module is missing from this machine. Aborting." -ForegroundColor $HostInfo.ErrorForegroundColor -BackgroundColor $HostInfo.ErrorBackgroundColor
        return
    }
}

Write-Host ""
Write-Info Info $Devices.Count "total devices found."
    
$Today = Get-Date

$3m = $Devices | Where-Object{$_.LastLogonDate -lt $Today.AddMonths(-3)}
$6m = $Devices | Where-Object{$_.LastLogonDate -lt $Today.AddMonths(-6) -and $_.LastLogonDate -ge $Today.AddMonths(-3)}
$1y = $Devices | Where-Object{$_.LastLogonDate -lt $Today.AddYears(-1) -and $_.LastLogonDate -lt $Today.AddMonths(-6)}


if($3m){
    Write-Host ""
    Write-Info Warning $3m.Count "Device(s) found that haven't connected in the last 3 months."
}
if($6m){
    Write-Host ""
    Write-Info Warning $6m.Count "Device(s) found that haven't connected in the last 6 months."
}
if($1y){
    Write-Host ""
    Write-Info Error $1y.Count "Device(s) found that haven't connected in the last year."
}