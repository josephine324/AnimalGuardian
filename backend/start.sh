#!/bin/bash
set -e

# Run migrations (with verbosity for debugging)
echo "Running database migrations..."
python manage.py migrate --noinput --verbosity=2

# If migration fails, try to run the specific migration
if [ $? -ne 0 ]; then
    echo "Standard migration failed, attempting to run specific migration..."
    python manage.py migrate accounts 0006_rename_password_reset_code_to_token --noinput --verbosity=2 || true
    # Try all migrations again
    python manage.py migrate --noinput --verbosity=2
fi

# Get port from environment variable, default to 8000
PORT=${PORT:-8000}

# Start gunicorn
exec gunicorn animalguardian.wsgi:application --bind 0.0.0.0:$PORT

