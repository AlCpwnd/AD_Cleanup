param(
    [Switch]$User=$false,
    [Switch]$Computer=$false,
    [Switch]$Server=$false
)

#Requires -Modules ActiveDirectory

# Settings:
$UserGracePeriod = 6 # Number of months of inactivity before the user is considered inactive
$ServerGracePeriod = 6 # Number of months of inactivity before the server is considered inactive
$ComputerGracePeriod = 6 # Number of months of inactivity before workstation/laptop is considered inactive

$Today = Get-Date

# Code:
if($User){
    $Users = Get-ADUser -Filter * -Properties LastLogonDate | Where-Object{$_.LastLogonDate -lt $Today.AddMonths(-$UserGracePeriod)}
    
}
if($Server -or $Computer){
    $Devices = Get-ADComputer -Filter * -Properties LastLogonDate,OperatingSystem
    $Workstations = $Devices | Where-Object{$_.OperatingSystem -notmatch "Server" -and $_.OperatingSystem -match "Windows"}
    $Servers = (Compare-Object -ReferenceObject $Devices -DifferenceObject $Workstations).InputObject
}