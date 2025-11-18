#!/usr/bin/env python3
"""
Comprehensive endpoint testing for AnimalGuardian
Tests all endpoints for Sector Vet, Local Vet, and Farmer roles
"""

import requests
import json
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# Configuration
BASE_URL = "https://animalguardian-backend-production-b5a8.up.railway.app/api"

# Test results storage
TEST_RESULTS = {
    "sector_vet": {"passed": [], "failed": [], "skipped": []},
    "local_vet": {"passed": [], "failed": [], "skipped": []},
    "farmer": {"passed": [], "failed": [], "skipped": []}
}

# Test credentials (these should be real test accounts)
TEST_CREDENTIALS = {
    "sector_vet": {
        "phone_number": "+250788000001",  # Update with real test account
        "password": "testpass123"
    },
    "local_vet": {
        "phone_number": "+250788000002",  # Update with real test account
        "password": "testpass123"
    },
    "farmer": {
        "phone_number": "+250788000003",  # Update with real test account
        "password": "testpass123"
    }
}

def log_test(role: str, name: str, status: str, message: str = ""):
    """Log test result for a specific role"""
    result = {
        "name": name,
        "status": status,
        "message": message,
        "timestamp": datetime.now().isoformat()
    }
    if status == "PASS":
        TEST_RESULTS[role]["passed"].append(result)
        print(f"[{role.upper()}] [PASS] {name}")
    elif status == "FAIL":
        TEST_RESULTS[role]["failed"].append(result)
        print(f"[{role.upper()}] [FAIL] {name}: {message}")
    else:
        TEST_RESULTS[role]["skipped"].append(result)
        print(f"[{role.upper()}] [SKIP] {name}: {message}")

def get_auth_token(role: str) -> Optional[str]:
    """Get authentication token for a role"""
    try:
        creds = TEST_CREDENTIALS[role]
        response = requests.post(
            f"{BASE_URL}/auth/login/",
            json={
                "phone_number": creds["phone_number"],
                "password": creds["password"]
            },
            timeout=10
        )
        if response.status_code == 200:
            data = response.json()
            return data.get("access")
        else:
            log_test(role, f"Login for {role}", "FAIL", f"Status {response.status_code}: {response.text[:100]}")
            return None
    except Exception as e:
        log_test(role, f"Login for {role}", "FAIL", str(e))
        return None

def test_endpoint(role: str, method: str, endpoint: str, name: str, 
                  token: Optional[str] = None, data: Optional[Dict] = None,
                  expected_status: int = 200, should_fail: bool = False) -> bool:
    """Test an API endpoint"""
    try:
        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        }
        if token:
            headers['Authorization'] = f'Bearer {token}'
        
        url = f"{BASE_URL}{endpoint}"
        
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=10)
        elif method == "POST":
            response = requests.post(url, headers=headers, json=data, timeout=10)
        elif method == "PATCH":
            response = requests.patch(url, headers=headers, json=data, timeout=10)
        elif method == "DELETE":
            response = requests.delete(url, headers=headers, timeout=10)
        else:
            log_test(role, name, "SKIP", f"Unsupported method: {method}")
            return False
        
        # If should_fail is True, we expect a failure (401, 403, etc.)
        if should_fail:
            if response.status_code in [401, 403]:
                log_test(role, name, "PASS", f"Correctly denied access (Status: {response.status_code})")
                return True
            else:
                log_test(role, name, "FAIL", f"Expected 401/403 but got {response.status_code}")
                return False
        else:
            if response.status_code == expected_status:
                log_test(role, name, "PASS")
                return True
            else:
                log_test(role, name, "FAIL", f"Expected {expected_status}, got {response.status_code}: {response.text[:100]}")
                return False
    except requests.exceptions.RequestException as e:
        log_test(role, name, "FAIL", f"Request failed: {str(e)}")
        return False
    except Exception as e:
        log_test(role, name, "FAIL", f"Unexpected error: {str(e)}")
        return False

def test_public_endpoints(role: str):
    """Test public endpoints (no auth required)"""
    print(f"\n{'='*60}")
    print(f"Testing PUBLIC ENDPOINTS for {role.upper()}")
    print(f"{'='*60}")
    
    test_endpoint(role, "GET", "/livestock/types/", "Get Livestock Types", expected_status=200)
    test_endpoint(role, "GET", "/livestock/breeds/", "Get Breeds", expected_status=200)
    test_endpoint(role, "GET", "/cases/diseases/", "Get Diseases", expected_status=200)
    test_endpoint(role, "GET", "/marketplace/categories/", "Get Marketplace Categories", expected_status=200)
    test_endpoint(role, "GET", "/marketplace/products/", "Get Marketplace Products", expected_status=200)

