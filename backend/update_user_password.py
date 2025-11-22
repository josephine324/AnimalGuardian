#!/usr/bin/env python
"""
Update user password.
"""
import requests
import json

BACKEND_URL = "https://animalguardian.onrender.com"

def update_password(email, new_password):
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
    
    user_id = user.get('id')
    print(f"[OK] User found: ID {user_id}")
    
    # Update password
    update_url = f"{BACKEND_URL}/api/users/{user_id}/"
    update_data = {
        "password": new_password,
        "password_confirm": new_password
    }
    
    update_response = requests.patch(update_url, headers=headers, json=update_data)
    
    if update_response.status_code == 200:
        print(f"[OK] Password updated successfully!")
        
        # Test login with new password
        print(f"\nTesting login with new password...")
        test_login = requests.post(login_url, json={
            "email": email,
            "password": new_password
        })
        
        if test_login.status_code == 200:
            print(f"[OK] Login successful with new password!")
        else:
            print(f"[FAIL] Login failed: {test_login.json()}")
    else:
        print(f"[FAIL] Password update failed: {update_response.status_code}")
        print(f"Response: {update_response.json()}")

if __name__ == '__main__':
    update_password('telesphore91073@gmail.com', '91073@Tecy')

