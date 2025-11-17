# Script to exclude build folder from OneDrive sync
# Run this script as Administrator for best results

Write-Host "Excluding build folder from OneDrive sync..." -ForegroundColor Green

$buildPath = Join-Path $PSScriptRoot "build"
$onedrivePath = $env:OneDrive

if (-not $onedrivePath) {
    Write-Host "OneDrive path not found. Trying alternative method..." -ForegroundColor Yellow
    $onedrivePath = "$env:USERPROFILE\OneDrive"
}

if (Test-Path $buildPath) {
    Write-Host "Build folder found at: $buildPath" -ForegroundColor Cyan
    
    # Method 1: Use attrib command to mark as not for sync
    Write-Host "Attempting to exclude folder using file attributes..." -ForegroundColor Yellow
    try {
        attrib +U "$buildPath" /S /D 2>$null
        Write-Host "[OK] Applied attributes to build folder" -ForegroundColor Green
    } catch {
        Write-Host "Could not apply attributes: $_" -ForegroundColor Red
    }
}

# Method 2: Create a .onedriveignore file (if supported)
$ignoreFile = Join-Path $PSScriptRoot ".onedriveignore"
if (-not (Test-Path $ignoreFile)) {
    @"
# OneDrive ignore file
# This file tells OneDrive to ignore these patterns
build/
.dart_tool/
*.lock
"@ | Out-File -FilePath $ignoreFile -Encoding UTF8
    Write-Host "[OK] Created .onedriveignore file" -ForegroundColor Green
}

# Method 3: Instructions for manual exclusion
Write-Host "`n=== Manual Steps (Recommended) ===" -ForegroundColor Cyan
Write-Host "1. Open File Explorer and navigate to:" -ForegroundColor White
Write-Host "   $PSScriptRoot" -ForegroundColor Yellow
Write-Host "2. Right-click on the 'build' folder" -ForegroundColor White
Write-Host "3. Select 'Always keep on this device' (if available)" -ForegroundColor White
Write-Host "   OR" -ForegroundColor White
Write-Host "4. Open OneDrive Settings:" -ForegroundColor White
Write-Host "   - Click OneDrive icon in system tray" -ForegroundColor White
Write-Host "   - Click Settings > Sync and backup" -ForegroundColor White
Write-Host "   - Click 'Advanced settings'" -ForegroundColor White
Write-Host "   - Click 'Choose folders' and uncheck 'build' folder" -ForegroundColor White
Write-Host "`n=== Alternative: Pause OneDrive During Builds ===" -ForegroundColor Cyan
Write-Host "Run this command before building:" -ForegroundColor White
Write-Host "  Stop-Process -Name 'OneDrive' -Force -ErrorAction SilentlyContinue" -ForegroundColor Yellow
Write-Host "`nAfter build completes, restart OneDrive from Start Menu" -ForegroundColor White

Write-Host "`n[OK] Script completed!" -ForegroundColor Green

