#!/usr/bin/env python
"""
Test script to verify all dashboard pages are fetching real data from the backend.
"""
import requests
import json
import sys

BACKEND_URL = "https://animalguardian.onrender.com"

def test_endpoint(name, method, url, headers=None, data=None, expected_status=200):
    """Test an API endpoint."""
    try:
        if method == 'GET':
            response = requests.get(url, headers=headers, timeout=10)
        elif method == 'POST':
            response = requests.post(url, headers=headers, json=data, timeout=10)
        else:
            print(f"❌ {name}: Unsupported method {method}")
            return False
        
        if response.status_code == expected_status:
            try:
                data = response.json()
                if isinstance(data, list):
                    print(f"[OK] {name}: Status {response.status_code}, Returned {len(data)} items")
                elif isinstance(data, dict) and 'results' in data:
                    print(f"[OK] {name}: Status {response.status_code}, Returned {len(data['results'])} items")
                else:
                    print(f"[OK] {name}: Status {response.status_code}, Data received")
                return True
            except:
                print(f"[OK] {name}: Status {response.status_code}, Response received")
                return True
        else:
            print(f"[FAIL] {name}: Status {response.status_code} (expected {expected_status})")
            try:
                error_data = response.json()
                print(f"   Error: {error_data}")
            except:
                print(f"   Error: {response.text[:200]}")
            return False
    except Exception as e:
        print(f"[FAIL] {name}: Exception - {str(e)}")
        return False

def main():
    print("=" * 70)
    print("Testing All Dashboard Pages - Backend API Endpoints")
    print("=" * 70)
    print()
    
    # First, login to get an access token
    print("Step 1: Logging in as admin...")
    login_url = f"{BACKEND_URL}/api/auth/login/"
    login_data = {
        "email": "mutesijosephine324@gmail.com",
        "password": "Admin@123456"
    }
    
    try:
        login_response = requests.post(login_url, json=login_data, timeout=10)
        if login_response.status_code != 200:
            print(f"[FAIL] Login failed: Status {login_response.status_code}")
            print(f"   Error: {login_response.text}")
            return
        
        login_data = login_response.json()
        access_token = login_data.get('access')
        if not access_token:
            print("[FAIL] Login failed: No access token received")
            return
        
        print(f"[OK] Login successful! User: {login_data.get('user', {}).get('email', 'Unknown')}")
        print()
        
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }
        
        # Test all dashboard endpoints
        endpoints = [
            # Dashboard
            ("Dashboard Stats", "GET", f"{BACKEND_URL}/api/dashboard/stats/"),
            
            # Cases
            ("Cases List", "GET", f"{BACKEND_URL}/api/cases/reports/"),
            
            # Veterinarians
            ("Veterinarians List", "GET", f"{BACKEND_URL}/api/veterinarians/"),
            
            # Farmers
            ("Farmers List", "GET", f"{BACKEND_URL}/api/farmers/"),
            
            # Livestock
            ("Livestock List", "GET", f"{BACKEND_URL}/api/livestock/"),
            ("Livestock Types", "GET", f"{BACKEND_URL}/api/livestock/types/"),
            ("Livestock Breeds", "GET", f"{BACKEND_URL}/api/livestock/breeds/"),
            
            # Notifications
            ("Notifications List", "GET", f"{BACKEND_URL}/api/notifications/"),
            
            # User Approval
            ("Pending Approvals", "GET", f"{BACKEND_URL}/api/users/pending_approval/"),
            
            # Users
            ("Users List", "GET", f"{BACKEND_URL}/api/users/"),
        ]
        
        print("Step 2: Testing all dashboard endpoints...")
        print()
        
        results = []
        for name, method, url in endpoints:
            result = test_endpoint(name, method, url, headers=headers)
            results.append((name, result))
        
        print()
        print("=" * 70)
        print("Summary")
        print("=" * 70)
        
        passed = sum(1 for _, result in results if result)
        total = len(results)
        
        for name, result in results:
            status = "[PASS]" if result else "[FAIL]"
            print(f"{status}: {name}")
        
        print()
        print(f"Total: {passed}/{total} endpoints working")
        
        if passed == total:
            print("[OK] All endpoints are working correctly!")
        else:
            print(f"[WARN] {total - passed} endpoint(s) need attention")
        
    except Exception as e:
        print(f"[ERROR] Error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()

