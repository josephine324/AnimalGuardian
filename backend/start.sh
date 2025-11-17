#!/bin/bash
set -e

# Run migrations
python manage.py migrate --noinput

# Get port from environment variable, default to 8000
PORT=${PORT:-8000}

# Start gunicorn
exec gunicorn animalguardian.wsgi:application --bind 0.0.0.0:$PORT

