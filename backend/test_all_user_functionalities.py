#!/usr/bin/env python
"""
Comprehensive test of all user functionalities across all user types.
"""
import requests
import json
import time
import random

BACKEND_URL = "https://animalguardian.onrender.com/api"
ADMIN_EMAIL = "mutesijosephine324@gmail.com"
ADMIN_PASSWORD = "Admin@123456"

def print_section(title):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")

def print_result(name, success, details=""):
    if success is True:
        status = "[PASS]"
    elif success is False:
        status = "[FAIL]"
    else:
        status = "[SKIP]"
    print(f"{status}: {name}")
    if details:
        print(f"      {details}")

def login(email, password):
    """Login and return access token."""
    try:
        response = requests.post(
            f"{BACKEND_URL}/auth/login/",
            json={"email": email, "password": password},
            timeout=30
        )
        if response.status_code == 200:
            data = response.json()
            return data.get('access'), data.get('user')
        return None, None
    except Exception as e:
        return None, None

def test_farmer_functionalities():
    """Test all farmer functionalities."""
    print_section("FARMER FUNCTIONALITIES")
    
    results = []
    
    # Test 1: Farmer Registration
    print("1. Testing Farmer Registration...")
    farmer_email = f"test_farmer_{int(time.time())}@test.com"
    farmer_phone = f"+25078{random.randint(1000000, 9999999)}"
    farmer_password = "TestFarmer@123"
    
    try:
        response = requests.post(
            f"{BACKEND_URL}/auth/register/",
            json={
                "first_name": "Test",
                "last_name": "Farmer",
                "email": farmer_email,
                "phone_number": farmer_phone,
                "password": farmer_password,
                "user_type": "farmer"
            },
            timeout=30
        )
        success = response.status_code == 201
        results.append(("Farmer Registration", success))
        print_result("Farmer Registration", success, 
                    f"Status: {response.status_code}, Email: {farmer_email}")
        
        if success:
            user_id = response.json().get('user_id')
            
            # Test 2: OTP Verification
            print("\n2. Testing OTP Verification...")
            try:
                otp_response = requests.post(
                    f"{BACKEND_URL}/auth/verify-otp/",
                    json={"email": farmer_email, "otp_code": "123456"},
                    timeout=30
                )
                otp_success = otp_response.status_code == 200
                results.append(("OTP Verification", otp_success))
                print_result("OTP Verification", otp_success,
                            f"Status: {otp_response.status_code}")
            except Exception as e:
                results.append(("OTP Verification", False))
                print_result("OTP Verification", False, str(e))
            
            # Test 3: Login (should fail before approval)
            print("\n3. Testing Login Before Approval (should fail)...")
            token, user = login(farmer_email, farmer_password)
            login_before_approval = token is None
            results.append(("Login Before Approval (Blocked)", login_before_approval))
            print_result("Login Before Approval (Blocked)", login_before_approval,
                        "Login correctly blocked before approval")
            
            # Test 4: Approve Farmer (as admin)
            print("\n4. Approving Farmer (as Admin)...")
            admin_token, _ = login(ADMIN_EMAIL, ADMIN_PASSWORD)
            if admin_token:
                approve_response = requests.post(
                    f"{BACKEND_URL}/users/{user_id}/approve/",
                    headers={"Authorization": f"Bearer {admin_token}"},
                    json={"notes": "Test approval"},
                    timeout=30
                )
                approve_success = approve_response.status_code == 200
                results.append(("Farmer Approval", approve_success))
                print_result("Farmer Approval", approve_success,
                            f"Status: {approve_response.status_code}")
                
                # Test 5: Login After Approval
                print("\n5. Testing Login After Approval...")
                time.sleep(1)  # Wait a moment
                token, user = login(farmer_email, farmer_password)
                login_after_approval = token is not None
                results.append(("Login After Approval", login_after_approval))
                print_result("Login After Approval", login_after_approval,
                            f"Token received: {token is not None}")
                
                if token:
                    # Test 6: Create Livestock
                    print("\n6. Testing Create Livestock...")
                    try:
                        # First get livestock types
                        types_response = requests.get(
                            f"{BACKEND_URL}/livestock/types/",
                            headers={"Authorization": f"Bearer {token}"},
                            timeout=30
                        )
                        types_data = types_response.json()
                        type_id = types_data[0]['id'] if types_data else None
                        
                        if type_id:
                            livestock_response = requests.post(
                                f"{BACKEND_URL}/livestock/",
                                headers={"Authorization": f"Bearer {token}"},
                                json={
                                    "livestock_type": type_id,
                                    "name": "Test Cow",
                                    "gender": "female",
                                    "status": "healthy"
                                },
                                timeout=30
                            )
                            livestock_success = livestock_response.status_code == 201
                            results.append(("Create Livestock", livestock_success))
                            print_result("Create Livestock", livestock_success,
                                        f"Status: {livestock_response.status_code}")
                        else:
                            results.append(("Create Livestock", False))
                            print_result("Create Livestock", False, "No livestock types available")
                    except Exception as e:
                        results.append(("Create Livestock", False))
                        print_result("Create Livestock", False, str(e))
                    
                    # Test 7: Create Case
                    print("\n7. Testing Create Case...")
                    try:
                        # Get livestock first
                        livestock_list = requests.get(
                            f"{BACKEND_URL}/livestock/",
                            headers={"Authorization": f"Bearer {token}"},
                            timeout=30
                        )
                        livestock_data = livestock_list.json()
                        livestock_id = livestock_data[0]['id'] if livestock_data else None
                        
                        if livestock_id:
                            case_response = requests.post(
                                f"{BACKEND_URL}/cases/reports/",
                                headers={"Authorization": f"Bearer {token}"},
                                json={
                                    "livestock": livestock_id,
                                    "urgency": "medium",
                                    "symptoms_observed": "Test symptoms",
                                    "duration_of_symptoms": "2 days",
                                    "number_of_affected_animals": 1
                                },
                                timeout=30
                            )
                            case_success = case_response.status_code == 201
                            results.append(("Create Case", case_success))
                            print_result("Create Case", case_success,
                                        f"Status: {case_response.status_code}")
                        else:
                            results.append(("Create Case", False))
                            print_result("Create Case", False, "No livestock available")
                    except Exception as e:
                        results.append(("Create Case", False))
                        print_result("Create Case", False, str(e))
                    
                    # Test 8: Get Profile
                    print("\n8. Testing Get Profile...")
                    try:
                        profile_response = requests.get(
                            f"{BACKEND_URL}/users/profile/",
                            headers={"Authorization": f"Bearer {token}"},
                            timeout=30
                        )
                        profile_success = profile_response.status_code == 200
                        results.append(("Get Profile", profile_success))
                        print_result("Get Profile", profile_success,
                                    f"Status: {profile_response.status_code}")
                    except Exception as e:
                        results.append(("Get Profile", False))
                        print_result("Get Profile", False, str(e))
                    
                    # Test 9: Update Profile
                    print("\n9. Testing Update Profile...")
                    try:
                        update_response = requests.patch(
                            f"{BACKEND_URL}/users/{user['id']}/",
                            headers={"Authorization": f"Bearer {token}"},
                            json={"first_name": "Updated", "last_name": "Farmer"},
                            timeout=30
                        )
                        update_success = update_response.status_code == 200
                        results.append(("Update Profile", update_success))
                        print_result("Update Profile", update_success,
                                    f"Status: {update_response.status_code}")
                    except Exception as e:
                        results.append(("Update Profile", False))
                        print_result("Update Profile", False, str(e))
                    
                    # Test 10: Change Password
                    print("\n10. Testing Change Password...")
                    try:
                        password_response = requests.post(
                            f"{BACKEND_URL}/auth/change-password/",
                            headers={"Authorization": f"Bearer {token}"},
                            json={
                                "current_password": farmer_password,
                                "new_password": "NewPassword@123",
                                "password_confirm": "NewPassword@123"
                            },
                            timeout=30
                        )
                        password_success = password_response.status_code == 200
                        results.append(("Change Password", password_success))
                        print_result("Change Password", password_success,
                                    f"Status: {password_response.status_code}")
                    except Exception as e:
                        results.append(("Change Password", False))
                        print_result("Change Password", False, str(e))
            else:
                print_result("Farmer Approval", False, "Admin login failed")
    except Exception as e:
        results.append(("Farmer Registration", False))
        print_result("Farmer Registration", False, str(e))
    
    return results

