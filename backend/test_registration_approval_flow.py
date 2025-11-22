#!/usr/bin/env python
"""
Test the registration and approval flow:
1. Register a local vet via API
2. Register a farmer via API
3. Verify they appear in pending approvals
4. Approve them
5. Verify they can login
"""
import requests
import json
import time

BACKEND_URL = "https://animalguardian.onrender.com"

def test_registration_approval_flow():
    print("=" * 70)
    print("TESTING REGISTRATION AND APPROVAL FLOW")
    print("=" * 70)
    
    # Step 1: Login as admin/sector vet
    print("\n1. Logging in as admin...")
    login_url = f"{BACKEND_URL}/api/auth/login/"
    admin_login = requests.post(login_url, json={
        "email": "mutesijosephine324@gmail.com",
        "password": "Admin@123456"
    })
    
    if admin_login.status_code != 200:
        print(f"[FAIL] Admin login failed: {admin_login.status_code}")
        return
    
    admin_token = admin_login.json()['access']
    headers = {'Authorization': f'Bearer {admin_token}'}
    print("[OK] Admin logged in successfully")
    
    # Step 2: Register a local vet
    print("\n2. Registering a local vet...")
    import random
    vet_email = f"test_local_vet_{random.randint(1000, 9999)}@test.com"
    vet_phone = f"+250788{random.randint(100000, 999999)}"
    
    register_data = {
        "first_name": "Test",
        "last_name": "Local Vet",
        "email": vet_email,
        "phone_number": vet_phone,
        "password": "Test1234!",
        "user_type": "local_vet"
    }
    
    register_response = requests.post(
        f"{BACKEND_URL}/api/auth/register/",
        json=register_data,
        timeout=10
    )
    
    if register_response.status_code == 201:
        vet_user_id = register_response.json().get('user_id')
        print(f"[OK] Local vet registered: {vet_email} (ID: {vet_user_id})")
    else:
        print(f"[FAIL] Local vet registration failed: {register_response.status_code}")
        print(f"Response: {register_response.json()}")
        return
    
    # Step 3: Register a farmer
    print("\n3. Registering a farmer...")
    farmer_phone = f"+250788{random.randint(100000, 999999)}"
    
    farmer_data = {
        "first_name": "Test",
        "last_name": "Farmer",
        "phone_number": farmer_phone,
        "password": "Test1234!",
        "user_type": "farmer"
    }
    
    farmer_response = requests.post(
        f"{BACKEND_URL}/api/auth/register/",
        json=farmer_data,
        timeout=10
    )
    
    if farmer_response.status_code == 201:
        farmer_user_id = farmer_response.json().get('user_id')
        print(f"[OK] Farmer registered: {farmer_phone} (ID: {farmer_user_id})")
    else:
        print(f"[FAIL] Farmer registration failed: {farmer_response.status_code}")
        print(f"Response: {farmer_response.json()}")
        return
    
    # Step 4: Verify OTP for both (using hardcoded OTP for testing)
    print("\n4. Verifying OTP for both users...")
    
    # Verify local vet OTP
    vet_otp_response = requests.post(
        f"{BACKEND_URL}/api/auth/verify-otp/",
        json={"email": vet_email, "otp_code": "123456"},
        timeout=10
    )
    if vet_otp_response.status_code == 200:
        print(f"[OK] Local vet OTP verified")
    else:
        print(f"[WARN] Local vet OTP verification: {vet_otp_response.status_code}")
    
    # Verify farmer OTP
    farmer_otp_response = requests.post(
        f"{BACKEND_URL}/api/auth/verify-otp/",
        json={"phone_number": farmer_phone, "otp_code": "123456"},
        timeout=10
    )
    if farmer_otp_response.status_code == 200:
        print(f"[OK] Farmer OTP verified")
    else:
        print(f"[WARN] Farmer OTP verification: {farmer_otp_response.status_code}")
    
    # Step 5: Check pending approvals
    print("\n5. Checking pending approvals...")
    time.sleep(2)  # Wait a bit for database to update
    
    pending_response = requests.get(
        f"{BACKEND_URL}/api/users/pending_approval/",
        headers=headers,
        timeout=10
    )
    
    if pending_response.status_code == 200:
        pending_users = pending_response.json()
        if isinstance(pending_users, dict) and 'results' in pending_users:
            pending_users = pending_users['results']
        elif not isinstance(pending_users, list):
            pending_users = []
        
        print(f"[OK] Found {len(pending_users)} pending users")
        
        # Check if our registered users are in the list
        vet_found = any(u.get('id') == vet_user_id for u in pending_users if isinstance(u, dict))
        farmer_found = any(u.get('id') == farmer_user_id for u in pending_users if isinstance(u, dict))
        
        print(f"  - Local vet in pending: {'YES' if vet_found else 'NO'}")
        print(f"  - Farmer in pending: {'YES' if farmer_found else 'NO'}")
        
        # List all pending users
        print("\n  Pending users:")
        for user in pending_users:
            if isinstance(user, dict):
                print(f"    - {user.get('first_name', '')} {user.get('last_name', '')} ({user.get('user_type')}) - ID: {user.get('id')}")
    else:
        print(f"[FAIL] Cannot get pending approvals: {pending_response.status_code}")
        print(f"Response: {pending_response.text[:200]}")
    
    # Step 6: Try to login before approval (should fail)
    print("\n6. Testing login before approval (should fail)...")
    
    vet_login_before = requests.post(
        login_url,
        json={"email": vet_email, "password": "Test1234!"},
        timeout=10
    )
    if vet_login_before.status_code == 403:
        print("[OK] Local vet login correctly blocked (pending approval)")
    else:
        print(f"[WARN] Local vet login status: {vet_login_before.status_code}")
    
    farmer_login_before = requests.post(
        login_url,
        json={"phone_number": farmer_phone, "password": "Test1234!"},
        timeout=10
    )
    if farmer_login_before.status_code == 403:
        print("[OK] Farmer login correctly blocked (pending approval)")
    else:
        print(f"[WARN] Farmer login status: {farmer_login_before.status_code}")
    
    # Step 7: Approve both users
    print("\n7. Approving both users...")
    
    approve_vet = requests.post(
        f"{BACKEND_URL}/api/users/{vet_user_id}/approve/",
        headers=headers,
        json={"notes": "Test approval"},
        timeout=10
    )
    if approve_vet.status_code == 200:
        print("[OK] Local vet approved")
    else:
        print(f"[FAIL] Failed to approve local vet: {approve_vet.status_code}")
    
    approve_farmer = requests.post(
        f"{BACKEND_URL}/api/users/{farmer_user_id}/approve/",
        headers=headers,
        json={"notes": "Test approval"},
        timeout=10
    )
    if approve_farmer.status_code == 200:
        print("[OK] Farmer approved")
    else:
        print(f"[FAIL] Failed to approve farmer: {approve_farmer.status_code}")
    
    # Step 8: Try to login after approval (should succeed)
    print("\n8. Testing login after approval (should succeed)...")
    
    vet_login_after = requests.post(
        login_url,
        json={"email": vet_email, "password": "Test1234!"},
        timeout=10
    )
    if vet_login_after.status_code == 200:
        print("[OK] Local vet can now login")
    else:
        print(f"[FAIL] Local vet login failed: {vet_login_after.status_code}")
        print(f"Response: {vet_login_after.json()}")
    
    farmer_login_after = requests.post(
        login_url,
        json={"phone_number": farmer_phone, "password": "Test1234!"},
        timeout=10
    )
    if farmer_login_after.status_code == 200:
        print("[OK] Farmer can now login")
    else:
        print(f"[FAIL] Farmer login failed: {farmer_login_after.status_code}")
        print(f"Response: {farmer_login_after.json()}")
    
    print("\n" + "=" * 70)
    print("TEST COMPLETE")
    print("=" * 70)
    print(f"\nTest credentials created:")
    print(f"  Local Vet: {vet_email} / Test1234!")
    print(f"  Farmer: {farmer_phone} / Test1234!")

if __name__ == '__main__':
    test_registration_approval_flow()

