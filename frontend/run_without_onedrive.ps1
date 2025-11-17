# Script to run Flutter app while OneDrive is paused
# This prevents build file locking issues

param(
    [string]$Device = "emulator-5554"
)

Write-Host "=== Flutter Build with OneDrive Paused ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Pause OneDrive
Write-Host "Step 1: Pausing OneDrive..." -ForegroundColor Yellow
$onedriveProcesses = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
if ($onedriveProcesses) {
    Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] OneDrive paused" -ForegroundColor Green
    $onedriveWasRunning = $true
} else {
    Write-Host "OneDrive is not running" -ForegroundColor Green
    $onedriveWasRunning = $false
}

Write-Host ""

# Step 2: Clean build if needed
$cleanBuild = Read-Host "Do you want to clean build first? (y/n)"
if ($cleanBuild -eq "y" -or $cleanBuild -eq "Y") {
    Write-Host "Cleaning build..." -ForegroundColor Yellow
    flutter clean
    Write-Host "[OK] Build cleaned" -ForegroundColor Green
    Write-Host ""
}

# Step 3: Run Flutter app
Write-Host "Step 2: Running Flutter app on device: $Device" -ForegroundColor Yellow
Write-Host ""

try {
    flutter run -d $Device
} finally {
    # Step 4: Resume OneDrive if it was running
    if ($onedriveWasRunning) {
        Write-Host ""
        Write-Host "Resuming OneDrive..." -ForegroundColor Yellow
        $onedrivePath = "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
        if (Test-Path $onedrivePath) {
            Start-Process $onedrivePath
            Write-Host "[OK] OneDrive resumed" -ForegroundColor Green
        }
    }
}

