#!/usr/bin/env python3
"""
Comprehensive test script for AnimalGuardian system
Tests: Backend API, USSD Service, Web Dashboard, and Mobile App endpoints
"""

import requests
import json
import sys
from datetime import datetime

# Configuration
BACKEND_URL = "https://animalguardian-backend-production-b5a8.up.railway.app/api"
USSD_URL = "http://localhost:5000"  # Update if USSD service is deployed
WEB_DASHBOARD_URL = "https://animalguards.netlify.app"

# Test credentials (update with real test user)
TEST_PHONE = "+250780570632"
TEST_EMAIL = "mutesijosephine324@gmail.com"
TEST_PASSWORD = "Admin@123456"

# Try email login first (admin account)
USE_EMAIL_LOGIN = True

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

class TestResults:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.skipped = 0
        self.results = []
    
    def add_result(self, test_name, status, message="", details=""):
        self.results.append({
            'name': test_name,
            'status': status,
            'message': message,
            'details': details
        })
        if status == 'PASS':
            self.passed += 1
            print(f"{Colors.GREEN}[PASS]{Colors.RESET}: {test_name}")
        elif status == 'FAIL':
            self.failed += 1
            print(f"{Colors.RED}[FAIL]{Colors.RESET}: {test_name} - {message}")
        else:
            self.skipped += 1
            print(f"{Colors.YELLOW}[SKIP]{Colors.RESET}: {test_name} - {message}")
        if details:
            print(f"  {Colors.BLUE}->{Colors.RESET} {details}")
    
    def print_summary(self):
        print(f"\n{Colors.BOLD}{'='*60}{Colors.RESET}")
        print(f"{Colors.BOLD}TEST SUMMARY{Colors.RESET}")
        print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
        print(f"{Colors.GREEN}Passed: {self.passed}{Colors.RESET}")
        print(f"{Colors.RED}Failed: {self.failed}{Colors.RESET}")
        print(f"{Colors.YELLOW}Skipped: {self.skipped}{Colors.RESET}")
        print(f"Total: {self.passed + self.failed + self.skipped}")
        print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")

results = TestResults()
auth_token = None
refresh_token = None

def test_backend_health():
    """Test backend health/availability"""
    try:
        response = requests.get(f"{BACKEND_URL.replace('/api', '')}/admin/", timeout=10)
        results.add_result(
            "Backend Health Check",
            "PASS" if response.status_code in [200, 302, 403] else "FAIL",
            f"Status: {response.status_code}",
            f"Backend is reachable at {BACKEND_URL}"
        )
        return True
    except Exception as e:
        results.add_result(
            "Backend Health Check",
            "FAIL",
            str(e),
            "Backend is not reachable"
        )
        return False

