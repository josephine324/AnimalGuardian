# Script to move project outside OneDrive to avoid file locking issues
# This is the BEST solution for development

$sourcePath = "C:\Users\Administrator\OneDrive\Desktop\AnimalGuardian"
$targetPath = "C:\Projects\AnimalGuardian"

Write-Host "=== Moving Project Outside OneDrive ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Source: $sourcePath" -ForegroundColor Yellow
Write-Host "Target: $targetPath" -ForegroundColor Yellow
Write-Host ""

# Check if target directory exists
if (Test-Path $targetPath) {
    $response = Read-Host "Target directory already exists. Overwrite? (y/n)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Operation cancelled." -ForegroundColor Red
        exit
    }
    Remove-Item -Path $targetPath -Recurse -Force -ErrorAction SilentlyContinue
}

# Create target directory
New-Item -ItemType Directory -Path "C:\Projects" -Force -ErrorAction SilentlyContinue | Out-Null

Write-Host "Copying project (this may take a few minutes)..." -ForegroundColor Cyan

# Copy project excluding build directories
robocopy $sourcePath $targetPath /E /XD build .dart_tool node_modules venv __pycache__ /XF *.lock /R:3 /W:5 /NP

if ($LASTEXITCODE -le 1) {
    Write-Host ""
    Write-Host "[OK] Project copied successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Close this terminal" -ForegroundColor White
    Write-Host "2. Open new terminal in: $targetPath\frontend" -ForegroundColor White
    Write-Host "3. Run: flutter run -d emulator-5554" -ForegroundColor White
    Write-Host ""
    Write-Host "The project is now at: $targetPath" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Error copying project. Exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host "You may need to run this script as Administrator" -ForegroundColor Yellow
}