def test_local_vet_functionalities():
    """Test all local vet functionalities."""
    print_section("LOCAL VET FUNCTIONALITIES")
    
    results = []
    
    # Test 1: Local Vet Registration
    print("1. Testing Local Vet Registration...")
    vet_email = f"test_localvet_{int(time.time())}@test.com"
    vet_phone = f"+25078{random.randint(1000000, 9999999)}"
    vet_password = "TestVet@123"
    
    try:
        response = requests.post(
            f"{BACKEND_URL}/auth/register/",
            json={
                "first_name": "Test",
                "last_name": "LocalVet",
                "email": vet_email,
                "phone_number": vet_phone,
                "password": vet_password,
                "user_type": "local_vet"
            },
            timeout=30
        )
        success = response.status_code == 201
        results.append(("Local Vet Registration", success))
        print_result("Local Vet Registration", success,
                    f"Status: {response.status_code}, Email: {vet_email}")
        
        if success:
            user_id = response.json().get('user_id')
            
            # Test 2: OTP Verification
            print("\n2. Testing OTP Verification...")
            try:
                otp_response = requests.post(
                    f"{BACKEND_URL}/auth/verify-otp/",
                    json={"email": vet_email, "otp_code": "123456"},
                    timeout=30
                )
                otp_success = otp_response.status_code == 200
                results.append(("OTP Verification", otp_success))
                print_result("OTP Verification", otp_success,
                            f"Status: {otp_response.status_code}")
            except Exception as e:
                results.append(("OTP Verification", False))
                print_result("OTP Verification", False, str(e))
            
            # Test 3: Approve Local Vet
            print("\n3. Approving Local Vet (as Admin)...")
            admin_token, _ = login(ADMIN_EMAIL, ADMIN_PASSWORD)
            if admin_token:
                approve_response = requests.post(
                    f"{BACKEND_URL}/users/{user_id}/approve/",
                    headers={"Authorization": f"Bearer {admin_token}"},
                    json={"notes": "Test approval"},
                    timeout=30
                )
                approve_success = approve_response.status_code == 200
                results.append(("Local Vet Approval", approve_success))
                print_result("Local Vet Approval", approve_success,
                            f"Status: {approve_response.status_code}")
                
                # Test 4: Login After Approval
                print("\n4. Testing Login After Approval...")
                time.sleep(1)
                token, user = login(vet_email, vet_password)
                login_success = token is not None
                results.append(("Login After Approval", login_success))
                print_result("Login After Approval", login_success,
                            f"Token received: {token is not None}")
                
                if token:
                    # Test 5: Get Assigned Cases (should be empty initially)
                    print("\n5. Testing Get Assigned Cases...")
                    try:
                        cases_response = requests.get(
                            f"{BACKEND_URL}/cases/reports/",
                            headers={"Authorization": f"Bearer {token}"},
                            timeout=30
                        )
                        cases_success = cases_response.status_code == 200
                        results.append(("Get Assigned Cases", cases_success))
                        print_result("Get Assigned Cases", cases_success,
                                    f"Status: {cases_response.status_code}")
                    except Exception as e:
                        results.append(("Get Assigned Cases", False))
                        print_result("Get Assigned Cases", False, str(e))
                    
                    # Test 6: Toggle Availability
                    print("\n6. Testing Toggle Availability...")
                    try:
                        toggle_response = requests.post(
                            f"{BACKEND_URL}/veterinarians/{user['id']}/toggle_availability/",
                            headers={"Authorization": f"Bearer {token}"},
                            timeout=30
                        )
                        toggle_success = toggle_response.status_code == 200
                        results.append(("Toggle Availability", toggle_success))
                        print_result("Toggle Availability", toggle_success,
                                    f"Status: {toggle_response.status_code}")
                    except Exception as e:
                        results.append(("Toggle Availability", False))
                        print_result("Toggle Availability", False, str(e))
                    
                    # Test 7: Get Profile
                    print("\n7. Testing Get Profile...")
                    try:
                        profile_response = requests.get(
                            f"{BACKEND_URL}/veterinarians/profile/",
                            headers={"Authorization": f"Bearer {token}"},
                            timeout=30
                        )
                        profile_success = profile_response.status_code == 200
                        results.append(("Get Profile", profile_success))
                        print_result("Get Profile", profile_success,
                                    f"Status: {profile_response.status_code}")
                    except Exception as e:
                        results.append(("Get Profile", False))
                        print_result("Get Profile", False, str(e))
            else:
                print_result("Local Vet Approval", False, "Admin login failed")
    except Exception as e:
        results.append(("Local Vet Registration", False))
        print_result("Local Vet Registration", False, str(e))
    
    return results

