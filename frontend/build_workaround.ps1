# Workaround build script that handles OneDrive locking
# This script tries multiple approaches to get the build working

Write-Host "=== Flutter Build Workaround ===" -ForegroundColor Cyan

# Step 1: Ensure OneDrive is paused
Write-Host "Pausing OneDrive..." -ForegroundColor Yellow
Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 2: Kill all Java/Gradle processes
Write-Host "Stopping Java/Gradle processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*java*" -or $_.ProcessName -like "*gradle*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 3: Try to remove problematic directory with retry
$problemDir = "build\permission_handler_android"
if (Test-Path $problemDir) {
    Write-Host "Removing problematic directory (with retries)..." -ForegroundColor Yellow
    for ($i = 1; $i -le 5; $i++) {
        try {
            Remove-Item -Path $problemDir -Recurse -Force -ErrorAction Stop
            Write-Host "[OK] Directory removed on attempt $i" -ForegroundColor Green
            break
        } catch {
            Write-Host "Attempt $i failed, retrying..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            if ($i -eq 5) {
                Write-Host "Could not remove directory after 5 attempts" -ForegroundColor Red
                Write-Host "Recommendation: Move project outside OneDrive" -ForegroundColor Yellow
            }
        }
    }
}

# Step 4: Build with Gradle options that might help
Write-Host "Building with workaround options..." -ForegroundColor Yellow
Write-Host ""

$device = $args[0]
if (-not $device) {
    $device = "emulator-5554"
}

# Try building with --no-build-number to avoid some file operations
flutter run -d $device --no-build-number