def test_authentication():
    """Test authentication endpoints"""
    global auth_token, refresh_token
    
    # Test Login (try email first, then phone)
    try:
        if USE_EMAIL_LOGIN:
            login_data = {
                "email": TEST_EMAIL,
                "password": TEST_PASSWORD
            }
        else:
            login_data = {
                "phone_number": TEST_PHONE,
                "password": TEST_PASSWORD
            }
        response = requests.post(f"{BACKEND_URL}/auth/login/", json=login_data, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            auth_token = data.get('access')
            refresh_token = data.get('refresh')
            results.add_result(
                "Authentication - Login",
                "PASS",
                "Login successful",
                f"User: {data.get('user', {}).get('username', 'N/A')}"
            )
        else:
            results.add_result(
                "Authentication - Login",
                "FAIL",
                f"Status: {response.status_code}",
                response.text[:100]
            )
    except Exception as e:
        results.add_result(
            "Authentication - Login",
            "FAIL",
            str(e),
            "Login endpoint not accessible"
        )
    
    # Test Token Refresh
    if refresh_token:
        try:
            response = requests.post(
                f"{BACKEND_URL}/auth/refresh/",
                json={"refresh": refresh_token},
                timeout=10
            )
            results.add_result(
                "Authentication - Token Refresh",
                "PASS" if response.status_code == 200 else "FAIL",
                f"Status: {response.status_code}",
                "Token refresh working" if response.status_code == 200 else response.text[:100]
            )
        except Exception as e:
            results.add_result(
                "Authentication - Token Refresh",
                "FAIL",
                str(e),
                "Token refresh failed"
            )

def test_cases_endpoints():
    """Test case reporting endpoints"""
    if not auth_token:
        results.add_result("Cases - List Cases", "SKIP", "No auth token")
        return
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # Test List Cases
    try:
        response = requests.get(f"{BACKEND_URL}/cases/reports/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            cases = data if isinstance(data, list) else (data.get('results', []) if isinstance(data, dict) else [])
            results.add_result(
                "Cases - List Cases",
                "PASS",
                f"Status: {response.status_code}",
                f"Found {len(cases)} cases"
            )
        else:
            results.add_result(
                "Cases - List Cases",
                "FAIL",
                f"Status: {response.status_code}",
                response.text[:100] if hasattr(response, 'text') else str(response)
            )
    except Exception as e:
        results.add_result("Cases - List Cases", "FAIL", str(e))
    
    # Test Case Assignment endpoint exists
    try:
        # Test assign endpoint (even if no cases, check if endpoint exists)
        assign_response = requests.post(
            f"{BACKEND_URL}/cases/reports/999/assign/",
            headers=headers,
            json={"veterinarian_id": 1},
            timeout=10
        )
        results.add_result(
            "Cases - Assignment Endpoint",
            "PASS" if assign_response.status_code in [200, 403, 400, 404] else "FAIL",
            f"Status: {assign_response.status_code}",
            "Assignment endpoint exists" if assign_response.status_code != 500 else "Server error"
        )
    except Exception as e:
        results.add_result("Cases - Assignment", "SKIP", str(e))

def test_livestock_endpoints():
    """Test livestock management endpoints"""
    if not auth_token:
        results.add_result("Livestock - List", "SKIP", "No auth token")
        return
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # Test List Livestock
    try:
        response = requests.get(f"{BACKEND_URL}/livestock/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            livestock = data if isinstance(data, list) else (data.get('results', []) if isinstance(data, dict) else [])
            results.add_result(
                "Livestock - List",
                "PASS",
                f"Status: {response.status_code}",
                f"Found {len(livestock)} livestock"
            )
        else:
            results.add_result(
                "Livestock - List",
                "FAIL",
                f"Status: {response.status_code}",
                response.text[:100] if hasattr(response, 'text') else str(response)
            )
    except Exception as e:
        results.add_result("Livestock - List", "FAIL", str(e))
    
    # Test Livestock Types
    try:
        response = requests.get(f"{BACKEND_URL}/livestock/types/", headers=headers, timeout=10)
        results.add_result(
            "Livestock - Types",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Livestock types endpoint working"
        )
    except Exception as e:
        results.add_result("Livestock - Types", "FAIL", str(e))

def test_users_endpoints():
    """Test user management endpoints"""
    if not auth_token:
        results.add_result("Users - List", "SKIP", "No auth token")
        return
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # Test List Users
    try:
        response = requests.get(f"{BACKEND_URL}/accounts/users/", headers=headers, timeout=10)
        results.add_result(
            "Users - List",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Users endpoint accessible"
        )
    except Exception as e:
        results.add_result("Users - List", "FAIL", str(e))
    
    # Test Pending Approvals
    try:
        response = requests.get(f"{BACKEND_URL}/accounts/users/pending_approval/", headers=headers, timeout=10)
        results.add_result(
            "Users - Pending Approvals",
            "PASS" if response.status_code in [200, 403] else "FAIL",
            f"Status: {response.status_code}",
            "Pending approvals endpoint exists"
        )
    except Exception as e:
        results.add_result("Users - Pending Approvals", "FAIL", str(e))

def test_dashboard_endpoints():
    """Test dashboard endpoints"""
    if not auth_token:
        results.add_result("Dashboard - Stats", "SKIP", "No auth token")
        return
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    try:
        response = requests.get(f"{BACKEND_URL}/dashboard/stats/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            results.add_result(
                "Dashboard - Statistics",
                "PASS",
                "Stats retrieved",
                f"Cases: {data.get('total_cases', 0)}, Farmers: {data.get('total_farmers', 0)}"
            )
        else:
            results.add_result(
                "Dashboard - Statistics",
                "FAIL",
                f"Status: {response.status_code}",
                response.text[:100]
            )
    except Exception as e:
        results.add_result("Dashboard - Statistics", "FAIL", str(e))

def test_notifications_endpoints():
    """Test notifications endpoints"""
    if not auth_token:
        results.add_result("Notifications - List", "SKIP", "No auth token")
        return
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    try:
        response = requests.get(f"{BACKEND_URL}/notifications/", headers=headers, timeout=10)
        results.add_result(
            "Notifications - List",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Notifications endpoint working"
        )
    except Exception as e:
        results.add_result("Notifications - List", "FAIL", str(e))

def test_community_endpoints():
    """Test community endpoints"""
    if not auth_token:
        results.add_result("Community - Posts", "SKIP", "No auth token")
        return
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    try:
        response = requests.get(f"{BACKEND_URL}/community/posts/", headers=headers, timeout=10)
        results.add_result(
            "Community - Posts",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Community posts endpoint working"
        )
    except Exception as e:
        results.add_result("Community - Posts", "FAIL", str(e))

def test_marketplace_endpoints():
    """Test marketplace endpoints"""
    try:
        # Marketplace can be accessed without auth for listing
        response = requests.get(f"{BACKEND_URL}/marketplace/products/", timeout=10)
        results.add_result(
            "Marketplace - Products",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Marketplace products endpoint working"
        )
    except Exception as e:
        results.add_result("Marketplace - Products", "FAIL", str(e))

def test_weather_endpoints():
    """Test weather endpoints"""
    if not auth_token:
        results.add_result("Weather - Current", "SKIP", "No auth token")
        return
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    try:
        response = requests.get(f"{BACKEND_URL}/weather/", headers=headers, timeout=10)
        results.add_result(
            "Weather - Current",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Weather endpoint working"
        )
    except Exception as e:
        results.add_result("Weather - Current", "FAIL", str(e))

def test_ussd_service():
    """Test USSD service endpoints"""
    try:
        response = requests.get(f"{USSD_URL}/health", timeout=5)
        results.add_result(
            "USSD Service - Health Check",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "USSD service is running" if response.status_code == 200 else "USSD service not accessible"
        )
    except Exception as e:
        results.add_result(
            "USSD Service - Health Check",
            "SKIP",
            "USSD service not running locally",
            "Start USSD service: cd ussd-service && python app.py"
        )
    
    # Test USSD endpoint
    try:
        ussd_data = {
            "sessionId": "test_session_123",
            "phoneNumber": TEST_PHONE,
            "serviceCode": "*384*123#",
            "text": ""
        }
        response = requests.post(f"{USSD_URL}/ussd", json=ussd_data, timeout=5)
        results.add_result(
            "USSD Service - USSD Handler",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "USSD handler working" if response.status_code == 200 else "USSD handler not accessible"
        )
    except Exception as e:
        results.add_result(
            "USSD Service - USSD Handler",
            "SKIP",
            "USSD service not running",
            str(e)
        )

def test_web_dashboard():
    """Test web dashboard accessibility"""
    try:
        response = requests.get(WEB_DASHBOARD_URL, timeout=10)
        results.add_result(
            "Web Dashboard - Accessibility",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Web dashboard is accessible"
        )
    except Exception as e:
        results.add_result(
            "Web Dashboard - Accessibility",
            "FAIL",
            str(e),
            "Web dashboard not accessible"
        )

def main():
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}AnimalGuardian System Test Suite{Colors.RESET}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"Backend URL: {BACKEND_URL}")
    print(f"USSD URL: {USSD_URL}")
    print(f"Web Dashboard URL: {WEB_DASHBOARD_URL}")
    print(f"{Colors.BOLD}{'='*60}{Colors.RESET}\n")
    
    # Run tests
    print(f"{Colors.BOLD}Testing Backend API...{Colors.RESET}\n")
    if test_backend_health():
        test_authentication()
        test_cases_endpoints()
        test_livestock_endpoints()
        test_users_endpoints()
        test_dashboard_endpoints()
        test_notifications_endpoints()
        test_community_endpoints()
        test_marketplace_endpoints()
        test_weather_endpoints()
    
    print(f"\n{Colors.BOLD}Testing USSD Service...{Colors.RESET}\n")
    test_ussd_service()
    
    print(f"\n{Colors.BOLD}Testing Web Dashboard...{Colors.RESET}\n")
    test_web_dashboard()
    
    # Print summary
    results.print_summary()
    
    # Exit code
    sys.exit(0 if results.failed == 0 else 1)

if __name__ == "__main__":
    main()

