#!/bin/bash
# Azure App Service startup script
set -e

echo "Starting AnimalGuardian backend on Azure..."

# Run migrations
echo "Running database migrations..."
python manage.py migrate --noinput --verbosity=2 || {
    echo "Standard migration failed, attempting to fix schema..."
    python fix_database_schema.py || {
        echo "Schema fix script failed, trying specific migration..."
        python manage.py migrate accounts 0006_rename_password_reset_code_to_token --noinput --verbosity=2 || true
        python manage.py migrate --noinput --verbosity=2
    }
}

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput || true

# Start gunicorn
echo "Starting Gunicorn..."
exec gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 600 --access-logfile - --error-logfile - animalguardian.wsgi:application

