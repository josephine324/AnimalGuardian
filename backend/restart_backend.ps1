# PowerShell script to restart the backend with CORS fix
Write-Host "========================================"
Write-Host "Restarting Django Backend Server"
Write-Host "========================================"
Write-Host ""

# Navigate to backend directory
cd $PSScriptRoot

# Activate virtual environment
if (Test-Path .\venv\Scripts\Activate.ps1) {
    Write-Host "Activating virtual environment..."
    .\venv\Scripts\Activate.ps1
} else {
    Write-Host "ERROR: Virtual environment not found!"
    exit 1
}

# Remove DATABASE_URL to force SQLite
Write-Host "Configuring for SQLite database..."
Remove-Item Env:\DATABASE_URL -ErrorAction SilentlyContinue

# Start the server
Write-Host ""
Write-Host "Starting Django backend server..."
Write-Host "Server will be available at: http://localhost:8000"
Write-Host "API endpoint: http://localhost:8000/api"
Write-Host ""
Write-Host "Press Ctrl+C to stop the server"
Write-Host "========================================"
Write-Host ""

python manage.py runserver

