<# 
 .SYNOPSIS
    Recherche des différences de sous dossier réciproques entre 2 dossiers
 .DESCRIPTION
    Search for reciprocal sub-folder differences between 2 folders
    Recherche des différences de sous dossier réciproques entre 2 dossiers ( avant de lancer une synchro)
 .PARAMETER Source
    Dossiers Origine / Source Directory
 .PARAMETER Cible
    Dossier Cible / Target Directory
 .EXAMPLE
    Find-DirDiff -Origine D:\test -Cible E:\test 
.EXAMPLE
    Find-DirDiff -Source D:\test -Target E:\test 

#>
 param (
    [parameter(mandatory=$False,Position=0)][alias('Source')][String]$Origine='T:\Domaine\MDBDATA\Divers\Photos\pers',
    [parameter(mandatory=$false,Position=1)][Alias('Target','Destination')] [String]$Cible='X:\Domaine\MDBDATA\Divers\Photos\Pers'    
 )

$Resume='Comparaison de répertoires en terme de dossiers enfants'
Write-host $Resume -ForegroundColor Yellow 

$Coul='Gray'
$DS=Get-ChildItem -Path $Origine -Directory
$Message='{0,-11} : {1} : [{2,6}]' -f 'Origine',$Origine, $DS.Count
Write-host $Message -ForegroundColor $Coul 

$DC=Get-ChildItem -Path $Cible -Directory
$Message='{0,-11} : {1} : [{2,6}]' -f 'Destination', $Cible, $DC.Count
Write-host $Message -ForegroundColor $Coul 

# Vérification dans la destination # PSChildName
$NBDS=0
foreach ($Dossier in $DS ) {
    $CiblePath=Join-path $Cible $Dossier.PSChildName 
    $w=$Dossier.PSChildName 
    $Message='Vérifier : {0}' -f $w 
    if (-not (test-path $CiblePath)) { Write-host $message ; $NBDS++}
}

# Vérification dans la destination # PSChildName
$NBDC=0
foreach ($Dossier in $DC ) {
    $CiblePath=Join-path $Source $Dossier.PSChildName 
    $w=$Dossier.PSChildName 
    $Message='Vérifier : {0}' -f $w 
    if (-not (test-path $CiblePath)) { Write-host $message ; $NBDC+1 }
}

if ($NBDS -eq 0 ) {
    $Message='Tous les dossiers Origine ont leur équivalent dans la Destination' ; 
    $Coul='Green'
} else {
    $Message='Il manque {0} dossier(s) dans la Destination' -f $NBDS ;
    $Coul='Yellow'
}
Write-host $Message -ForegroundColor $Coul 

if ($NBDC -eq 0 ) {
    $Message='Tous les dossiers Cible ont leur équivalent dans l''Origine' ; 
    $Coul='Green'
} else {
    $Message='Il manque {0} dossier(s) dans l''Origine.' -f $NBDC ;
    $Coul='Yellow'
}
Write-host $Message -ForegroundColor $Coul 



