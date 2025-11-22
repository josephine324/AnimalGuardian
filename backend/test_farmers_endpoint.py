#!/usr/bin/env python
"""
Test the farmers endpoint to see what error is occurring.
"""
import requests
import json

BACKEND_URL = "https://animalguardian.onrender.com"

def test_farmers_endpoint():
    # Login as admin
    login_url = f"{BACKEND_URL}/api/auth/login/"
    admin_login = requests.post(login_url, json={
        "email": "mutesijosephine324@gmail.com",
        "password": "Admin@123456"
    })
    
    if admin_login.status_code != 200:
        print(f"[FAIL] Cannot login as admin: {admin_login.status_code}")
        print(f"Response: {admin_login.text}")
        return
    
    token = admin_login.json()['access']
    headers = {'Authorization': f'Bearer {token}'}
    
    # Test farmers endpoint
    farmers_url = f"{BACKEND_URL}/api/farmers/"
    print(f"\nTesting: GET {farmers_url}")
    
    try:
        response = requests.get(farmers_url, headers=headers, timeout=10)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"[OK] Success! Returned {len(data) if isinstance(data, list) else 'data'}")
        else:
            print(f"[FAIL] Error: {response.status_code}")
            try:
                error_data = response.json()
                print(f"Error details: {json.dumps(error_data, indent=2)}")
            except:
                print(f"Error text: {response.text[:500]}")
    except Exception as e:
        print(f"[FAIL] Exception: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    test_farmers_endpoint()

