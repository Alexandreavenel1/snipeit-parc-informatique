$ErrorActionPreference = "Stop"

$ProjectPath = "C:\snipeit-test"
$BackupScript = Join-Path $ProjectPath "scripts\backup-snipeit-local.ps1"

Set-Location $ProjectPath

Write-Host "Sauvegarde avant arrêt de Snipe-IT..."

if (-not (Test-Path $BackupScript)) {
    throw "Script de sauvegarde introuvable : $BackupScript"
}

powershell -ExecutionPolicy Bypass -File $BackupScript

Write-Host ""
Write-Host "Sauvegarde terminée. Arrêt des conteneurs..."

docker compose stop

Write-Host ""
Write-Host "Snipe-IT est arrêté proprement après sauvegarde."