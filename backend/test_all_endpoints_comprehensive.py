#!/usr/bin/env python
"""
Comprehensive test script to verify all backend endpoints and communication
"""
import os
import sys
import requests
import json
from datetime import datetime

# Railway backend URL
BACKEND_URL = os.environ.get(
    'BACKEND_URL',
    'https://animalguardian-backend-production-b5a8.up.railway.app'
)

# Test credentials
TEST_EMAIL = "mutesijosephine324@gmail.com"
TEST_PASSWORD = "Admin@123456"

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'

def print_success(message):
    try:
        print(f"{Colors.GREEN}[PASS] {message}{Colors.RESET}")
    except UnicodeEncodeError:
        print(f"[PASS] {message}")

def print_error(message):
    try:
        print(f"{Colors.RED}[FAIL] {message}{Colors.RESET}")
    except UnicodeEncodeError:
        print(f"[FAIL] {message}")

def print_info(message):
    try:
        print(f"{Colors.BLUE}[INFO] {message}{Colors.RESET}")
    except UnicodeEncodeError:
        print(f"[INFO] {message}")

def print_warning(message):
    try:
        print(f"{Colors.YELLOW}[WARN] {message}{Colors.RESET}")
    except UnicodeEncodeError:
        print(f"[WARN] {message}")

