# Script to run seed_livestock_types on Render using CLI
# Usage: Set RENDERCLI_APIKEY environment variable first

$env:HOME = $env:USERPROFILE

# Set API key (will be provided by user)
# $env:RENDERCLI_APIKEY = "rnd_xxxxxxxxxxxxx"

Write-Output "Step 1: Listing services to find animalguardian-backend..."
cd C:\Users\Administrator\Downloads
.\render.exe services list --name "animalguardian-backend" --format json

Write-Output "`nStep 2: Getting service ID..."
$services = .\render.exe services list --name "animalguardian-backend" --format json | ConvertFrom-Json
$serviceId = $services[0].id

Write-Output "Service ID: $serviceId"

Write-Output "`nStep 3: Running seed command via SSH..."
.\render.exe services ssh --id $serviceId "cd backend && python manage.py seed_livestock_types"

Write-Output "`nDone! Livestock types should now be seeded."

