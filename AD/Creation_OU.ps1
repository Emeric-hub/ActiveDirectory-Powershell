# EDE - le 14/09/20
# Creation d'une nouvelle agence sur la base d'un template.


# Demande le nom du client
$agence_name = Read-Host -Prompt 'Nom du site (format : SXX-VILLE)'
if (!$agence_name) { 
    exit 
}

# nom du fichier de log
$Logfile = "C:\Folder\$agence_name.log"

# Infos spécifiques
$OU_PATH_ROOT = ",OU=EXEMPLE_OU_RACINE,DC=MON_DC,DC=fr"
$OU_PATH_AGENCE = "OU="+ $agence_name + $OU_PATH_ROOT
$OU_PATH_COMPUTERS = "OU=$agence_code-COMPUTERS,"+ $OU_PATH_AGENCE
$OU_PATH_USERS = "OU=$agence_code-USERS," + $OU_PATH_AGENCE

$Date = Get-Date

#recupération du num client
$pos = $agence_name.IndexOf("-")
$agence_code = $agence_name.Substring(0, $pos)

try {
    #On Check L'existence de l'O.U.
        Get-ADOrganizationalUnit -Identity $OU_PATH_ROOT | Out-Null
        $Output = "L'OU existe - pas de création"
        Write-Host $Output       
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    #Si elle n'existe pas ... On la crée

    #Lvl0
        New-ADOrganizationalUnit -Name $agence_name -Path $OU_PATH_ROOT -Description $Date
    #Lvl1
        New-ADOrganizationalUnit -Name "$agence_code-COMPUTERS" -Path $OU_PATH_AGENCE -Description $Date
        New-ADOrganizationalUnit -Name "$agence_code-SERVICES" -Path $OU_PATH_AGENCE -Description $Date
        New-ADOrganizationalUnit -Name "$agence_code-USERS" -Path $OU_PATH_AGENCE -Description $Date
        New-ADOrganizationalUnit -Name "$agence_code-TRASH" -Path $OU_PATH_AGENCE -Description $Date
    #Lvl2
        #ComputersOU
            
            New-ADOrganizationalUnit -Name "$agence_code-DESKTOP" -Path $OU_PATH_COMPUTERS -Description $Date
            New-ADOrganizationalUnit -Name "$agence_code-LAPTOP" -Path $OU_PATH_COMPUTERS -Description $Date
            New-ADOrganizationalUnit -Name "$agence_code-SERVERS" -Path $OU_PATH_COMPUTERS -Description $Date
        #UsersOU
            New-ADOrganizationalUnit -Name "$agence_code-USERS-DEFAULT" -Path $OU_PATH_USERS -Description $Date
            New-ADOrganizationalUnit -Name "$agence_code-USERS-DEV" -Path $OU_PATH_USERS -Description $Date
            New-ADOrganizationalUnit -Name "$agence_code-USERS-IT" -Path $OU_PATH_USERS -Description $Date
            New-ADOrganizationalUnit -Name "$agence_code-USERS-PROVIDER" -Path $OU_PATH_USERS -Description $Date
    
    # Ajout Droits pour LAPS
    Set-AdmPwdComputerSelfPermission -OrgUnit $agence_code-COMPUTERS
    Set-AdmPwdReadPasswordPermission -OrgUnit $agence_code-COMPUTERS -AllowedPrincipals PwdAdmins
    Set-AdmPwdResetPasswordPermission -OrgUnit $agence_code-COMPUTERS -AllowedPrincipals PwdAdmins

    Set-AdmPwdComputerSelfPermission -OrgUnit $agence_code-DESKTOP
    Set-AdmPwdReadPasswordPermission -OrgUnit $agence_code-DESKTOP -AllowedPrincipals PwdAdmins
    Set-AdmPwdResetPasswordPermission -OrgUnit $agence_code-DESKTOP -AllowedPrincipals PwdAdmins

    Set-AdmPwdComputerSelfPermission -OrgUnit $agence_code-LAPTOP
    Set-AdmPwdReadPasswordPermission -OrgUnit $agence_code-LAPTOP -AllowedPrincipals PwdAdmins
    Set-AdmPwdResetPasswordPermission -OrgUnit $agence_code-LAPTOP -AllowedPrincipals PwdAdmins

    Set-AdmPwdComputerSelfPermission -OrgUnit $agence_code-SERVERS
    Set-AdmPwdReadPasswordPermission -OrgUnit $agence_code-SERVERS -AllowedPrincipals PwdAdmins
    Set-AdmPwdResetPasswordPermission -OrgUnit $agence_code-SERVERS -AllowedPrincipals PwdAdmins



    }
$Date = Get-Date
$Output = "-----------------------------Fin le $Date -----------------------------------"
Write-Host $Output
Add-content $Logfile -value $Output
