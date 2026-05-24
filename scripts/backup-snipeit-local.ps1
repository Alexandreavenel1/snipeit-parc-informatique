$ErrorActionPreference = "Stop"

# Chemins locaux
$ProjectPath = "C:\snipeit-test"
$BackupRoot = "C:\snipeit-backups"

# Dossier interne standard des sauvegardes Snipe-IT
$BackupPathInContainer = "/var/www/html/storage/app/backups"

# Horodatage de la sauvegarde
$Stamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$RunDir = Join-Path $BackupRoot $Stamp

New-Item -ItemType Directory -Force -Path $RunDir | Out-Null

Set-Location $ProjectPath

Write-Host "Recherche du conteneur Snipe-IT..."

# Détection automatique du service applicatif Snipe-IT
$Services = docker compose config --services

$AppService = $null
$AppContainer = $null

foreach ($Service in $Services) {
    $ContainerId = docker compose ps -q $Service 2>$null

    if (-not [string]::IsNullOrWhiteSpace($ContainerId)) {
        $Image = docker inspect -f "{{.Config.Image}}" $ContainerId 2>$null

        if ($Image -like "*snipe/snipe-it*") {
            $AppService = $Service
            $AppContainer = $ContainerId
            break
        }
    }
}

if ([string]::IsNullOrWhiteSpace($AppService)) {
    throw "Impossible de trouver automatiquement le conteneur Snipe-IT. Vérifie que docker compose up -d a bien été lancé."
}

Write-Host "Service Snipe-IT détecté : $AppService"
Write-Host "Conteneur : $AppContainer"

Write-Host ""
Write-Host "Lancement de la sauvegarde interne Snipe-IT..."

docker compose exec -T $AppService php artisan snipeit:backup

Write-Host ""
Write-Host "Recherche de la dernière archive générée..."

$LatestBackup = docker compose exec -T $AppService sh -lc "ls -t $BackupPathInContainer/*.zip 2>/dev/null | head -n 1"
$LatestBackup = $LatestBackup.Trim()

if ([string]::IsNullOrWhiteSpace($LatestBackup)) {
    throw "Aucune archive de sauvegarde trouvée dans $BackupPathInContainer"
}

$BackupFileName = $LatestBackup.Split('/')[-1]
$DestZip = Join-Path $RunDir $BackupFileName

Write-Host "Archive trouvée : $BackupFileName"
Write-Host "Copie vers : $DestZip"

docker cp "${AppContainer}:$LatestBackup" "$DestZip"

Write-Host ""
Write-Host "Copie des fichiers de configuration nécessaires à une restauration..."

Copy-Item ".env" (Join-Path $RunDir ".env") -Force
Copy-Item "docker-compose.yml" (Join-Path $RunDir "docker-compose.yml") -Force

$Manifest = @"
Date sauvegarde : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Projet : $ProjectPath
Service Snipe-IT : $AppService
Conteneur app : $AppContainer
Archive Snipe-IT : $BackupFileName

Contenu :
- Archive Snipe-IT générée par php artisan snipeit:backup
- Fichier .env réel
- docker-compose.yml

ATTENTION :
Ce dossier contient le fichier .env avec des secrets.
Ne jamais envoyer ce dossier sur GitHub.
Ne pas partager non chiffré.
"@

$Manifest | Out-File -Encoding UTF8 (Join-Path $RunDir "MANIFEST.txt")

Write-Host ""
Write-Host "Sauvegarde terminée avec succès."
Write-Host "Dossier de sauvegarde : $RunDir"