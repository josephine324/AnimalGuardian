# Force clean build directory - handles locked files
# Run this if you get file locking errors

Write-Host "Force cleaning build directory..." -ForegroundColor Yellow

# Stop all related processes
Write-Host "Stopping related processes..." -ForegroundColor Cyan
Get-Process | Where-Object {
    $_.ProcessName -like "*java*" -or 
    $_.ProcessName -like "*gradle*" -or 
    $_.ProcessName -like "*dart*" -or
    $_.ProcessName -like "*flutter*"
} | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 3

# Try to unlock files using handle.exe if available, or use PowerShell
$buildPath = Join-Path $PSScriptRoot "build"

if (Test-Path $buildPath) {
    Write-Host "Removing build directory..." -ForegroundColor Cyan
    
    # Try multiple deletion methods
    try {
        # Method 1: Standard delete
        Remove-Item -Path $buildPath -Recurse -Force -ErrorAction Stop
        Write-Host "[OK] Build directory removed" -ForegroundColor Green
    } catch {
        Write-Host "Standard delete failed, trying alternative methods..." -ForegroundColor Yellow
        
        # Method 2: Delete files individually
        try {
            Get-ChildItem -Path $buildPath -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path $buildPath -Force -ErrorAction SilentlyContinue
            Write-Host "[OK] Build directory removed using alternative method" -ForegroundColor Green
        } catch {
            Write-Host "Warning: Could not fully remove build directory" -ForegroundColor Red
            Write-Host "Some files may still be locked. Try:" -ForegroundColor Yellow
            Write-Host "1. Close all IDEs and editors" -ForegroundColor White
            Write-Host "2. Restart your computer" -ForegroundColor White
            Write-Host "3. Or move project outside OneDrive" -ForegroundColor White
        }
    }
}

# Clean Flutter cache
Write-Host "Cleaning Flutter cache..." -ForegroundColor Cyan
cd $PSScriptRoot
flutter clean 2>&1 | Out-Null

Write-Host "[OK] Force clean completed!" -ForegroundColor Green
Write-Host "You can now run: flutter run -d emulator-5554" -ForegroundColor Cyan