def test_health_check():
    """Test health check endpoint"""
    print("\n" + "="*60)
    print("1. Testing Health Check Endpoint")
    print("="*60)
    try:
        response = requests.get(f"{BACKEND_URL}/api/dashboard/health/", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print_success(f"Health check passed: {data.get('status', 'unknown')}")
            if 'schema' in data:
                schema = data['schema']
                if schema.get('schema_issue'):
                    print_warning("Database schema issue detected")
                else:
                    print_success("Database schema is correct")
            return True
        else:
            print_error(f"Health check failed: {response.status_code}")
            print(response.text[:200])
            return False
    except Exception as e:
        print_error(f"Health check error: {str(e)}")
        return False

def test_login():
    """Test login endpoint"""
    print("\n" + "="*60)
    print("2. Testing Login Endpoint")
    print("="*60)
    try:
        response = requests.post(
            f"{BACKEND_URL}/api/auth/login/",
            json={"email": TEST_EMAIL, "password": TEST_PASSWORD},
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        if response.status_code == 200:
            data = response.json()
            access_token = data.get('access')
            refresh_token = data.get('refresh')
            user = data.get('user', {})
            print_success(f"Login successful for user: {user.get('email', 'unknown')}")
            print_info(f"User type: {user.get('user_type', 'unknown')}")
            return access_token, refresh_token, user
        else:
            print_error(f"Login failed: {response.status_code}")
            try:
                error_data = response.json()
                print_error(f"Error: {error_data.get('error', 'Unknown error')}")
            except:
                print_error(f"Response: {response.text[:200]}")
            return None, None, None
    except Exception as e:
        print_error(f"Login error: {str(e)}")
        return None, None, None

def test_endpoint(name, method, url, headers=None, data=None, expected_status=200):
    """Generic endpoint test"""
    try:
        if method.upper() == 'GET':
            response = requests.get(url, headers=headers, timeout=10)
        elif method.upper() == 'POST':
            response = requests.post(url, json=data, headers=headers, timeout=10)
        elif method.upper() == 'PATCH':
            response = requests.patch(url, json=data, headers=headers, timeout=10)
        elif method.upper() == 'DELETE':
            response = requests.delete(url, headers=headers, timeout=10)
        else:
            print_error(f"Unsupported method: {method}")
            return False
        
        if response.status_code == expected_status:
            print_success(f"{name}: {response.status_code}")
            return True
        else:
            print_error(f"{name}: {response.status_code} (expected {expected_status})")
            try:
                error_data = response.json()
                if 'error' in error_data:
                    print_error(f"  Error: {error_data['error']}")
                elif 'detail' in error_data:
                    print_error(f"  Detail: {error_data['detail']}")
            except:
                pass
            return False
    except Exception as e:
        print_error(f"{name}: Exception - {str(e)}")
        return False

def test_all_endpoints(access_token):
    """Test all API endpoints"""
    print("\n" + "="*60)
    print("3. Testing All API Endpoints")
    print("="*60)
    
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }
    
    api_base = f"{BACKEND_URL}/api"
    results = []
    
    # Dashboard endpoints
    print("\n--- Dashboard Endpoints ---")
    results.append(("Dashboard Stats", test_endpoint(
        "Dashboard Stats", "GET", f"{api_base}/dashboard/stats/", headers
    )))
    
    # Cases endpoints
    print("\n--- Cases Endpoints ---")
    results.append(("Cases List", test_endpoint(
        "Cases List", "GET", f"{api_base}/cases/reports/", headers
    )))
    
    # Livestock endpoints
    print("\n--- Livestock Endpoints ---")
    results.append(("Livestock List", test_endpoint(
        "Livestock List", "GET", f"{api_base}/livestock/", headers
    )))
    results.append(("Livestock Types", test_endpoint(
        "Livestock Types", "GET", f"{api_base}/livestock/types/", headers
    )))
    results.append(("Livestock Breeds", test_endpoint(
        "Livestock Breeds", "GET", f"{api_base}/livestock/breeds/", headers
    )))
    
    # Users endpoints
    print("\n--- Users Endpoints ---")
    results.append(("Users List", test_endpoint(
        "Users List", "GET", f"{api_base}/users/", headers
    )))
    results.append(("Farmers List", test_endpoint(
        "Farmers List", "GET", f"{api_base}/farmers/", headers
    )))
    results.append(("Veterinarians List", test_endpoint(
        "Veterinarians List", "GET", f"{api_base}/veterinarians/", headers
    )))
    
    # Community endpoints
    print("\n--- Community Endpoints ---")
    results.append(("Community Posts", test_endpoint(
        "Community Posts", "GET", f"{api_base}/community/posts/", headers
    )))
    
    # Marketplace endpoints
    print("\n--- Marketplace Endpoints ---")
    results.append(("Marketplace Listings", test_endpoint(
        "Marketplace Listings", "GET", f"{api_base}/marketplace/listings/", headers
    )))
    
    # Notifications endpoints
    print("\n--- Notifications Endpoints ---")
    results.append(("Notifications List", test_endpoint(
        "Notifications List", "GET", f"{api_base}/notifications/", headers
    )))
    
    # Weather endpoints
    print("\n--- Weather Endpoints ---")
    results.append(("Weather Forecast", test_endpoint(
        "Weather Forecast", "GET", f"{api_base}/weather/forecast/", headers
    )))
    
    return results

def test_cors():
    """Test CORS configuration"""
    print("\n" + "="*60)
    print("4. Testing CORS Configuration")
    print("="*60)
    
    test_origins = [
        "http://localhost:3000",
        "http://localhost:3001",
        "http://localhost:60524",
        "http://127.0.0.1:3000",
        "https://animalguards.netlify.app",
    ]
    
    cors_results = []
    for origin in test_origins:
        try:
            response = requests.options(
                f"{BACKEND_URL}/api/dashboard/health/",
                headers={
                    'Origin': origin,
                    'Access-Control-Request-Method': 'GET',
                },
                timeout=5
            )
            cors_header = response.headers.get('Access-Control-Allow-Origin', '')
            if cors_header == origin or cors_header == '*':
                print_success(f"CORS allowed for {origin}")
                cors_results.append(True)
            else:
                print_warning(f"CORS not configured for {origin} (got: {cors_header})")
                cors_results.append(False)
        except Exception as e:
            print_error(f"CORS test failed for {origin}: {str(e)}")
            cors_results.append(False)
    
    return cors_results

def main():
    print("\n" + "="*60)
    print("COMPREHENSIVE BACKEND API TEST")
    print("="*60)
    print(f"Backend URL: {BACKEND_URL}")
    print(f"Test Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Test 1: Health Check
    health_ok = test_health_check()
    if not health_ok:
        print_error("\nHealth check failed. Backend may not be running properly.")
        return
    
    # Test 2: Login
    access_token, refresh_token, user = test_login()
    if not access_token:
        print_error("\nLogin failed. Cannot test authenticated endpoints.")
        return
    
    # Test 3: All Endpoints
    endpoint_results = test_all_endpoints(access_token)
    
    # Test 4: CORS
    cors_results = test_cors()
    
    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    
    total_tests = 1 + 1 + len(endpoint_results) + len(cors_results)
    passed_tests = (
        (1 if health_ok else 0) +
        (1 if access_token else 0) +
        sum(1 for r in endpoint_results if r[1]) +
        sum(1 for r in cors_results if r)
    )
    
    print(f"\nTotal Tests: {total_tests}")
    print_success(f"Passed: {passed_tests}")
    print_error(f"Failed: {total_tests - passed_tests}")
    print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")
    
    print("\n--- Endpoint Results ---")
    for name, result in endpoint_results:
        status = "PASS" if result else "FAIL"
        color = Colors.GREEN if result else Colors.RED
        print(f"{color}{status}{Colors.RESET}: {name}")
    
    if passed_tests == total_tests:
        print_success("\n✓ All tests passed! Backend is working correctly.")
    else:
        print_warning(f"\n⚠ {total_tests - passed_tests} test(s) failed. Please review the errors above.")

if __name__ == '__main__':
    main()

