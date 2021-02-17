

# EDE - le 22/10/20
# import d'utilisateur a partir d'un csv ou r�initialisation de mot de passe si existant
# dans une OU 

# format du csv
# OU Site;OU Service;CN;Company;Created;Department;Title;Description;DisplayName;DistinguishedName;Division;EmailAddress;EmployeeID;EmployeeNumber;Enabled;GivenName;LastBadPasswordAttempt;LastLogonDate;MobilePhone;Modified;Name;ObjectCategory;ObjectClass;ObjectGUID;objectSid;Office;OfficePhone;Organization;PostalCode;PrimaryGroup;SamAccountName;SID;SmartcardLogonRequired;State;StreetAddress;Surname;UserPrincipalName;whenChanged;whenCreated



# Message de bienvenue
Write-Host "Ce script permet de cr�er l'OU, les groupes, le compte Hotline"
Write-Host "ainsi que les utilisateurs si sp�cifi�s dans le fichier c:\scripts\utilisateurs.csv"
Write-Host "Format : Firstname,Lastname,SAM,Password"
Write-Host "(VF) : Nom,Pr�nom,Login,mdp"
Write-Host "Exemple : User,Test01,utest01,P@ssw0rd"
Write-Host "Regles de cr�ation des utilisateurs :"
Write-Host "si l'utilisateur n'existe pas alors on le cr�e"
Write-Host "sinon l'utilisateur existe d�ja, on ne le cr�e pas"
Write-Host "mais si l'utilisateur existe dans le groupe, on essaye de mettre � jour son mot de passe."


# nom du fichier de log
$Logfile = "C:\Scripts\$client_name.log"


# Infos sp�cifiques
$OU_RACINE = "OU=IMPORT,DC=mondomain,DC=tld"
$Date = Get-Date
$Maildomain = "@ndd.fr"
$_import_password = "LeSuperMotDePasseAChangerAlapremi�reConnexionMaisPasLeChoixIlFautEnMettreUn,M�meen2020!!"

# --- Import du fichier csv pour cr�ation des utilisateurs ---

$Users = Import-Csv -Path "C:\scripts\utilisateurs.csv"




$Output = "-----------------------------Lancement � $Date -----------------------------------"
Write-Host $Output
Add-content $Logfile -value $Output

foreach ($User in $Users)            
{            
    #Mise en forme des infos utilisateurs                 
                     

    $Displayname = $User.'DisplayName'
    $GivenName = $User.'GivenName'
    $Firstname = $User.'Firstname'            
    $Lastname = $User.'Lastname'
    $UserPrincipalName = $User.'UserPrincipalName' 
    $SamAccountName = $User.'SamAccountName'

    $Password = "MDP_defaut_a_changer"
    
    $Site = $User.'OU Site'
    $Service = $User.'OU Service'
    $Company = $User.'Company'
    $Title = $User.'Title'
    $OfficePhone = $User.'OfficePhone'
    $MobilePhone = $User.'MobilePhone'
    $Department =  $User.'Department'


    # --- Cr�ation de la sous-OU de Site si non existant bas�e sur le site ---

    try {
        Get-ADOrganizationalUnit -Identity "OU="+$Site+","+$OU_RACINE | Out-Null       
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        New-ADOrganizationalUnit -Name $Site -Path + $OU_RACINE -Description $Date
        #New-ADGroup -Name "$client_name" -SamAccountName $client_name -GroupCategory Security -GroupScope Global -DisplayName "$client_name" -Path $OU_OK
        #New-ADGroup -Name "$client_code-OSX" -SamAccountName "$client_code-OSX" -GroupCategory Security -GroupScope Global -DisplayName "$client_code-OSX" -Path $OU_OK
    
    }



    # V�rification pr�alable de la pr�sence utilisateur
    $User_to_check = Get-ADUser -Filter {sAMAccountName -eq $SamAccountName}

    If ($User_to_check -eq $Null) {
            # si l'utilisateur n'existe pas alors on le cr�e

            $Output = "Cr�ation de l'utilisateur :  $SamAccountName"
            Write-Host $Output
            Add-content $Logfile -value $Output

            # Cr�ation de l'utilisateur
            New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Date" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "OU="+$Site+","+$OU_RACINE -ChangePasswordAtLogon $truee �PasswordNeverExpires $false -server 02-DC-01.leni.fr
            
            #V�rification de la bonne cr�ation de l'utilisateur
            if ($? -eq $false)
            {
                $Output = "Erreur � la Cr�ation de l'utilisateur :  $SamAccountName"
                Write-Host $Output
                Add-content $Logfile -value $Output
            }

            #Ajout de l'utilisateur au groupe client
            Add-ADGroupMember -Identity "$client_name" -Members "$SamAccountName"
    }
    Else {

            # sinon on l'utilisateur existe d�ja, on ne le cr�e pas
            $Output = "Utilisateur d�ja existant (pas de cr�ation) : $SamAccountName"
            Write-Host $Output
            Add-content $Logfile -value $Output


            # Si l'utilisateur existe dans le groupe, on essaye de mettre � jour son mot de passe.
            If ($members -contains $SamAccountNameM) {
                $Output = Write-Host "Mise a jour du mot de passe"
                Write-Host $Output
                Add-content $Logfile -value $Output

                Set-ADAccountPassword -Identity $SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
                  if ($? -eq $false) {
                        $Output = "Mot de passe non compliant :  $SamAccountName"
                        Write-Host $Output
                        Add-content $Logfile -value $Output
                    } 
                    else {
                       $Output = "              -> Mot de passe mis � jour / Compte activ� : $SamAccountName"
                       Write-Host $Output
                       Add-content $Logfile -value $Output

                       Enable-ADAccount -Identity $SamAccountName
                       Unlock-ADAccount -Identity $SamAccountName
                    }
            }
    }
}

$Date = Get-Date
$Output = "-----------------------------Fin le $Date -----------------------------------"
Write-Host $Output
Add-content $Logfile -value $Output