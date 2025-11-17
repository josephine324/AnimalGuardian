# Script to pause OneDrive temporarily during builds
# This prevents file locking issues during Flutter builds

Write-Host "Pausing OneDrive sync..." -ForegroundColor Yellow

try {
    # Stop OneDrive process
    $onedriveProcesses = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
    if ($onedriveProcesses) {
        Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] OneDrive paused successfully" -ForegroundColor Green
        Write-Host "You can now run 'flutter run' without file locking issues" -ForegroundColor Cyan
        Write-Host "`nTo resume OneDrive, run: resume_onedrive.ps1" -ForegroundColor Yellow
        Write-Host "Or restart OneDrive from Start Menu" -ForegroundColor Yellow
    } else {
        Write-Host "OneDrive is not currently running" -ForegroundColor Green
    }
} catch {
    Write-Host "Error pausing OneDrive: $_" -ForegroundColor Red
    Write-Host "You may need to run this script as Administrator" -ForegroundColor Yellow
}

