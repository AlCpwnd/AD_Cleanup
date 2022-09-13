param(
    [Switch]$User,
    [Switch]$Computer,
    [Switch]$Server,
    [Switch]$IncludeExceptions,
    [Switch]$Report
)

#Requires -Modules ActiveDirectory

# Settings:
$UserGracePeriod = 6 # Number of months of inactivity before the user is considered inactive
$ServerGracePeriod = 6 # Number of months of inactivity before the server is considered inactive
$ComputerGracePeriod = 6 # Number of months of inactivity before workstation/laptop is considered inactive

$Today = Get-Date

$UserExceptions = "Guest","DefaultAccount","krbtgt","Sync_" # Exceptions to the search. Either default accounts or sync accounts

# Functions:
function Show-Status{
    Param(
        [Parameter(Mandatory,Position=0)][ValidateSet("Info","Warning","Error")][String]$Type,
        [Parameter(Mandatory,Position=1)][String]$Message
    )
    switch($Type){
        "Info" {$param = @{Object = "`t[i] $Message"}}
        "Warning" {$param = @{Object = "`t[!] $Message"; ForegroundColor = "Yellow"}}
        "Error" {$param = @{Object = "`t[x] $Message"; ForegroundColor = "Red"}}
    }
    Write-Host @param
}

# Code:
if($User){
    $Users = Get-ADUser -Filter * -Properties LastLogonDate,CanonicalName | Where-Object{$_.LastLogonDate -lt $Today.AddMonths(-$UserGracePeriod) -and $_.SamAccountName -notmatch ($UserExceptions -join "|")}
    if($Users){
        Show-Status Info "$($Users.Count) user(s) found:"
        $Users | Select-Object Name,SamAccountName,LastLogonDate,CanonicalName
    }
}
if($Server -or $Computer){
    $Devices = Get-ADComputer -Filter * -Properties LastLogonDate,OperatingSystem
    $Workstations = $Devices | Where-Object{$_.OperatingSystem -notmatch "Server" -and $_.OperatingSystem -match "Windows"}
    $Servers = (Compare-Object -ReferenceObject $Devices -DifferenceObject $Workstations).InputObject
}