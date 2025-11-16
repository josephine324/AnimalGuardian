#!/usr/bin/env python3
"""
Comprehensive endpoint testing for AnimalGuardian
Tests all endpoints with all user types
"""
import requests
import json
from datetime import datetime

BACKEND_URL = "https://animalguardian-backend-production-b5a8.up.railway.app/api"

# Test users
TEST_USERS = {
    'farmer': {'username': 'farmer1', 'password': 'Test@123456', 'phone': '+250780000001'},
    'local_vet': {'username': 'localvet1', 'password': 'Test@123456', 'phone': '+250780000003'},
    'sector_vet': {'username': 'sectorvet1', 'password': 'Test@123456', 'phone': '+250780000004'},
    'admin': {'email': 'mutesijosephine324@gmail.com', 'password': 'Admin@123456'},
    'field_officer': {'username': 'fieldofficer1', 'password': 'Test@123456', 'phone': '+250780000005'}
}

results = {
    'passed': [],
    'failed': [],
    'skipped': []
}

def login_user(user_type, user_data):
    """Login and get token"""
    try:
        if 'email' in user_data:
            login_data = {'email': user_data['email'], 'password': user_data['password']}
        else:
            login_data = {'phone_number': user_data['phone'], 'password': user_data['password']}
        
        response = requests.post(f"{BACKEND_URL}/auth/login/", json=login_data, timeout=10)
        if response.status_code == 200:
            data = response.json()
            return data.get('access'), data.get('user', {})
        return None, None
    except:
        return None, None

def test_endpoint(name, method, url, headers=None, data=None, expected_status=None):
    """Test an endpoint"""
    try:
        if method == 'GET':
            response = requests.get(url, headers=headers, timeout=10)
        elif method == 'POST':
            response = requests.post(url, json=data, headers=headers, timeout=10)
        elif method == 'PUT':
            response = requests.put(url, json=data, headers=headers, timeout=10)
        elif method == 'PATCH':
            response = requests.patch(url, json=data, headers=headers, timeout=10)
        elif method == 'DELETE':
            response = requests.delete(url, headers=headers, timeout=10)
        
        status_ok = True
        if expected_status:
            status_ok = response.status_code in expected_status if isinstance(expected_status, list) else response.status_code == expected_status
        
        if status_ok:
            results['passed'].append(f"{name} - {method} {url} - Status: {response.status_code}")
            return True, response
        else:
            error_msg = response.text[:200] if hasattr(response, 'text') else str(response)
            results['failed'].append(f"{name} - {method} {url} - Status: {response.status_code} (Expected: {expected_status}) - {error_msg}")
            return False, response
    except Exception as e:
        results['failed'].append(f"{name} - {method} {url} - Error: {str(e)}")
        return False, None

def run_all_tests():
    """Run comprehensive endpoint tests"""
    
    print("="*60)
    print("AnimalGuardian Comprehensive Endpoint Testing")
    print("="*60)
    print()
    
    # Test each user type
    for user_type, user_data in TEST_USERS.items():
        print(f"\nTesting as {user_type.upper()}...")
        print("-" * 60)
        
        token, user = login_user(user_type, user_data)
        if not token:
            print(f"  [FAIL] Login failed for {user_type}")
            results['skipped'].append(f"All {user_type} tests - Login failed")
            continue
        
        print(f"  [OK] Logged in as {user.get('username', user_type)}")
        headers = {"Authorization": f"Bearer {token}"}
        
        # Authentication endpoints
        test_endpoint("Token Refresh", "POST", f"{BACKEND_URL}/auth/refresh/", 
                     data={"refresh": requests.post(f"{BACKEND_URL}/auth/login/", 
                     json={'email' if 'email' in user_data else 'phone_number': user_data.get('email') or user_data.get('phone'), 
                     'password': user_data['password']}, timeout=10).json().get('refresh')}, 
                     expected_status=[200])
        
        # Cases endpoints
        test_endpoint("List Cases", "GET", f"{BACKEND_URL}/cases/reports/", headers=headers, expected_status=[200])
        test_endpoint("List Diseases", "GET", f"{BACKEND_URL}/cases/diseases/", headers=headers, expected_status=[200])
        
        # Livestock endpoints
        test_endpoint("List Livestock", "GET", f"{BACKEND_URL}/livestock/", headers=headers, expected_status=[200])
        test_endpoint("List Livestock Types", "GET", f"{BACKEND_URL}/livestock/types/", headers=headers, expected_status=[200])
        test_endpoint("List Breeds", "GET", f"{BACKEND_URL}/livestock/breeds/", headers=headers, expected_status=[200])
        
        # User endpoints
        test_endpoint("List Users", "GET", f"{BACKEND_URL}/accounts/users/", headers=headers, expected_status=[200])
        test_endpoint("List Farmers", "GET", f"{BACKEND_URL}/accounts/farmers/", headers=headers, expected_status=[200])
        test_endpoint("List Veterinarians", "GET", f"{BACKEND_URL}/accounts/veterinarians/", headers=headers, expected_status=[200])
        
        # Dashboard
        test_endpoint("Dashboard Stats", "GET", f"{BACKEND_URL}/dashboard/stats/", headers=headers, expected_status=[200])
        
        # Notifications
        test_endpoint("List Notifications", "GET", f"{BACKEND_URL}/notifications/", headers=headers, expected_status=[200])
        
        # Community
        test_endpoint("List Posts", "GET", f"{BACKEND_URL}/community/posts/", headers=headers, expected_status=[200])
        test_endpoint("List Comments", "GET", f"{BACKEND_URL}/community/comments/", headers=headers, expected_status=[200])
        
        # Weather
        test_endpoint("Weather Info", "GET", f"{BACKEND_URL}/weather/", headers=headers, expected_status=[200])
        
        # Files
        test_endpoint("File Upload Endpoint", "GET", f"{BACKEND_URL}/files/upload/", headers=headers, expected_status=[200, 405, 400])
        
        # Special tests for sector vet/admin
        if user_type in ['sector_vet', 'admin']:
            test_endpoint("Pending Approvals", "GET", f"{BACKEND_URL}/accounts/users/pending_approval/", 
                         headers=headers, expected_status=[200])
            test_endpoint("Case Assignment", "POST", f"{BACKEND_URL}/cases/reports/1/assign/", 
                         headers=headers, data={"veterinarian_id": 1}, expected_status=[200, 400, 404])
    
    # Public endpoints (no auth)
    print("\nTesting Public Endpoints...")
    print("-" * 60)
    test_endpoint("Marketplace Products", "GET", f"{BACKEND_URL}/marketplace/products/", expected_status=[200, 500])
    test_endpoint("Marketplace Categories", "GET", f"{BACKEND_URL}/marketplace/categories/", expected_status=[200, 500])
    test_endpoint("User Registration", "POST", f"{BACKEND_URL}/auth/register/", 
                 data={"phone_number": "+250999999999", "username": "test", "password": "Test@123"}, 
                 expected_status=[200, 201, 400])
    
    # Print summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    print(f"[PASS] Passed: {len(results['passed'])}")
    print(f"[FAIL] Failed: {len(results['failed'])}")
    print(f"[SKIP] Skipped: {len(results['skipped'])}")
    print("="*60)
    
    if results['failed']:
        print("\nFAILED TESTS:")
        print("-" * 60)
        for fail in results['failed'][:20]:  # Show first 20 failures
            print(f"  - {fail}")
        if len(results['failed']) > 20:
            print(f"  ... and {len(results['failed']) - 20} more failures")
    
    return results

if __name__ == "__main__":
    run_all_tests()

