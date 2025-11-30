# Start Django server for local development
# This script clears DATABASE_URL to force SQLite usage

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Django Server (Local Dev)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Clear DATABASE_URL to force SQLite
$env:DATABASE_URL = ""
Write-Host "✓ Cleared DATABASE_URL (will use SQLite)" -ForegroundColor Green

# Activate virtual environment if it exists
if (Test-Path "venv\Scripts\Activate.ps1") {
    Write-Host "✓ Activating virtual environment..." -ForegroundColor Green
    .\venv\Scripts\Activate.ps1
} else {
    Write-Host "⚠ Virtual environment not found. Using system Python." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting Django development server..." -ForegroundColor Cyan
Write-Host ""

# Run the server
python manage.py runserver

