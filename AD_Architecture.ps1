$Ous = Get-ADOrganizationalUnit -Filter * | Select Name,DistinguishedName
$Clean = foreach($OU in $Ous){
    [PsCustomObject]@{
        Name = $OU.Name
        ParentOU = $OU.DistinguishedName.Split(",") | ?{$_ -notmatch "DC|$($OU.Name)"} | %{$_.Replace("OU=","")}
    }
}

$Mid = "├─"
$End = "└─"

function Write-ADArchitecture{
    param(
        $Parent,
        $Table
    )
    $Output = @()
    if(!$Parent){
        $Output += (Get-ADDomain).DNSRoot
        $Spacing = ""
    }else{
        $Spacing = "  "
    }
    $Root = $Table | ?{$_.ParentOU -eq $Parent}
    foreach($Folder in $Root){
        if($Folder -eq $Root[-1]){
            $Connector = $End
        }else{
            $Connector = $Mid
        }
        $Output += "$Spacing$Connector$($Folder.Name)"
        $Children = $Table | ?{$_.ParentOU -contains $Folder.Name}
        if($Children){
            $Output += Write-ADArchitecture -Parent $Folder -Table $Children
        }
    }
    return $Output
}

Write-ADArchitecture -Table $Clean