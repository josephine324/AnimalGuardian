#!/bin/bash
# Render-specific startup script
# This script is optimized for Render deployment

echo "========================================="
echo "Starting AnimalGuardian Backend on Render"
echo "========================================="

# Run migrations (silent mode for faster startup)
echo "Running database migrations..."
python manage.py migrate --noinput --verbosity=0 || {
    echo "⚠ Migration failed, retrying..."
    python manage.py migrate --noinput --verbosity=1 || {
        echo "❌ Migration failed. Check logs."
        exit 1
    }
}

# Get port from environment variable (Render sets this automatically)
PORT=${PORT:-8000}

# Start gunicorn with optimized settings for Render
# Workers: 2 (optimal for free tier)
# Threads: 2 per worker
# Timeout: 120 seconds
exec gunicorn animalguardian.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 2 \
    --threads 2 \
    --worker-class gthread \
    --timeout 120 \
    --keep-alive 5 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    --preload \
    --access-logfile - \
    --error-logfile - \
    --log-level info

