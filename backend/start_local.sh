#!/bin/bash
# Start Django server for local development
# This script clears DATABASE_URL to force SQLite usage

echo "========================================"
echo "Starting Django Server (Local Dev)"
echo "========================================"
echo ""

# Clear DATABASE_URL to force SQLite
export DATABASE_URL=""
echo "✓ Cleared DATABASE_URL (will use SQLite)"

# Activate virtual environment if it exists
if [ -f "venv/Scripts/activate" ]; then
    echo "✓ Activating virtual environment..."
    source venv/Scripts/activate
elif [ -f "venv/bin/activate" ]; then
    echo "✓ Activating virtual environment..."
    source venv/bin/activate
else
    echo "⚠ Virtual environment not found. Using system Python."
fi

echo ""
echo "Starting Django development server..."
echo ""

# Run the server
python manage.py runserver