def test_sector_vet_functionalities():
    """Test all sector vet functionalities."""
    print_section("SECTOR VET FUNCTIONALITIES")
    
    results = []
    
    # Login as admin (acting as sector vet)
    print("1. Logging in as Admin (Sector Vet role)...")
    token, user = login(ADMIN_EMAIL, ADMIN_PASSWORD)
    
    if not token:
        print_result("Sector Vet Login", False, "Cannot login as admin")
        return results
    
    results.append(("Sector Vet Login", True))
    print_result("Sector Vet Login", True, "Logged in successfully")
    
    # Test 2: Get All Farmers
    print("\n2. Testing Get All Farmers...")
    try:
        farmers_response = requests.get(
            f"{BACKEND_URL}/farmers/",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        farmers_success = farmers_response.status_code == 200
        farmers_data = farmers_response.json() if farmers_success else []
        farmers_count = len(farmers_data) if isinstance(farmers_data, list) else 0
        results.append(("Get All Farmers", farmers_success))
        print_result("Get All Farmers", farmers_success,
                    f"Status: {farmers_response.status_code}, Count: {farmers_count}")
    except Exception as e:
        results.append(("Get All Farmers", False))
        print_result("Get All Farmers", False, str(e))
    
    # Test 3: Get All Local Vets
    print("\n3. Testing Get All Local Vets...")
    try:
        vets_response = requests.get(
            f"{BACKEND_URL}/veterinarians/",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        vets_success = vets_response.status_code == 200
        vets_data = vets_response.json() if vets_success else []
        vets_count = len(vets_data) if isinstance(vets_data, list) else 0
        results.append(("Get All Local Vets", vets_success))
        print_result("Get All Local Vets", vets_success,
                    f"Status: {vets_response.status_code}, Count: {vets_count}")
    except Exception as e:
        results.append(("Get All Local Vets", False))
        print_result("Get All Local Vets", False, str(e))
    
    # Test 4: Get All Cases
    print("\n4. Testing Get All Cases...")
    try:
        cases_response = requests.get(
            f"{BACKEND_URL}/cases/reports/",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        cases_success = cases_response.status_code == 200
        cases_data = cases_response.json()
        cases_list = cases_data.get('results', []) if isinstance(cases_data, dict) else (cases_data if isinstance(cases_data, list) else [])
        cases_count = len(cases_list)
        results.append(("Get All Cases", cases_success))
        print_result("Get All Cases", cases_success,
                    f"Status: {cases_response.status_code}, Count: {cases_count}")
    except Exception as e:
        results.append(("Get All Cases", False))
        print_result("Get All Cases", False, str(e))
    
    # Test 5: Get All Livestock
    print("\n5. Testing Get All Livestock...")
    try:
        livestock_response = requests.get(
            f"{BACKEND_URL}/livestock/",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        livestock_success = livestock_response.status_code == 200
        livestock_data = livestock_response.json()
        livestock_list = livestock_data.get('results', []) if isinstance(livestock_data, dict) else (livestock_data if isinstance(livestock_data, list) else [])
        livestock_count = len(livestock_list)
        results.append(("Get All Livestock", livestock_success))
        print_result("Get All Livestock", livestock_success,
                    f"Status: {livestock_response.status_code}, Count: {livestock_count}")
    except Exception as e:
        results.append(("Get All Livestock", False))
        print_result("Get All Livestock", False, str(e))
    
    # Test 6: Get Pending Approvals
    print("\n6. Testing Get Pending Approvals...")
    try:
        pending_response = requests.get(
            f"{BACKEND_URL}/users/pending_approval/",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        pending_success = pending_response.status_code == 200
        pending_data = pending_response.json() if pending_success else []
        pending_count = len(pending_data) if isinstance(pending_data, list) else 0
        results.append(("Get Pending Approvals", pending_success))
        print_result("Get Pending Approvals", pending_success,
                    f"Status: {pending_response.status_code}, Count: {pending_count}")
    except Exception as e:
        results.append(("Get Pending Approvals", False))
        print_result("Get Pending Approvals", False, str(e))
    
    # Test 7: Get Dashboard Stats
    print("\n7. Testing Get Dashboard Stats...")
    try:
        stats_response = requests.get(
            f"{BACKEND_URL}/dashboard/stats/",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        stats_success = stats_response.status_code == 200
        results.append(("Get Dashboard Stats", stats_success))
        print_result("Get Dashboard Stats", stats_success,
                    f"Status: {stats_response.status_code}")
    except Exception as e:
        results.append(("Get Dashboard Stats", False))
        print_result("Get Dashboard Stats", False, str(e))
    
    # Test 8: Assign Case (if cases and vets exist)
    print("\n8. Testing Assign Case...")
    try:
        # Get cases and vets
        cases_resp = requests.get(
            f"{BACKEND_URL}/cases/reports/",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        vets_resp = requests.get(
            f"{BACKEND_URL}/veterinarians/",
            headers={"Authorization": f"Bearer {token}"},
            timeout=30
        )
        
        if cases_resp.status_code == 200 and vets_resp.status_code == 200:
            cases_data = cases_resp.json()
            cases_list = cases_data.get('results', []) if isinstance(cases_data, dict) else (cases_data if isinstance(cases_data, list) else [])
            vets_data = vets_resp.json()
            vets_list = vets_data if isinstance(vets_data, list) else []
            
            # Find unassigned case and available local vet
            unassigned_case = next((c for c in cases_list if not c.get('assigned_veterinarian')), None)
            local_vet = next((v for v in vets_list if v.get('user_type') == 'local_vet'), None)
            
            if unassigned_case and local_vet:
                assign_response = requests.post(
                    f"{BACKEND_URL}/cases/reports/{unassigned_case['id']}/assign/",
                    headers={"Authorization": f"Bearer {token}"},
                    json={"veterinarian_id": local_vet['id']},
                    timeout=30
                )
                assign_success = assign_response.status_code == 200
                results.append(("Assign Case", assign_success))
                print_result("Assign Case", assign_success,
                            f"Status: {assign_response.status_code}")
            else:
                results.append(("Assign Case", None))
                print_result("Assign Case", None, "No unassigned cases or local vets available")
        else:
            results.append(("Assign Case", False))
            print_result("Assign Case", False, "Cannot fetch cases or vets")
    except Exception as e:
        results.append(("Assign Case", False))
        print_result("Assign Case", False, str(e))
    
    return results

def main():
    print("\n" + "="*70)
    print("  COMPREHENSIVE USER FUNCTIONALITY TEST")
    print("="*70)
    
    all_results = []
    
    # Test Farmer functionalities
    farmer_results = test_farmer_functionalities()
    all_results.extend(farmer_results)
    
    # Test Local Vet functionalities
    local_vet_results = test_local_vet_functionalities()
    all_results.extend(local_vet_results)
    
    # Test Sector Vet functionalities
    sector_vet_results = test_sector_vet_functionalities()
    all_results.extend(sector_vet_results)
    
    # Summary
    print_section("TEST SUMMARY")
    
    passed = sum(1 for _, success in all_results if success is True)
    failed = sum(1 for _, success in all_results if success is False)
    skipped = sum(1 for _, success in all_results if success is None)
    total = len(all_results)
    
    print(f"Total Tests: {total}")
    print(f"[PASS] Passed: {passed}")
    print(f"[FAIL] Failed: {failed}")
    print(f"[SKIP] Skipped: {skipped}")
    if total > 0:
        print(f"Success Rate: {(passed/total*100):.1f}%")
    
    if failed > 0:
        print("\nFailed Tests:")
        for name, success in all_results:
            if success is False:
                print(f"  [FAIL] {name}")
    
    print("\n" + "="*70)

if __name__ == '__main__':
    main()

