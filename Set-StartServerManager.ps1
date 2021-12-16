<#
 .SYNOPSIS
    Désactiver le lancement du Gestionnaire de Serveurs ( Server Manager)
 .Description 
    Désactiver le lancement du Gestionnaire de Serveurs ( Server Manager) au lancement d'un serveur
 .NOTES
    C'est aussi possible de faire par GPO
    On va ici faire la configuration pour l'utilisateur courant.
    La configuration n'est poussé que si c'est nécessaire
#>

# Désactiver le lancement du gestionnaire de serveurs
try { $Res=get-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -ErrorAction SilentlyContinue} catch {$res=$Null}
$Sb={
    $Message='Désactiver le lancement du gestionnaire de serveurs'
    Write-Host $Message -ForegroundColor Yellow
    New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "0x1" –Force
}
if ($res.DoNotOpenServerManagerAtLogon -ne 1) { & $SB } else {
    $Message='Lancement du gestionnaire de serveurs : Désactivé'
    Write-Host $Message -ForegroundColor green
}
