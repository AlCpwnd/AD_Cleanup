# Module verification
if(!(Get-Module -Name ActiveDirectory)){
    try{
        Import-Module AcriveDirectory -ErrorAction Stop
    }catch{
        Write-Host "ActiveDirectory module is missing from this machine. Aborting."
        return
    }
}

$Devices = Get-ADComputer -Filter * -Properties LastLogonDate

