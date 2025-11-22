#!/usr/bin/env python
"""
Check why a user cannot login.
"""
import requests
import json

BACKEND_URL = "https://animalguardian.onrender.com"

def check_user(email):
    # First login as admin
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
    
    # Get all users
    users_url = f"{BACKEND_URL}/api/users/"
    users_response = requests.get(users_url, headers=headers)
    
    if users_response.status_code != 200:
        print(f"[FAIL] Cannot get users: {users_response.status_code}")
        return
    
    users_data = users_response.json()
    # Handle both list and dict with results
    if isinstance(users_data, dict) and 'results' in users_data:
        users = users_data['results']
    elif isinstance(users_data, list):
        users = users_data
    else:
        users = []
    
    user = next((u for u in users if isinstance(u, dict) and u.get('email') == email), None)
    
    if not user:
        print(f"[FAIL] User with email {email} not found")
        return
    
    print(f"[OK] User found:")
    print(f"  ID: {user.get('id')}")
    print(f"  Email: {user.get('email')}")
    print(f"  Phone: {user.get('phone_number')}")
    print(f"  Username: {user.get('username')}")
    print(f"  User Type: {user.get('user_type')}")
    print(f"  Is Active: {user.get('is_active')}")
    print(f"  Is Verified: {user.get('is_verified')}")
    print(f"  Is Approved: {user.get('is_approved_by_admin')}")
    
    # Try to login with this user
    print(f"\nTesting login...")
    test_login = requests.post(login_url, json={
        "email": email,
        "password": "Test1234!"  # Try common password
    })
    
    print(f"Login Status: {test_login.status_code}")
    if test_login.status_code == 200:
        print("[OK] Login successful!")
    else:
        print(f"[FAIL] Login failed: {test_login.json()}")

if __name__ == '__main__':
    check_user('telesphore91073@gmail.com')