def test_farmer_endpoints(token: str):
    """Test endpoints specific to farmers"""
    role = "farmer"
    print(f"\n{'='*60}")
    print(f"Testing FARMER-SPECIFIC ENDPOINTS")
    print(f"{'='*60}")
    
    # Livestock Management (Farmers can create)
    test_endpoint(role, "GET", "/livestock/", "Get Own Livestock", token, expected_status=200)
    test_endpoint(role, "POST", "/livestock/", "Create Livestock", token, 
                  data={"livestock_type": 1, "name": "Test Cow", "gender": "F", "status": "healthy"},
                  expected_status=201)
    
    # Case Management (Farmers can create)
    test_endpoint(role, "GET", "/cases/reports/", "Get Own Cases", token, expected_status=200)
    test_endpoint(role, "POST", "/cases/reports/", "Create Case Report", token,
                  data={"livestock": 1, "symptoms_observed": "Test symptoms", "urgency": "medium"},
                  expected_status=201)
    
    # Community
    test_endpoint(role, "GET", "/community/posts/", "Get Community Posts", token, expected_status=200)
    test_endpoint(role, "POST", "/community/posts/", "Create Post", token,
                  data={"content": "Test post", "post_type": "text"},
                  expected_status=201)
    
    # Notifications
    test_endpoint(role, "GET", "/notifications/", "Get Notifications", token, expected_status=200)
    
    # Weather
    test_endpoint(role, "GET", "/weather/", "Get Weather Data", token, expected_status=200)
    
    # Dashboard Stats
    test_endpoint(role, "GET", "/dashboard/stats/", "Get Dashboard Stats", token, expected_status=200)
    
    # Should NOT have access to admin endpoints
    test_endpoint(role, "GET", "/users/", "Access Users List (Should Fail)", token, should_fail=True)
    test_endpoint(role, "GET", "/farmers/", "Access Farmers List (Should Fail)", token, should_fail=True)
    test_endpoint(role, "GET", "/veterinarians/", "Access Veterinarians List (Should Fail)", token, should_fail=True)
    test_endpoint(role, "GET", "/broadcasts/", "Access Broadcasts (Should Fail)", token, should_fail=True)

def test_local_vet_endpoints(token: str):
    """Test endpoints specific to local vets"""
    role = "local_vet"
    print(f"\n{'='*60}")
    print(f"Testing LOCAL VET-SPECIFIC ENDPOINTS")
    print(f"{'='*60}")
    
    # Cases (Local vets can view assigned cases)
    test_endpoint(role, "GET", "/cases/reports/", "Get Assigned Cases", token, expected_status=200)
    test_endpoint(role, "PATCH", "/cases/reports/1/", "Update Case Status", token,
                  data={"status": "under_review"},
                  expected_status=200)
    
    # Should NOT be able to create cases
    test_endpoint(role, "POST", "/cases/reports/", "Create Case (Should Fail)", token,
                  data={"livestock": 1, "symptoms_observed": "Test", "urgency": "medium"},
                  should_fail=True)
    
    # Should NOT be able to create livestock
    test_endpoint(role, "POST", "/livestock/", "Create Livestock (Should Fail)", token,
                  data={"livestock_type": 1, "name": "Test", "gender": "F"},
                  should_fail=True)
    
    # Can view livestock (read-only)
    test_endpoint(role, "GET", "/livestock/", "View Livestock (Read-Only)", token, expected_status=200)
    
    # Community
    test_endpoint(role, "GET", "/community/posts/", "Get Community Posts", token, expected_status=200)
    
    # Notifications
    test_endpoint(role, "GET", "/notifications/", "Get Notifications", token, expected_status=200)
    
    # Weather
    test_endpoint(role, "GET", "/weather/", "Get Weather Data", token, expected_status=200)
    
    # Dashboard Stats
    test_endpoint(role, "GET", "/dashboard/stats/", "Get Dashboard Stats", token, expected_status=200)
    
    # Should NOT have access to admin endpoints
    test_endpoint(role, "GET", "/users/", "Access Users List (Should Fail)", token, should_fail=True)
    test_endpoint(role, "GET", "/farmers/", "Access Farmers List (Should Fail)", token, should_fail=True)
    test_endpoint(role, "GET", "/veterinarians/", "Access Veterinarians List (Should Fail)", token, should_fail=True)
    test_endpoint(role, "GET", "/broadcasts/", "Access Broadcasts (Should Fail)", token, should_fail=True)
    test_endpoint(role, "POST", "/cases/reports/1/assign/", "Assign Case (Should Fail)", token,
                  data={"veterinarian_id": 1},
                  should_fail=True)

