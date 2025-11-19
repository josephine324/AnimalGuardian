#!/usr/bin/env python
"""
Check all veterinarians and their profiles.
"""
import requests
import json

BACKEND_URL = "https://animalguardian-backend-production-b5a8.up.railway.app"

def check_veterinarians():
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
    print(f"VETERINARIANS REPORT")
    print(f"{'='*70}")
    print(f"\nTotal Veterinarians: {len(vets)}")
    print(f"\n{'='*70}\n")
    
    for i, vet in enumerate(vets, 1):
        print(f"Veterinarian #{i}:")
        print(f"  ID: {vet.get('id')}")
        print(f"  Name: {vet.get('first_name', '')} {vet.get('last_name', '')}")
        print(f"  Email: {vet.get('email', 'N/A')}")
        print(f"  Phone: {vet.get('phone_number', 'N/A')}")
        print(f"  User Type: {vet.get('user_type')}")
        print(f"  Is Active: {vet.get('is_active')}")
        print(f"  Is Verified: {vet.get('is_verified')}")
        print(f"  Is Approved: {vet.get('is_approved_by_admin')}")
        
        # Check for profile
        vet_profile = vet.get('veterinarian_profile')
        if vet_profile:
            print(f"  Profile: EXISTS")
            print(f"    License: {vet_profile.get('license_number', 'N/A')}")
            print(f"    Specialization: {vet_profile.get('specialization', 'N/A')}")
            print(f"    Available: {vet_profile.get('is_available', 'N/A')}")
        else:
            print(f"  Profile: MISSING (needs to be created)")
        
        print()
    
    # Get veterinarians via /veterinarians/ endpoint
    print(f"{'='*70}")
    print(f"Checking /veterinarians/ endpoint...")
    print(f"{'='*70}\n")
    
    vets_url = f"{BACKEND_URL}/api/veterinarians/"
    vets_response = requests.get(vets_url, headers=headers)
    
    if vets_response.status_code == 200:
        vets_data = vets_response.json()
        if isinstance(vets_data, dict) and 'results' in vets_data:
            vets_list = vets_data['results']
        elif isinstance(vets_data, list):
            vets_list = vets_data
        else:
            vets_list = []
        
        print(f"Veterinarians endpoint returned: {len(vets_list)} veterinarians")
        for vet in vets_list:
            print(f"  - {vet.get('first_name', '')} {vet.get('last_name', '')} ({vet.get('email', 'N/A')})")
    else:
        print(f"[FAIL] Cannot get veterinarians: {vets_response.status_code}")
        print(f"Response: {vets_response.json()}")

if __name__ == '__main__':
    check_veterinarians()

