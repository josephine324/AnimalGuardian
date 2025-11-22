# PowerShell script to start backend with SQLite
cd $PSScriptRoot

# Activate virtual environment
if (Test-Path .\venv\Scripts\Activate.ps1) {
    .\venv\Scripts\Activate.ps1
}

# Remove DATABASE_URL to force SQLite
Remove-Item Env:\DATABASE_URL -ErrorAction SilentlyContinue

# Start the server
Write-Host "Starting Django backend with SQLite database..."
Write-Host "Server will be available at: http://localhost:8000"
Write-Host ""
python manage.py runserver

