#!/usr/bin/env python
"""
Trigger profile creation via API endpoint.
"""
import requests
import json

BACKEND_URL = "https://animalguardian.onrender.com"

def trigger_create_profiles():
    # Login as admin
    login_url = f"{BACKEND_URL}/api/auth/login/"
    admin_login = requests.post(login_url, json={
        "email": "mutesijosephine324@gmail.com",
        "password": "Admin@123456"
    })
    
    if admin_login.status_code != 200:
        print(f"[FAIL] Cannot login as admin: {admin_login.status_code}")
        return
    
    token = admin_login.json()['access']
    headers = {'Authorization': f'Bearer {token}'}
    
    # Call the create_missing_profiles endpoint
    create_url = f"{BACKEND_URL}/api/veterinarians/create_missing_profiles/"
    response = requests.post(create_url, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        print(f"[OK] Profile creation triggered successfully!")
        print(f"Created: {data.get('created', 0)}")
        print(f"Skipped: {data.get('skipped', 0)}")
        print(f"Total: {data.get('total', 0)}")
    else:
        print(f"[FAIL] Error: {response.status_code}")
        print(f"Response: {response.json()}")

if __name__ == '__main__':
    trigger_create_profiles()

