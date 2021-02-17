
#CmdLet a installer
Install-Module MSOnline

#Connection Azure
Connect-MsolService -Credential $credential


#Boucle pour eviter à se reconnecter à chaque lancement.
Do
{

    #On interroge l'utilisateur sur le mail a traiter
    $User = Read-Host -Prompt 'e-mail à mettre à jour '
    #On recupère l'utilisateur O365 correspondant
    $UserId = Get-MsolUser -UserPrincipalName $User

    #Si le retour est vide, pas de correspondance, on arrete.
    if ($UserId.DisplayName -eq "" ) {
        echo "Pas d'utilisateur - Arret"
        exit
    }

    #On affiche les informations de l'utilisateur pour verification
    echo "Utilisateur : "
    echo $UserId.DisplayName
    echo "e-mail : "
    echo $UserId.UserPrincipalName
    echo "licence actuelle :"
    echo $UserId.Licenses.AccountSkuId

    #On Attend confirmation
    $Confirm = Read-Host -Prompt 'Confirmer [Y] ?'

    if ($Confirm -ne "Y" ) {
       echo "Pas de confirmation - Arret"
        exit
    }

    echo "Debut de traitement"

    Remove-MsolUser -UserPrincipalName $UserId.UserPrincipalName -force
    Remove-MsolUser -UserPrincipalName $UserId.UserPrincipalName -RemoveFromRecycleBin -force


    echo "Création"

    New-MsolUser -UserPrincipalName $UserId.UserPrincipalName -DisplayName $UserId.DisplayName -FirstName $UserId.FirstName -LastName $UserId.LastName -MobilePhone $UserId.MobilePhone -PhoneNumber $UserId.PhoneNumber -Office $UserId.Office -Password "Leni12345" -ForceChangePassword 1 
    
    echo "Ajout de licence"

    Set-MsolUser -UserPrincipalName $UserId.UserPrincipalName -UsageLocation FR
    Set-MsolUserLicense -UserPrincipalName $UserId.UserPrincipalName -AddLicenses "lenifr:O365_BUSINESS_ESSENTIALS"

    $UserId = Get-MsolUser -UserPrincipalName $User
    echo "Utilisateur Modifié"
    echo $UserId.DisplayName
    echo "e-mail : "
    echo $UserId.UserPrincipalName
    echo "licence actuelle :"
    echo $UserId.Licenses.AccountSkuId
        
    echo "etat des licences "
    Get-MsolAccountSku | Where-Object {$_.AccountSkuId -eq "lenifr:O365_BUSINESS_ESSENTIALS"} | Select AccountSkuId, ConsumedUnits, ActiveUnits




    echo "Fin de traitement"



}While ($True)
