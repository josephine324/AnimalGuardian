#!/usr/bin/env python
"""
Test script to diagnose login issues on Railway backend.
"""
import requests
import json
import sys

# Railway backend URL
BACKEND_URL = "https://animalguardian-backend-production.up.railway.app"

def test_login():
    """Test login with provided credentials."""
    email = "mutesijosephine324@gmail.com"
    password = "Admin@123456"
    
    login_url = f"{BACKEND_URL}/api/auth/login/"
    
    print("=" * 60)
    print("Testing Login to Railway Backend")
    print("=" * 60)
    print(f"URL: {login_url}")
    print(f"Email: {email}")
    print(f"Password: {'*' * len(password)}")
    print("=" * 60)
    print()
    
    # Test login with email
    print("Attempting login with email...")
    try:
        response = requests.post(
            login_url,
            json={
                "email": email,
                "password": password
            },
            headers={
                "Content-Type": "application/json"
            },
            timeout=30
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        print()
        
        response_data = None
        try:
            response_data = response.json()
            print("Response JSON:")
            print(json.dumps(response_data, indent=2))
        except:
            print("Response Text (not JSON):")
            print(response.text[:500])  # First 500 chars
        
        print()
        print("=" * 60)
        
        if response.status_code == 200:
            print("[OK] Login successful!")
            if response_data and 'access' in response_data:
                print(f"Access token received: {response_data['access'][:50]}...")
            return True
        elif response.status_code == 500:
            print("[ERROR] 500 Internal Server Error")
            print("\nThis indicates a server-side error. Possible causes:")
            print("1. Database schema mismatch (password_reset_code vs password_reset_token)")
            print("2. Database connection issue")
            print("3. Code error in the login view")
            print("\nCheck Railway logs for detailed error information.")
            
            # Try to get more details if DEBUG mode is on and we have JSON
            if response_data:
                if 'error' in response_data or 'detail' in response_data:
                    print("\nError details from server:")
                    if 'error' in response_data:
                        print(f"  Error: {response_data['error']}")
                    if 'detail' in response_data:
                        print(f"  Detail: {response_data['detail']}")
            
            return False
        elif response.status_code == 401:
            print("[ERROR] 401 Unauthorized - Invalid credentials")
            return False
        else:
            print(f"[ERROR] Unexpected status code: {response.status_code}")
            return False
            
    except requests.exceptions.ConnectionError as e:
        print(f"[ERROR] Connection Error: {e}")
        print("Cannot connect to Railway backend. Check if the service is running.")
        return False
    except requests.exceptions.Timeout as e:
        print(f"[ERROR] Timeout Error: {e}")
        print("Request timed out. The backend might be slow or unresponsive.")
        return False
    except Exception as e:
        print(f"[ERROR] Unexpected Error: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_health_check():
    """Test health check endpoint to see if backend is running."""
    health_url = f"{BACKEND_URL}/api/dashboard/health/"
    
    print("\n" + "=" * 60)
    print("Testing Health Check Endpoint")
    print("=" * 60)
    print(f"URL: {health_url}")
    print("=" * 60)
    print()
    
    try:
        response = requests.get(health_url, timeout=10)
        print(f"Status Code: {response.status_code}")
        
        try:
            health_data = response.json()
            print("Health Check Response:")
            print(json.dumps(health_data, indent=2))
            
            if 'schema' in health_data:
                schema = health_data['schema']
                if schema.get('schema_issue'):
                    print("\n[WARNING] Database schema issue detected!")
                    print("   The password_reset_code column exists but password_reset_token doesn't.")
                    print("   Run fix_database_schema.py to fix this.")
        except:
            print("Response Text:")
            print(response.text)
            
    except Exception as e:
        print(f"[ERROR] Error checking health: {e}")

if __name__ == '__main__':
    # Test health check first
    test_health_check()
    
    # Then test login
    print("\n")
    success = test_login()
    
    sys.exit(0 if success else 1)

