#!/usr/bin/env python3
"""
Database keep-alive script
Pings the database periodically to prevent it from going to sleep
Run this as a background task or cron job
"""
import os
import sys
import django
import time
import requests
from datetime import datetime

# Setup Django
sys.path.append(os.path.dirname(__file__))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from django.db import connection

def ping_database():
    """Ping the database to keep connection alive"""
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        print(f"[{datetime.now()}] Database ping successful")
        return True
    except Exception as e:
        print(f"[{datetime.now()}] Database ping failed: {e}")
        return False

def ping_health_endpoint():
    """Ping the health check endpoint"""
    try:
        # Get backend URL from environment or use default
        backend_url = os.environ.get(
            'BACKEND_URL',
            'https://animalguardian-backend-production-b5a8.up.railway.app'
        )
        response = requests.get(f"{backend_url}/api/dashboard/health/", timeout=10)
        if response.status_code == 200:
            print(f"[{datetime.now()}] Health endpoint ping successful")
            return True
        else:
            print(f"[{datetime.now()}] Health endpoint returned status {response.status_code}")
            return False
    except Exception as e:
        print(f"[{datetime.now()}] Health endpoint ping failed: {e}")
        return False

def keep_alive_loop(interval_minutes=5):
    """Run keep-alive loop"""
    interval_seconds = interval_minutes * 60
    print(f"Starting database keep-alive service (pinging every {interval_minutes} minutes)")
    print("Press Ctrl+C to stop")
    
    while True:
        try:
            # Ping database directly
            ping_database()
            
            # Also ping health endpoint (which also pings database)
            ping_health_endpoint()
            
            # Wait for next interval
            time.sleep(interval_seconds)
        except KeyboardInterrupt:
            print("\nStopping keep-alive service...")
            break
        except Exception as e:
            print(f"[{datetime.now()}] Error in keep-alive loop: {e}")
            time.sleep(interval_seconds)

if __name__ == "__main__":
    # Default to 5 minutes, can be overridden with command line argument
    interval = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    keep_alive_loop(interval)