def test_sector_vet_endpoints(token: str):
    """Test endpoints specific to sector vets"""
    role = "sector_vet"
    print(f"\n{'='*60}")
    print(f"Testing SECTOR VET-SPECIFIC ENDPOINTS")
    print(f"{'='*60}")
    
    # User Management (Sector vets can view)
    test_endpoint(role, "GET", "/users/", "Get All Users", token, expected_status=200)
    test_endpoint(role, "GET", "/farmers/", "Get All Farmers", token, expected_status=200)
    test_endpoint(role, "GET", "/veterinarians/", "Get All Veterinarians", token, expected_status=200)
    
    # Cases (Sector vets can view all and assign)
    test_endpoint(role, "GET", "/cases/reports/", "Get All Cases", token, expected_status=200)
    test_endpoint(role, "POST", "/cases/reports/1/assign/", "Assign Case to Vet", token,
                  data={"veterinarian_id": 1},
                  expected_status=200)
    
    # Should NOT be able to create cases
    test_endpoint(role, "POST", "/cases/reports/", "Create Case (Should Fail)", token,
                  data={"livestock": 1, "symptoms_observed": "Test", "urgency": "medium"},
                  should_fail=True)
    
    # Should NOT be able to create livestock
    test_endpoint(role, "POST", "/livestock/", "Create Livestock (Should Fail)", token,
                  data={"livestock_type": 1, "name": "Test", "gender": "F"},
                  should_fail=True)
    
    # Can view all livestock
    test_endpoint(role, "GET", "/livestock/", "View All Livestock", token, expected_status=200)
    
    # Broadcasts (Sector vets can create and send)
    test_endpoint(role, "GET", "/broadcasts/", "Get Broadcasts", token, expected_status=200)
    test_endpoint(role, "POST", "/broadcasts/", "Create Broadcast", token,
                  data={"title": "Test Broadcast", "message": "Test message", "channel": "in_app"},
                  expected_status=201)
    
    # Notifications
    test_endpoint(role, "GET", "/notifications/", "Get Notifications", token, expected_status=200)
    
    # Dashboard Stats
    test_endpoint(role, "GET", "/dashboard/stats/", "Get Dashboard Stats", token, expected_status=200)
    
    # Weather
    test_endpoint(role, "GET", "/weather/", "Get Weather Data", token, expected_status=200)

def main():
    print("=" * 60)
    print("ANIMALGUARDIAN ENDPOINT TESTING BY ROLE")
    print("=" * 60)
    print(f"Base URL: {BASE_URL}")
    print(f"Test started: {datetime.now().isoformat()}\n")
    
    # Test public endpoints for all roles
    for role in ["sector_vet", "local_vet", "farmer"]:
        test_public_endpoints(role)
    
    # Test authenticated endpoints for each role
    roles_to_test = ["sector_vet", "local_vet", "farmer"]
    
    for role in roles_to_test:
        print(f"\n{'='*60}")
        print(f"Testing {role.upper()} AUTHENTICATED ENDPOINTS")
        print(f"{'='*60}")
        
        # Get auth token
        token = get_auth_token(role)
        if not token:
            print(f"[WARNING] Skipping {role} tests - could not authenticate")
            print(f"         Please update TEST_CREDENTIALS with valid test account credentials")
            continue
        
        # Test role-specific endpoints
        if role == "farmer":
            test_farmer_endpoints(token)
        elif role == "local_vet":
            test_local_vet_endpoints(token)
        elif role == "sector_vet":
            test_sector_vet_endpoints(token)
    
    # Print summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    for role in ["sector_vet", "local_vet", "farmer"]:
        passed = len(TEST_RESULTS[role]["passed"])
        failed = len(TEST_RESULTS[role]["failed"])
        skipped = len(TEST_RESULTS[role]["skipped"])
        total = passed + failed + skipped
        
        print(f"\n{role.upper()}:")
        print(f"  Total Tests: {total}")
        print(f"  Passed: {passed}")
        print(f"  Failed: {failed}")
        print(f"  Skipped: {skipped}")
        
        if TEST_RESULTS[role]["failed"]:
            print(f"\n  Failed Tests:")
            for test in TEST_RESULTS[role]["failed"]:
                print(f"    - {test['name']}: {test['message']}")
    
    # Save results
    with open("test_results_by_role.json", "w") as f:
        json.dump(TEST_RESULTS, f, indent=2)
    
    print(f"\nDetailed results saved to: test_results_by_role.json")
    print(f"Test completed: {datetime.now().isoformat()}")

if __name__ == "__main__":
    main()

