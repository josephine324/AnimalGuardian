#!/usr/bin/env python3
"""
Comprehensive endpoint testing for AnimalGuardian
Tests endpoints without requiring real credentials
"""

import requests
import json
from datetime import datetime

BASE_URL = "https://animalguardian-backend-production-b5a8.up.railway.app/api"

def test_endpoint(method, endpoint, name, data=None, headers=None, expected_status=200, description=""):
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
            return {"status": "SKIP", "message": f"Unsupported method: {method}"}
        
        status_match = response.status_code == expected_status
        return {
            "status": "PASS" if status_match else "FAIL",
            "expected": expected_status,
            "actual": response.status_code,
            "message": response.text[:200] if not status_match else "OK",
            "description": description
        }
    except Exception as e:
        return {"status": "FAIL", "message": str(e), "description": description}

def main():
    print("=" * 70)
    print("ANIMALGUARDIAN COMPREHENSIVE ENDPOINT TEST")
    print("=" * 70)
    print(f"Base URL: {BASE_URL}")
    print(f"Test started: {datetime.now().isoformat()}\n")
    
    results = {
        "public": [],
        "auth": [],
        "protected": [],
        "admin": []
    }
    
    # 1. Test Public Endpoints
    print("\n" + "=" * 70)
    print("1. PUBLIC ENDPOINTS (No Authentication Required)")
    print("=" * 70)
    
    public_tests = [
        ("GET", "/livestock/types/", "Livestock Types", 200, "Should be public or require auth"),
        ("GET", "/livestock/breeds/", "Breeds", 200, "Should be public or require auth"),
        ("GET", "/cases/diseases/", "Diseases", 200, "Should be public or require auth"),
        ("GET", "/marketplace/categories/", "Marketplace Categories", 200, "Public endpoint"),
        ("GET", "/marketplace/products/", "Marketplace Products", 200, "Public endpoint"),
    ]
    
    for method, endpoint, name, expected, desc in public_tests:
        result = test_endpoint(method, endpoint, name, expected_status=expected, description=desc)
        results["public"].append({"name": name, "endpoint": endpoint, **result})
        status_symbol = "[PASS]" if result["status"] == "PASS" else "[FAIL]"
        print(f"{status_symbol} {name:30} | Status: {result.get('actual', 'N/A')} | {desc}")
    
    # 2. Test Authentication Endpoints
    print("\n" + "=" * 70)
    print("2. AUTHENTICATION ENDPOINTS")
    print("=" * 70)
    
    auth_tests = [
        ("POST", "/auth/register/", "Register Endpoint", {}, 400, "Should exist (400 = bad request, but endpoint exists)"),
        ("POST", "/auth/login/", "Login Endpoint", {}, 400, "Should exist (400 = bad request, but endpoint exists)"),
        ("POST", "/auth/verify-otp/", "Verify OTP Endpoint", {}, 400, "Should exist"),
        ("POST", "/auth/refresh/", "Token Refresh Endpoint", {}, 401, "Should exist (401 = no token)"),
    ]
    
    for method, endpoint, name, data, expected, desc in auth_tests:
        result = test_endpoint(method, endpoint, name, data=data, expected_status=expected, description=desc)
        results["auth"].append({"name": name, "endpoint": endpoint, **result})
        status_symbol = "[PASS]" if result["status"] == "PASS" else "[FAIL]"
        print(f"{status_symbol} {name:30} | Status: {result.get('actual', 'N/A')} | {desc}")
    
    # 3. Test Protected Endpoints (Should return 401 without auth)
    print("\n" + "=" * 70)
    print("3. PROTECTED ENDPOINTS (Should require authentication)")
    print("=" * 70)
    
    protected_tests = [
        ("GET", "/livestock/", "Livestock List", 401, "Should require auth"),
        ("GET", "/cases/reports/", "Cases List", 401, "Should require auth"),
        ("GET", "/notifications/", "Notifications", 401, "Should require auth"),
        ("GET", "/dashboard/stats/", "Dashboard Stats", 401, "Should require auth"),
        ("GET", "/weather/", "Weather Data", 401, "Should require auth"),
        ("GET", "/community/posts/", "Community Posts", 401, "Should require auth"),
    ]
    
    for method, endpoint, name, expected, desc in protected_tests:
        result = test_endpoint(method, endpoint, name, expected_status=expected, description=desc)
        results["protected"].append({"name": name, "endpoint": endpoint, **result})
        status_symbol = "[PASS]" if result["status"] == "PASS" else "[FAIL]"
        print(f"{status_symbol} {name:30} | Status: {result.get('actual', 'N/A')} | {desc}")
    
    # 4. Test Admin Endpoints (Should return 401 without auth)
    print("\n" + "=" * 70)
    print("4. ADMIN ENDPOINTS (Should require authentication)")
    print("=" * 70)
    
    admin_tests = [
        ("GET", "/users/", "Users List", 401, "Should require auth"),
        ("GET", "/farmers/", "Farmers List", 401, "Should require auth"),
        ("GET", "/veterinarians/", "Veterinarians List", 401, "Should require auth"),
        ("GET", "/broadcasts/", "Broadcasts List", 401, "Should require auth"),
    ]
    
    for method, endpoint, name, expected, desc in admin_tests:
        result = test_endpoint(method, endpoint, name, expected_status=expected, description=desc)
        results["admin"].append({"name": name, "endpoint": endpoint, **result})
        status_symbol = "[PASS]" if result["status"] == "PASS" else "[FAIL]"
        print(f"{status_symbol} {name:30} | Status: {result.get('actual', 'N/A')} | {desc}")
    
    # 5. Test Role-Based Permissions (with invalid token)
    print("\n" + "=" * 70)
    print("5. ROLE-BASED PERMISSIONS (Testing with invalid token)")
    print("=" * 70)
    
    invalid_token = "invalid_token_for_testing"
    headers = {"Authorization": f"Bearer {invalid_token}"}
    
    permission_tests = [
        ("POST", "/livestock/", "Create Livestock (Farmer only)", {"livestock_type": 1}, 401, "Should reject invalid token"),
        ("POST", "/cases/reports/", "Create Case (Farmer only)", {"livestock": 1}, 401, "Should reject invalid token"),
        ("POST", "/cases/reports/1/assign/", "Assign Case (Sector Vet only)", {"veterinarian_id": 1}, 401, "Should reject invalid token"),
        ("POST", "/broadcasts/", "Create Broadcast (Sector Vet only)", {"title": "Test"}, 401, "Should reject invalid token"),
    ]
    
    for method, endpoint, name, data, expected, desc in permission_tests:
        result = test_endpoint(method, endpoint, name, data=data, headers=headers, expected_status=expected, description=desc)
        status_symbol = "[PASS]" if result["status"] == "PASS" else "[FAIL]"
        print(f"{status_symbol} {name:30} | Status: {result.get('actual', 'N/A')} | {desc}")
    
    # Summary
    print("\n" + "=" * 70)
    print("TEST SUMMARY")
    print("=" * 70)
    
    total_passed = sum(len([r for r in results[cat] if r["status"] == "PASS"]) for cat in results)
    total_failed = sum(len([r for r in results[cat] if r["status"] == "FAIL"]) for cat in results)
    total_tests = total_passed + total_failed
    
    print(f"\nTotal Tests: {total_tests}")
    print(f"Passed: {total_passed}")
    print(f"Failed: {total_failed}")
    print(f"Success Rate: {(total_passed/total_tests*100):.1f}%")
    
    print("\n" + "-" * 70)
    print("BY CATEGORY:")
    print("-" * 70)
    for category, tests in results.items():
        passed = len([r for r in tests if r["status"] == "PASS"])
        failed = len([r for r in tests if r["status"] == "FAIL"])
        print(f"{category.upper():15} | Passed: {passed:2} | Failed: {failed:2}")
    
    # Save results
    with open("test_results_comprehensive.json", "w") as f:
        json.dump({
            "timestamp": datetime.now().isoformat(),
            "base_url": BASE_URL,
            "summary": {
                "total": total_tests,
                "passed": total_passed,
                "failed": total_failed
            },
            "results": results
        }, f, indent=2)
    
    print(f"\nDetailed results saved to: test_results_comprehensive.json")
    print(f"Test completed: {datetime.now().isoformat()}")
    
    # Recommendations
    print("\n" + "=" * 70)
    print("RECOMMENDATIONS")
    print("=" * 70)
    print("1. Create test accounts for each role (Sector Vet, Local Vet, Farmer)")
    print("2. Update test_endpoints_by_role.py with real credentials")
    print("3. Test authenticated endpoints with valid tokens")
    print("4. Verify role-based permissions work correctly")
    print("5. Test that farmers can create livestock/cases")
    print("6. Test that vets cannot create livestock/cases")
    print("7. Test that sector vets can assign cases")

if __name__ == "__main__":
    main()

