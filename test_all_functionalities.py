#!/usr/bin/env python3
"""
Comprehensive functionality test for AnimalGuardian
Tests all API endpoints and functionality
"""

import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "https://animalguardian-backend-production-b5a8.up.railway.app/api"
TEST_RESULTS = {
    "passed": [],
    "failed": [],
    "skipped": []
}

def log_test(name, status, message=""):
    """Log test result"""
    result = {
        "name": name,
        "status": status,
        "message": message,
        "timestamp": datetime.now().isoformat()
    }
    if status == "PASS":
        TEST_RESULTS["passed"].append(result)
        print(f"✓ {name}")
    elif status == "FAIL":
        TEST_RESULTS["failed"].append(result)
        print(f"✗ {name}: {message}")
    else:
        TEST_RESULTS["skipped"].append(result)
        print(f"⊘ {name}: {message}")

def test_endpoint(method, endpoint, name, data=None, headers=None, expected_status=200):
    """Test an API endpoint"""
    try:
        url = f"{BASE_URL}{endpoint}"
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=10)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers, timeout=10)
        elif method == "PATCH":
            response = requests.patch(url, json=data, headers=headers, timeout=10)
        elif method == "DELETE":
            response = requests.delete(url, headers=headers, timeout=10)
        else:
            log_test(name, "SKIP", f"Unsupported method: {method}")
            return None
        
        if response.status_code == expected_status:
            log_test(name, "PASS")
            return response.json() if response.content else None
        else:
            log_test(name, "FAIL", f"Expected {expected_status}, got {response.status_code}: {response.text[:100]}")
            return None
    except requests.exceptions.RequestException as e:
        log_test(name, "FAIL", f"Request failed: {str(e)}")
        return None
    except Exception as e:
        log_test(name, "FAIL", f"Unexpected error: {str(e)}")
        return None

def main():
    print("=" * 60)
    print("ANIMALGUARDIAN FUNCTIONALITY TEST")
    print("=" * 60)
    print(f"Base URL: {BASE_URL}")
    print(f"Test started: {datetime.now().isoformat()}\n")
    
    # Test 1: Health Check
    print("\n1. BACKEND HEALTH CHECK")
    print("-" * 60)
    test_endpoint("GET", "/dashboard/health/", "Backend Health Check", expected_status=200)
    
    # Test 2: Public Endpoints (No Auth Required)
    print("\n2. PUBLIC ENDPOINTS")
    print("-" * 60)
    test_endpoint("GET", "/livestock/types/", "Get Livestock Types", expected_status=200)
    test_endpoint("GET", "/livestock/breeds/", "Get Breeds", expected_status=200)
    test_endpoint("GET", "/cases/diseases/", "Get Diseases", expected_status=200)
    test_endpoint("GET", "/marketplace/categories/", "Get Marketplace Categories", expected_status=200)
    test_endpoint("GET", "/marketplace/products/", "Get Marketplace Products", expected_status=200)
    
    # Test 3: Authentication Endpoints
    print("\n3. AUTHENTICATION ENDPOINTS")
    print("-" * 60)
    
    # Test registration (will fail without proper data, but endpoint should exist)
    test_endpoint("POST", "/auth/register/", "Register Endpoint Exists", 
                  data={}, expected_status=400)  # 400 = bad request, but endpoint exists
    
    # Test login (will fail without credentials, but endpoint should exist)
    test_endpoint("POST", "/auth/login/", "Login Endpoint Exists",
                  data={}, expected_status=400)
    
    # Test 4: Protected Endpoints (Require Auth)
    print("\n4. PROTECTED ENDPOINTS (Require Authentication)")
    print("-" * 60)
    print("Note: These will fail without valid auth token, but we're checking if endpoints exist")
    
    # Without auth token, should get 401
    test_endpoint("GET", "/livestock/", "Livestock List (Protected)", expected_status=401)
    test_endpoint("GET", "/cases/reports/", "Cases List (Protected)", expected_status=401)
    test_endpoint("GET", "/notifications/", "Notifications List (Protected)", expected_status=401)
    test_endpoint("GET", "/dashboard/stats/", "Dashboard Stats (Protected)", expected_status=401)
    test_endpoint("GET", "/weather/", "Weather Data (Protected)", expected_status=401)
    test_endpoint("GET", "/community/posts/", "Community Posts (Protected)", expected_status=401)
    
    # Test 5: Admin Endpoints
    print("\n5. ADMIN ENDPOINTS")
    print("-" * 60)
    test_endpoint("GET", "/users/", "Users List (Admin)", expected_status=401)
    test_endpoint("GET", "/farmers/", "Farmers List (Admin)", expected_status=401)
    test_endpoint("GET", "/veterinarians/", "Veterinarians List (Admin)", expected_status=401)
    test_endpoint("GET", "/broadcasts/", "Broadcasts List (Admin)", expected_status=401)
    
    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    print(f"Total Tests: {len(TEST_RESULTS['passed']) + len(TEST_RESULTS['failed']) + len(TEST_RESULTS['skipped'])}")
    print(f"Passed: {len(TEST_RESULTS['passed'])}")
    print(f"Failed: {len(TEST_RESULTS['failed'])}")
    print(f"Skipped: {len(TEST_RESULTS['skipped'])}")
    
    if TEST_RESULTS['failed']:
        print("\nFAILED TESTS:")
        for test in TEST_RESULTS['failed']:
            print(f"  - {test['name']}: {test['message']}")
    
    # Save results
    with open("test_results.json", "w") as f:
        json.dump(TEST_RESULTS, f, indent=2)
    
    print(f"\nDetailed results saved to: test_results.json")
    print(f"Test completed: {datetime.now().isoformat()}")

if __name__ == "__main__":
    main()

