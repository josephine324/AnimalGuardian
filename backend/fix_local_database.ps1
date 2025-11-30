# Fix .env file for local development (use SQLite instead of PostgreSQL)

$envFile = ".env"

if (Test-Path $envFile) {
    Write-Host "Reading current .env file..." -ForegroundColor Cyan
    
    # Read all lines
    $lines = Get-Content $envFile
    
    # Create new content
    $newLines = @()
    $databaseUrlFound = $false
    
    foreach ($line in $lines) {
        if ($line -match "^DATABASE_URL=") {
            # Comment out the production DATABASE_URL for local development
            $newLines += "# DATABASE_URL=postgresql://...  # Commented out for local development - using SQLite"
            $databaseUrlFound = $true
            Write-Host "Commented out DATABASE_URL (will use SQLite for local dev)" -ForegroundColor Yellow
        } else {
            $newLines += $line
        }
    }
    
    # If DATABASE_URL wasn't found, add a comment
    if (-not $databaseUrlFound) {
        $newLines += "# DATABASE_URL is not set - using SQLite for local development"
    }
    
    # Backup original
    $backupFile = ".env.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $envFile $backupFile
    Write-Host "Backed up original .env to: $backupFile" -ForegroundColor Green
    
    # Write new content
    $newLines | Set-Content $envFile
    Write-Host "Updated .env file for local development!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Now you can run: python manage.py runserver" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Note: For production, uncomment DATABASE_URL in .env" -ForegroundColor Yellow
} else {
    Write-Host ".env file not found. Creating new one..." -ForegroundColor Yellow
    
    $defaultEnv = @"
# Django Settings
SECRET_KEY=your-secret-key-here-change-this-in-production
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database (Leave empty for SQLite local development)
# DATABASE_URL=postgresql://...  # Uncomment for production

# CORS Settings
CORS_ALLOW_ALL_ORIGINS=True

# Email Configuration (for password reset)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com
"@
    
    $defaultEnv | Set-Content $envFile
    Write-Host "Created new .env file with SQLite configuration" -ForegroundColor Green
}

