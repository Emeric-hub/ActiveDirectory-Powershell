# EDE - le 14/09/20
#Script avec pour objectif de recuperer les smtp proxy des utilisateurs coté Azure AD

#CmdLet a installer
#Install-Module MSOnline

#Connection Azure
Connect-MsolService -Credential $credential

get-msoluser | select DisplayName , UserPrincipalName, @{L = "ProxyAddresses"; E = { $_.ProxyAddresses -join ";"}} | export-csv -append .\Export_proxy.csv -delimiter ";"

#Get-MSOLUser | Select DisplayName , UserPrincipalName, @{Name="PrimaryEmailAddress";Expression={$_.ProxyAddresses | ?{$_ -cmatch '^SMTP\:.*'}}} | export-csv -append "C:\Users\edelavaud\Desktop\O365 - Ransonware\Messagerie\ExportTest.csv"

