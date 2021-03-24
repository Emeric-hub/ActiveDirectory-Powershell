
# Script necessaire à l'intégration au domaine dans le cadre du déploiement
#renommage du poste
# EDE - 09/10/2020


function SendAlert{

$User = "Mail expediteur"
$ToAddress = "Service Informatique <Mail expediteur>"
$MessageSubject = "le poste $computername_name a été integré au domaine"
$MessageBody = "le poste $computername_name a été integré au domaine"
$SMTPServer = "serveur_SMTP"
$SMTPMessage = New-Object System.Net.Mail.MailMessage($ToAddress,$FromAddress,$MessageSubject,$MessageBody)

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
$SMTPClient.EnableSsl = $false
#$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Cred.UserName, $Cred.Password);
$SMTPClient.Send($SMTPMessage)

}
 


#Verification N°1 : Accès D.C.

$dns_name= Resolve-DnsName -Name ndd_du_domaine

#Si l'ip est une de celle du controleur de domaine, on suppose que l'integration est réalisable

switch ($dns_name.IPAddress)
{
    "addresse1" {}
    "addresse2" {}
    Default {
        echo "---------------------------------------------"
        echo "le poste ne résoud pas le bon nom de ndd_du_domaine"
        echo "l'intégration ne peux pas fonctionner"
        echo "une connexion VPN est probablement nécessaire"
        echo "---------------------------------------------"
        echo ""
        pause
        exit
     }
}

#Affichage du nom de poste et préparation


echo "Nom actuel du Poste :" $Nom_de_poste

echo "Convention de nommage :"
echo "XX-YYY-ZZZ (ex : 01-LAP-EDE)"
echo "XX : Numéro Site d'appartenance de la machine"
echo "01 - Montreuil"
echo "02 - Angers"
echo "03 - Valbonne"
echo "04 - Lyon"
echo "05 - Marseille"
echo "06 - Toulouse"
echo "07 - Tunis"
echo "08 - Bussy"
echo "--------------"
echo "YYY : Type de poste"
echo "LAP : Laptop (Portable)"
echo "DES : Desktop (Fixe)"
echo "--------------"
echo "ZZZ : le Trigramme de l'utilisateur"
echo "exemple Emeric Delavaud -> EDE"
echo "--------------"

$computername_name = Read-Host -Prompt 'Nouveau nom à attribuer'
$Nom_de_poste = $computername_name
if (!$computername_name) { 
    exit 
}

#Vérification N°2 : Format de nom de poste



#$Nom_de_poste = "02-LAP-EDE"
$split_name = $Nom_de_poste.Split("-")
echo "---------------------------------------------"
echo "Nom actuel du Poste :" $Nom_de_poste
echo ""
#Extraction de l'agence à partir du nom de machine
switch ($split_name[0])
{
    "01" { $Site = "S01-MONTREUIL"}
    "02" { $Site = "S02-ANGERS"}
    "03" { $Site = "S03-VALBONNE"}
    "04" { $Site = "S04-LYON"}
    "05" { $Site = "S05-MARSEILLE"}
    "06" { $Site = "S06-TOULOUSE"}
    "07" { $Site = "S07-TUNIS"}
    "08" { $Site = "S08-BUSSY"}

     Default {
            "Le nommage est erroné (ex de format attendu: 01-LAP-EDE)"
            pause
            exit
     }
}
echo "---------------------------------------------"

#Extraction du type de poste à partir du nom de machine
switch ($split_name[1])
{
    "LAP" { $Type = "LAPTOP"}
    "DESK" { $Type = "LAPTOP"}
    "DES" { $Type = "DESKTOP"}
     Default {
            "Le nommage est erroné (format attendu: 01-LAP-EDE)"
            pause
            exit
     }
}

$Type_rework = "S" + $split_name[0] + "-" + $Type

# Création du chemin d'intégration du poste dans l'A.D.
$OU_path = "OU="+$Type_rework+",OU=S"+$split_name[0]+"-COMPUTERS,OU="+$site+",OU=LENI,DC=leni,DC=fr"

#echo $OU_path


# Intégration au Domaine :


#add-computer –domainname leni.fr -OUPath $OU_path -restart –force
echo "Renommage du poste, patientez."
echo ""
Rename-Computer -NewName "$computername_name"

sleep 15

echo ""
echo "Saisissez un compte N3 autorisé a enregistrer des postes dans le domaine"

$result = add-computer –domainname leni.fr -OUPath $OU_path -Options JoinWithNewName,AccountCreate –force -passthru

if ($result.HasSucceeded ) {
    
    Echo "Yeah !!! Ca marche !!!"
    sleep 5

    #Désactivation Autologin

    Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -value "0"
    Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -value "Leni.fr"
    Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -value "" 
    Set-Itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "LastUsedUsername" -value ""


    #reinit ID Anydesk
    stop-service AnyDesk-d74b3733_msi
    sleep 10
    Remove-Item "C:\ProgramData\AnyDesk\ad_d74b3733_msi\" -Force

    #On envois un mail pour prévenir
    SendAlert

    #On reboot et le poste doit etre pret !
    Restart-Computer -Force



    Echo "redemarrez le poste si cela ne se fait pas automatiquement"

} else {

    echo "une erreur est survenue"
    echo "un poste existe peut-etre déja avec ce nom"
    echo "le compte utilisé n'a pas les droits pour  inscrire un poste ..."
   
}
pause




