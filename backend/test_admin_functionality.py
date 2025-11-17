#!/usr/bin/env python
"""
Test script to verify all admin dashboard functionalities
"""
import os
import django
import requests
import json

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken

def test_admin_functionality():
    """Test all admin dashboard endpoints"""
    
    # Get admin user
    try:
        admin = User.objects.get(email='mutesijosephine324@gmail.com')
        print(f"Admin user found: {admin.email}")
    except User.DoesNotExist:
        print("ERROR: Admin user not found!")
        return None
    
    # Get JWT token
    refresh = RefreshToken.for_user(admin)
    access_token = str(refresh.access_token)
    
    # Base URL - adjust this to your backend URL
    base_url = os.environ.get('BACKEND_URL', 'http://localhost:8000')
    api_base = f"{base_url}/api"
    
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }
    
    print("\n" + "="*60)
    print("TESTING ADMIN DASHBOARD FUNCTIONALITIES")
    print("="*60 + "\n")
    
    tests_passed = 0
    tests_failed = 0
    
    # Test 1: Dashboard Stats
    print("1. Testing Dashboard Stats...")
    try:
        response = requests.get(f"{api_base}/dashboard/stats/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"   [PASS] Dashboard stats loaded")
            print(f"   - Total Cases: {data.get('total_cases', 0)}")
            print(f"   - Total Farmers: {data.get('total_farmers', 0)}")
            print(f"   - Total Veterinarians: {data.get('total_veterinarians', 0)}")
            tests_passed += 1
        else:
            print(f"   [FAIL] Status: {response.status_code}")
            tests_failed += 1
    except Exception as e:
        print(f"   [FAIL] Error: {str(e)}")
        tests_failed += 1
    
    # Test 2: Cases API
    print("\n2. Testing Cases API...")
    try:
        response = requests.get(f"{api_base}/cases/reports/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            cases = data.get('results', []) if isinstance(data, dict) else data
            print(f"   [PASS] Cases API working - {len(cases)} cases found")
            tests_passed += 1
        else:
            print(f"   [FAIL] Status: {response.status_code}")
            tests_failed += 1
    except Exception as e:
        print(f"   [FAIL] Error: {str(e)}")
        tests_failed += 1
    
    # Test 3: Users API
    print("\n3. Testing Users API...")
    try:
        response = requests.get(f"{api_base}/users/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            users = data.get('results', []) if isinstance(data, dict) else data
            print(f"   [PASS] Users API working - {len(users)} users found")
            tests_passed += 1
        else:
            print(f"   [FAIL] Status: {response.status_code}")
            tests_failed += 1
    except Exception as e:
        print(f"   [FAIL] Error: {str(e)}")
        tests_failed += 1
    
    # Test 4: Veterinarians API
    print("\n4. Testing Veterinarians API...")
    try:
        response = requests.get(f"{api_base}/veterinarians/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            vets = data.get('results', []) if isinstance(data, dict) else data
            print(f"   [PASS] Veterinarians API working - {len(vets)} veterinarians found")
            tests_passed += 1
        else:
            print(f"   [FAIL] Status: {response.status_code}")
            tests_failed += 1
    except Exception as e:
        print(f"   [FAIL] Error: {str(e)}")
        tests_failed += 1
    
    # Test 5: Farmers API
    print("\n5. Testing Farmers API...")
    try:
        response = requests.get(f"{api_base}/farmers/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            farmers = data.get('results', []) if isinstance(data, dict) else data
            print(f"   [PASS] Farmers API working - {len(farmers)} farmers found")
            tests_passed += 1
        else:
            print(f"   [FAIL] Status: {response.status_code}")
            tests_failed += 1
    except Exception as e:
        print(f"   [FAIL] Error: {str(e)}")
        tests_failed += 1
    
    # Test 6: Livestock API
    print("\n6. Testing Livestock API...")
    try:
        response = requests.get(f"{api_base}/livestock/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            livestock = data.get('results', []) if isinstance(data, dict) else data
            print(f"   [PASS] Livestock API working - {len(livestock)} livestock found")
            tests_passed += 1
        else:
            print(f"   [FAIL] Status: {response.status_code}")
            tests_failed += 1
    except Exception as e:
        print(f"   [FAIL] Error: {str(e)}")
        tests_failed += 1
    
    # Test 7: Notifications API
    print("\n7. Testing Notifications API...")
    try:
        response = requests.get(f"{api_base}/notifications/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            notifications = data.get('results', []) if isinstance(data, dict) else data
            print(f"   [PASS] Notifications API working - {len(notifications)} notifications found")
            tests_passed += 1
        else:
            print(f"   [FAIL] Status: {response.status_code}")
            tests_failed += 1
    except Exception as e:
        print(f"   [FAIL] Error: {str(e)}")
        tests_failed += 1
    
    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    print(f"Tests Passed: {tests_passed}")
    print(f"Tests Failed: {tests_failed}")
    print(f"Total Tests: {tests_passed + tests_failed}")
    print("="*60 + "\n")
    
    return tests_passed, tests_failed

if __name__ == '__main__':
    test_admin_functionality()

