"""
Test Approval Functionality with Real Data
1. Create a user (farmer or local vet) via API
2. Login as Sector Vet
3. Approve the user via API
4. Verify user can now login
"""

import requests
import json
from datetime import datetime

API_BASE_URL = "http://localhost:8000/api"

def print_section(title):
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60)

def print_result(success, message, data=None):
    status = "[PASS]" if success else "[FAIL]"
    print(f"{status}: {message}")
    if data and not success:
        print(f"   Error: {json.dumps(data, indent=2)}")

def create_test_user(user_type="farmer"):
    """Create a test user that needs approval"""
    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    
    test_user = {
        "username": f"test_{user_type}_{timestamp}",
        "phone_number": f"+250788{timestamp[-6:]}",
        "email": f"test_{user_type}_{timestamp}@test.com",
        "first_name": "Test",
        "last_name": user_type.title(),
        "password": "Test@123456",
        "password_confirm": "Test@123456",
        "user_type": user_type,
        "gender": "M",
        "province": "Eastern Province",
        "district": "Nyagatare",
        "sector": "Nyagatare",
        "preferred_language": "en"
    }
    
    try:
        response = requests.post(
            f"{API_BASE_URL}/auth/register/",
            json=test_user,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if response.status_code == 201:
            data = response.json()
            user_id = data.get('user_id')
            print_result(True, f"Created {user_type} user with ID: {user_id}")
            return user_id, test_user
        else:
            error_data = response.json()
            print_result(False, f"Failed to create user: {response.status_code}", error_data)
            return None, None
    except Exception as e:
        print_result(False, f"Error creating user: {str(e)}")
        return None, None

def login_sector_vet():
    """Login as sector vet to get auth token"""
    # Try multiple possible sector vet credentials
    possible_credentials = [
        {"phone_number": "+250780570632", "password": "admin123"},
        {"phone_number": "+250123456789", "password": "admin123"},
        {"phone_number": "admin", "password": "admin123"},
    ]
    
    for sector_vet_data in possible_credentials:
    
    try:
        response = requests.post(
            f"{API_BASE_URL}/auth/login/",
            json=sector_vet_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
            if response.status_code == 200:
                data = response.json()
                token = data.get('access')
                user_data = data.get('user', {})
                user_type = user_data.get('user_type')
                
                # Check if user is sector vet or admin
                if user_type in ['sector_vet', 'admin'] or user_data.get('is_staff'):
                    print_result(True, f"Logged in as: {user_data.get('username')} ({user_type})")
                    return token, user_data
                else:
                    print(f"   User {user_data.get('username')} is not sector vet/admin (type: {user_type}), trying next...")
                    continue
            else:
                continue
        except Exception as e:
            continue
    
    print_result(False, "Could not login as sector vet with any known credentials")
    print("   Please create a sector vet account or update credentials in test script")
    return None, None

def approve_user(user_id, auth_token):
    """Approve a user"""
    try:
        response = requests.post(
            f"{API_BASE_URL}/accounts/users/{user_id}/approve/",
            json={"notes": "Test approval"},  # Backend expects "notes" not "approval_notes"
            headers={
                "Authorization": f"Bearer {auth_token}",
                "Content-Type": "application/json"
            },
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            print_result(True, f"User {user_id} approved successfully")
            return True
        else:
            error_data = response.json()
            print_result(False, f"Approval failed: {response.status_code}", error_data)
            return False
    except Exception as e:
        print_result(False, f"Error approving user: {str(e)}")
        return False

def verify_user_can_login(phone_number, password):
    """Verify user can login after approval"""
    try:
        response = requests.post(
            f"{API_BASE_URL}/auth/login/",
            json={
                "phone_number": phone_number,
                "password": password
            },
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            print_result(True, "User can now login after approval")
            return True
        elif response.status_code == 403:
            error_data = response.json()
            if "pending approval" in error_data.get('error', '').lower():
                print_result(False, "User still pending approval")
            else:
                print_result(False, f"Login blocked: {error_data.get('error')}")
            return False
        else:
            error_data = response.json()
            print_result(False, f"Login failed: {response.status_code}", error_data)
            return False
    except Exception as e:
        print_result(False, f"Error verifying login: {str(e)}")
        return False

def main():
    print("\n" + "="*60)
    print("  APPROVAL FUNCTIONALITY TEST WITH REAL DATA")
    print("="*60)
    print(f"\nTesting against: {API_BASE_URL}")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Step 1: Create a test user (farmer) that needs approval
    print_section("STEP 1: Create Test User (Farmer)")
    user_id, test_user = create_test_user("farmer")
    
    if not user_id:
        print("\n[FAIL] Cannot continue without test user")
        return
    
    # Step 2: Verify user cannot login yet (needs approval)
    print_section("STEP 2: Verify User Cannot Login (Pending Approval)")
    can_login_before = verify_user_can_login(test_user["phone_number"], test_user["password"])
    
    if can_login_before:
        print("[NOTE] User can already login (might already be approved)")
    
    # Step 3: Login as Sector Vet
    print_section("STEP 3: Login as Sector Veterinarian")
    auth_token, sector_vet = login_sector_vet()
    
    if not auth_token:
        print("\n[FAIL] Cannot continue without authentication")
        return
    
    # Step 4: Approve the user
    print_section("STEP 4: Approve User")
    approved = approve_user(user_id, auth_token)
    
    if not approved:
        print("\n[FAIL] Approval failed")
        return
    
    # Step 5: Verify user can now login
    print_section("STEP 5: Verify User Can Login After Approval")
    can_login_after = verify_user_can_login(test_user["phone_number"], test_user["password"])
    
    if can_login_after:
        print_result(True, "Complete approval flow works correctly!")
    else:
        print_result(False, "Approval flow incomplete - user still cannot login")
    
    # Summary
    print("\n" + "="*60)
    print("  TEST SUMMARY")
    print("="*60)
    print(f"\nTest User Created: {user_id}")
    print(f"Phone Number: {test_user['phone_number']}")
    print(f"Before Approval: {'Can login' if can_login_before else 'Cannot login (expected)'}")
    print(f"After Approval: {'Can login' if can_login_after else 'Cannot login (unexpected)'}")
    print(f"\nResult: {'APPROVAL WORKING' if (not can_login_before and can_login_after) else 'NEEDS INVESTIGATION'}")

if __name__ == "__main__":
    main()

