<#
 .SYNOPSIS
    Notes sur la gestion des GPO depuis Powershell
 .DESCRIPTION
    Notes sur la gestion des GPO depuis Powershell

 .NOTES 
  voir :
  https://akril.net/rechercher-dans-les-gpo-de-votre-active-directory-avec-powershell/

  Configurer Chrome par GPO
  https://support.google.com/chrome/a/answer/187202?hl=fr#zippy=%2Cwindows 
  Configurer Horizon par GPO
  https://docs.vmware.com/en/VMware-Horizon/2106/horizon-remote-desktop-features/GUID-633FB6A2-206E-40A2-A72B-0FD28823EBCA.html

  Avant action sur une GPO faire une sauvegarde depuis une console de domaine ou depuis une T0
  Le dossier de Sauvegardes d:\donapp\xmadds\P00\sav\GPO
  $SavDir='d:\donapp\xmadds\P00\sav\GPO'
  if (-not (test-path $SavDir)) { new-item -path $SavDir -itemType Directory}

  Voir le script SAVE-GPOSilo.ps1 mis en place à partir de ces notes.
  
  sécurisation des GPO :https://www.ssi.gouv.fr/publication/chemins-de-controle-en-environnement-active-directory-chacun-son-root-chacun-son-chemin/ 
    manipuler les GPO : https://hichamkadiri.wordpress.com/tag/gerer-gpo-via-powershell/  ( trouver les orphelins)

 .LINK
    https://evotec.xyz/the-only-command-you-will-ever-need-to-understand-and-fix-your-group-policies-gpo/ 

#>

#region Générer HTML un rapport unitaire sur domaine Précis
$Domain='asm.awd.pole-emploi.intra'
$Domain='xitam.unedic.fr'
$LogDir='d:\donapp\xinvtr\p00\html\rapports'
$LogName='GPOReport-{0}.html' -f $Domain.split('.')[0]
$LogPath=join-path $LogDir $LogName
Get-GPOReport -All -Domain $Domain -ReportType Html -Path $LogPath
#endregion Générer un rapport HTML

#region Générer HTML un rapport unitaire sur les domaines de la foret par défaut
$SBRapportGPOs={ 
    Write-Host ('Génération des Rapports Stratégies de Domaine (GPO) ') -ForegroundColor gray   
    $DossierRapport='d:\donapp\xinvtr\p00\html\rapports'
    $File='GPOReport-{0}.html'
    If (-not (test-path $DossierRapport)) {New-Item -Path $DossierRapport -ItemType Directory }
    #$Forets='aw0.pole-emploi.intra'
    #$Forets='xitam.unedic.fr'
    if ($Forets -le '') { $Forets=(Get-ADForest).RootDomain }
    # 'abep.pole-emploi.intra','abed.pole-emploi.intra'| % {
    # 'ame.pole-emploi.intra','amex.pole-emploi.intra','amer.pole-emploi.intra','amed.pole-emploi.intra' | % {
    $Forets | ForEach-Object {
            $Forest=Get-ADForest -Server $_
            Foreach ($Domain in $Forest.Domains) {
            $DomainCourt=$Domain.split('.')[0]
            Write-Host ('Génération rapport GPO pour [{0}]' -f $DomainCourt) -ForegroundColor gray   
            $FileName=$File -f $Domain.split('.')
            $Filepath=Join-Path $DossierRapport $FileName
                Get-GPOReport -All -Domain $Domain -ReportType Html -Path $Filepath
            }  # fin du forEach
    }     # fin de la boucle 
    Write-Host ('Rapports GPO disponibles dans [{0}]' -f $DossierRapport) -ForegroundColor Yellow
}   # $SBRapportGPOs
# & $SBRapportGPOs
    
    # si besoin robocopy $DossierRapport \\swz9i5.asp.awp.pole-emploi.intra\d$\donapp\xinvtr\p00\html\rapports *.html
#endregion Générer HTML un rapport unitaire sur les domaines POC


#region recherche dans les GPO
# https://akril.net/rechercher-dans-les-gpo-de-votre-active-directory-avec-powershell/
# https://dailysysadmin.com/KB/Article/2304/search-all-gpos-in-a-domain-for-some-text/
# Get the string we want to search for 
$string = Read-Host -Prompt "What string do you want to search for?" 
 
# Set the domain to search for GPOs 
$DomainName = $env:USERDNSDOMAIN 
 
# Find all GPOs in the current domain 
write-host "Finding all the GPOs in $DomainName" 
Import-Module grouppolicy 
$allGposInDomain = Get-GPO -All -Domain $DomainName 
[string[]] $MatchedGPOList = @()

# Look through each GPO's XML for the string 
Write-Host "Starting search...." 
foreach ($gpo in $allGposInDomain) { 
    $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml 
    if ($report -match $string) { 
        write-host "********** Match found in: $($gpo.DisplayName) **********" -foregroundcolor "Green"
        $MatchedGPOList += "$($gpo.DisplayName)";
    } # end if 
    else { 
        Write-Host "No match in: $($gpo.DisplayName)" 
    } # end else 
} # end foreach
write-host "`r`n"
write-host "Results: **************" -foregroundcolor "Yellow"
foreach ($match in $MatchedGPOList) { 
    write-host "Match found in: $($match)" -foregroundcolor "Green"
}

