#!/bin/bash
set -e

# Run migrations (with verbosity for debugging)
echo "Running database migrations..."
python manage.py migrate --noinput --verbosity=2 || {
    echo "Standard migration failed, attempting to fix schema..."
    # Try to fix the schema issue directly
    python fix_database_schema.py || {
        echo "Schema fix script failed, trying specific migration..."
        python manage.py migrate accounts 0006_rename_password_reset_code_to_token --noinput --verbosity=2 || true
        # Try all migrations again
        python manage.py migrate --noinput --verbosity=2
    }
}

# Get port from environment variable, default to 8000
PORT=${PORT:-8000}

# Start gunicorn
exec gunicorn animalguardian.wsgi:application --bind 0.0.0.0:$PORT

