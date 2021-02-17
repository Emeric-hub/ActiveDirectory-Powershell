Import-module ActiveDirectory
$Users = Import-Csv c:\leni\Export_proxy.csv -delimiter ";"

foreach ($User in $Users)  
{
    $UserPrincipalName = $User.UserPrincipalName
    $userproxy = $User.ProxyAddresses -split ';'
    $User_ori = Get-ADUser -Filter 'UserPrincipalName -like $UserPrincipalName' -Properties DisplayName
    echo $User_ori.DisplayName
    Set-ADUser $User_ori -Add @{proxyAddresses= $userproxy}
}