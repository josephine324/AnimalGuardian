#!/usr/bin/env python
"""
Sync/Update account on production API.
This will create or update the account on the production server.
"""
import requests
import json
import sys

# Production API URL
PRODUCTION_API = 'https://animalguardian.onrender.com/api'

# Account details to sync
phone_number = '0780480780'
password = 'Aggyirakiza123'
first_name = 'Aggy'
last_name = 'Irakiza'
email = None

print("\n" + "="*60)
print("Syncing Account to Production")
print("="*60 + "\n")

# First, try to login to check if account exists
print("Step 1: Checking if account exists on production...")
try:
    login_response = requests.post(
        f'{PRODUCTION_API}/auth/login/',
        json={
            'phone_number': phone_number,
            'password': password
        },
        timeout=30
    )
    
    if login_response.status_code == 200:
        print("✓ Account exists and login works on production!")
        print("  No need to sync - account is already working.")
        sys.exit(0)
    elif login_response.status_code == 401:
        print("⚠️  Account exists but login failed (password might be different or account not approved)")
    elif login_response.status_code == 403:
        error_data = login_response.json()
        if 'pending_approval' in error_data:
            print("⚠️  Account exists but is pending approval")
        else:
            print(f"⚠️  Account exists but access denied: {error_data.get('error', 'Unknown error')}")
    else:
        print(f"⚠️  Account may not exist (status: {login_response.status_code})")
except Exception as e:
    print(f"⚠️  Could not check account status: {e}")

print("\nStep 2: Attempting to register/update account on production...")
print("Note: This will create a NEW account if it doesn't exist.")
print("      If account exists, you'll need to update it manually via admin panel.\n")

# Try to register the account
registration_data = {
    'phone_number': phone_number,
    'password': password,
    'first_name': first_name,
    'last_name': last_name,
    'user_type': 'local_vet'
}

if email:
    registration_data['email'] = email

try:
    register_response = requests.post(
        f'{PRODUCTION_API}/auth/register/',
        json=registration_data,
        headers={'Content-Type': 'application/json'},
        timeout=30
    )
    
    if register_response.status_code == 201:
        print("✓ Account created successfully on production!")
        print("  Account is now pending approval by a sector veterinarian.")
        print("  Go to production dashboard to approve it.")
    elif register_response.status_code == 400:
        error_data = register_response.json()
        if 'already exists' in str(error_data).lower():
            print("⚠️  Account already exists on production")
            print("\nOptions:")
            print("  1. Login to production admin panel and approve the account")
            print("     URL: https://animalguardian.onrender.com/admin/")
            print("  2. Or approve via dashboard: https://animalguardian.onrender.com/user-approval")
            print("\nTo approve:")
            print("  - Find user by phone: 0780480780")
            print("  - Check 'Active' and 'Approved by admin'")
            print("  - Save")
        else:
            print(f"❌ Registration failed: {error_data}")
    else:
        print(f"❌ Unexpected response: {register_response.status_code}")
        print(f"   Response: {register_response.text[:200]}")
except Exception as e:
    print(f"❌ Error syncing to production: {e}")
    print("\nManual steps:")
    print("  1. Go to: https://animalguardian.onrender.com/admin/")
    print("  2. Login as admin/sector vet")
    print("  3. Create or find the user")
    print("  4. Approve the account")

print("\n" + "="*60 + "\n")

