#!/usr/bin/env python
"""
Create VeterinarianProfile for all veterinarians via API (for Railway database).
"""
import requests
import json
import secrets

BACKEND_URL = "https://animalguardian.onrender.com"

def create_profiles_via_api():
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
    
    # Filter veterinarians
    vets = [u for u in users if isinstance(u, dict) and u.get('user_type') in ['local_vet', 'sector_vet']]
    
    print(f"\n{'='*70}")
    print(f"Creating Veterinarian Profiles via API")
    print(f"{'='*70}\n")
    
    created_count = 0
    skipped_count = 0
    failed_count = 0
    
    for vet in vets:
        vet_id = vet.get('id')
        email = vet.get('email', 'N/A')
        
        # Check if profile already exists
        if vet.get('veterinarian_profile'):
            print(f"[SKIP] {email} already has a profile")
            skipped_count += 1
            continue
        
        # Try to create profile via the profile endpoint
        # First, let's try to get the profile endpoint to see if it exists
        profile_url = f"{BACKEND_URL}/api/veterinarians/{vet_id}/profile/"
        
        # Actually, we need to create the profile via a different method
        # Since there's no direct API endpoint to create profiles, we'll need to
        # use Django admin or create a management command
        # For now, let's check if we can update the user to trigger profile creation
        
        print(f"[INFO] {email} (ID: {vet_id}) needs a profile")
        print(f"       Note: Profile creation requires backend script execution on Railway")
        failed_count += 1
    
    print(f"\n{'='*70}")
    print(f"Summary:")
    print(f"  Created: {created_count}")
    print(f"  Skipped: {skipped_count}")
    print(f"  Needs Creation: {failed_count}")
    print(f"  Total: {len(vets)}")
    print(f"\n{'='*70}")
    print(f"To create profiles on Railway, run:")
    print(f"  railway run python backend/create_missing_vet_profiles.py")
    print(f"{'='*70}\n")

if __name__ == '__main__':
    create_profiles_via_api()