#endregion recherche dans les GPO

# recherche d'une GPO par son SID
$AllGposInDomain = Get-GPO -All -Domain $DomainName 
$IDGPO='{0A8F5770-9C64-4D58-9B51-13F9277D7D34}'
$ID=$IDGPO -replace('{|}','')

$AllGposInDomain | where {$_.id -eq  $iD}
$AllGposInDomain | where {$_.displayName -eq 'STR_Serveurs'}
$AllGposInDomain | sort DisplayName | ft DisplayName,id

$IDGPO='{444278e7-ffde-48d5-8553-bd9d201fac1a}'
$ID=$IDGPO -replace('{|}','')

$Dossier='D:\sasech\Backup\All-GPO'
test-path (Join-Path $Dossier $IDGPO) 

# recherches des libellées // a la sauvegarde
$Dossier='D:\sasech\Backup\All-GPO'
$Saves=Get-ChildItem -path $Dossier 
foreach ($Save in $Saves) {
    $IDGPO=$Save.Name
    $ID=$IDGPO -replace('{|}','')
    $AllGposInDomain | where {$_.id -eq  $iD}    
}


#region backup des GPO du domaine courant en powershell
#$Dossier='D:\sasech\Backup\All-GPO'
$Domain='asm.awd.pole-emploi.intra'
$Domain='asp.awp.pole-emploi.intra'
$Domain='as0.aw0.pole-emploi.intra'

$SavDir='d:\donapp\xmadds\P00\sav\GPO'
if (-not (test-path $SavDir)) { new-item -path $SavDir -itemType Directory}
$Domain=(get-addomain).DnsRoot
$DomainCourt=$Domain.split('.')[0]
$DossierCible=(join-path $SavDir $DomainCourt)
if (-not (test-path $DossierCible)) { new-item -path $DossierCible -itemType Directory}
get-Gpo -all -domain $Domain | Backup-gpo -Path $DossierCible -domain $Domain
#endregion backup des GPO en powershell

#region backup des GPO des domaines de la foret courante en powershell
#$Dossier='D:\sasech\Backup\All-GPO'
$SavDir='d:\donapp\xmadds\P00\sav\GPO'
if (-not (test-path $SavDir)) { New-Item -Path $SavDir -ItemType Directory}
$Param=@{} 
#$Param['Server']='anpe.fr'
#$Param['Server']='ame.pole-emploi.intra'
#$Param['Server']='abep.pole-emploi.intra'
#$Param['Server']='itam.unedic.fr'
$ForestInfos=get-adForest @Param
$Foret=($ForestInfos).name
foreach ($Domain in $ForestInfos.Domains) { 
    $DomainCourt=$Domain.split('.')[0]
    $DossierCible=(join-path $SavDir $DomainCourt)
    if (-not (test-path $DossierCible)) { new-item -path $DossierCible -itemType Directory}
    get-Gpo -all -domain $Domain | Backup-gpo -Path $DossierCible -domain $Domain
}
#endregion backup des GPO en powershell

#region backup des GPO des domaines du silo courant (script en powershell)
#region Charger les librairies
. 'D:\applis\xtechn\put\lib\LIB.z.PE-GP-VarTools.ps1'
. 'D:\applis\xtechn\put\lib\LIB.z.PE-GP-SrvTools.ps1'
. 'D:\applis\xtechn\put\lib\LIB.Z.PE-GP-ADTOOLS.ps1'
#endregion Charger les librairies

$SavDir=join-path $RacineDonapp 'xmadds\P00\sav\GPO'  # 'd:\donapp\xmadds\P00\sav\GPO'
if (-not (test-path $SavDir)) { New-Item -Path $SavDir -ItemType Directory}

$Param=@{} 
$ListeDomaines=($oLesDomaines | Where-Object {$_.silo -eq (get-silo)})

foreach ($Domaine in $ListeDomaines) { 
    $DossierCible=(join-path $SavDir $Domaine.Name)
    if (-not (test-path $DossierCible)) { new-item -path $DossierCible -itemType Directory}

    $Param=@{Domain=$Domaine.Fqdn} 
    get-Gpo @param -all  | Backup-gpo @param -Path $DossierCible
}
#endregion backup des GPO en powershell


#region rapport sur les GPO du domaine courant
$param=@{}
#$param['domain']= $Domain
$ListeGpo=get-Gpo -all @param
$Dossier='d:\donapp\xinvtr\p00\dat\gpo'
if (-not (test-path $Dossier)) {new-item -path $Dossier -ItemType Directory}
$ListeGpo | Backup-gpo @param -Path $DossierCible 
#endregion rapport sur les GPO du domaine courant