# Script to resume OneDrive sync after builds

Write-Host "Resuming OneDrive sync..." -ForegroundColor Yellow

try {
    # Start OneDrive
    $onedrivePath = "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
    if (Test-Path $onedrivePath) {
        Start-Process $onedrivePath
        Write-Host "[OK] OneDrive resumed successfully" -ForegroundColor Green
    } else {
        Write-Host "OneDrive executable not found at: $onedrivePath" -ForegroundColor Red
        Write-Host "Please start OneDrive manually from Start Menu" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error resuming OneDrive: $_" -ForegroundColor Red
    Write-Host "Please start OneDrive manually from Start Menu" -ForegroundColor Yellow
}

