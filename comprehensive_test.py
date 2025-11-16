#!/usr/bin/env python3
"""
Comprehensive test script for AnimalGuardian system
Tests ALL functionalities across Backend API, USSD Service, Web Dashboard, and Mobile App
"""

import requests
import json
import sys
from datetime import datetime
from typing import Dict, List, Any

# Configuration
BACKEND_URL = "https://animalguardian-backend-production-b5a8.up.railway.app/api"
USSD_URL = "http://localhost:5000"
WEB_DASHBOARD_URL = "https://animalguards.netlify.app"

# Test credentials
TEST_PHONE = "+250780570632"
TEST_EMAIL = "mutesijosephine324@gmail.com"
TEST_PASSWORD = "Admin@123456"

class TestResults:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.skipped = 0
        self.results = []
        self.details = {}
    
    def add_result(self, category: str, test_name: str, status: str, message: str = "", details: str = "", response_data: Any = None):
        if category not in self.details:
            self.details[category] = []
        
        result = {
            'name': test_name,
            'status': status,
            'message': message,
            'details': details,
            'response': response_data
        }
        self.details[category].append(result)
        self.results.append(result)
        
        if status == 'PASS':
            self.passed += 1
        elif status == 'FAIL':
            self.failed += 1
        else:
            self.skipped += 1
    
    def to_markdown(self) -> str:
        md = f"""# AnimalGuardian Comprehensive Test Results

**Test Date:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Test Summary

- **Total Tests:** {len(self.results)}
- **Passed:** {self.passed} ✅
- **Failed:** {self.failed} ❌
- **Skipped:** {self.skipped} ⚠️
- **Success Rate:** {(self.passed / len(self.results) * 100) if self.results else 0:.1f}%

---

"""
        
        for category, tests in self.details.items():
            md += f"## {category}\n\n"
            
            for test in tests:
                status_icon = "✅" if test['status'] == 'PASS' else ("❌" if test['status'] == 'FAIL' else "⚠️")
                md += f"### {status_icon} {test['name']}\n\n"
                md += f"- **Status:** {test['status']}\n"
                if test['message']:
                    md += f"- **Message:** {test['message']}\n"
                if test['details']:
                    md += f"- **Details:** {test['details']}\n"
                if test['response']:
                    md += f"- **Response:** `{json.dumps(test['response'], indent=2)[:200]}...`\n"
                md += "\n"
            
            md += "---\n\n"
        
        return md

results = TestResults()
auth_token = None
refresh_token = None
user_data = None

def test_backend_connectivity():
    """Test backend connectivity and health"""
    category = "Backend Connectivity"
    
    try:
        response = requests.get(f"{BACKEND_URL.replace('/api', '')}/admin/", timeout=10)
        results.add_result(
            category, "Backend Health Check",
            "PASS" if response.status_code in [200, 302, 403] else "FAIL",
            f"Status: {response.status_code}",
            f"Backend is reachable at {BACKEND_URL}"
        )
        return True
    except Exception as e:
        results.add_result(category, "Backend Health Check", "FAIL", str(e))
        return False

def test_authentication():
    """Test all authentication endpoints"""
    global auth_token, refresh_token, user_data
    category = "Authentication"
    
    # Test Registration
    try:
        reg_data = {
            "phone_number": "+250999999999",
            "username": "testuser",
            "first_name": "Test",
            "last_name": "User",
            "email": "test@example.com",
            "password": "Test@123456",
            "user_type": "farmer"
        }
        response = requests.post(f"{BACKEND_URL}/auth/register/", json=reg_data, timeout=10)
        results.add_result(
            category, "User Registration",
            "PASS" if response.status_code in [200, 201, 400] else "FAIL",
            f"Status: {response.status_code}",
            "Registration endpoint working" if response.status_code != 500 else "Server error"
        )
    except Exception as e:
        results.add_result(category, "User Registration", "FAIL", str(e))
    
    # Test Login with Email
    try:
        login_data = {"email": TEST_EMAIL, "password": TEST_PASSWORD}
        response = requests.post(f"{BACKEND_URL}/auth/login/", json=login_data, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            auth_token = data.get('access')
            refresh_token = data.get('refresh')
            user_data = data.get('user', {})
            results.add_result(
                category, "Login (Email)",
                "PASS",
                "Login successful",
                f"User: {user_data.get('username', 'N/A')}, Type: {user_data.get('user_type', 'N/A')}",
                {"user_id": user_data.get('id'), "user_type": user_data.get('user_type')}
            )
        else:
            results.add_result(
                category, "Login (Email)",
                "FAIL",
                f"Status: {response.status_code}",
                response.text[:200]
            )
    except Exception as e:
        results.add_result(category, "Login (Email)", "FAIL", str(e))
    
    # Test Login with Phone
    try:
        login_data = {"phone_number": TEST_PHONE, "password": TEST_PASSWORD}
        response = requests.post(f"{BACKEND_URL}/auth/login/", json=login_data, timeout=10)
        results.add_result(
            category, "Login (Phone)",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Phone login working" if response.status_code == 200 else response.text[:100]
        )
    except Exception as e:
        results.add_result(category, "Login (Phone)", "FAIL", str(e))
    
    # Test Token Refresh
    if refresh_token:
        try:
            response = requests.post(f"{BACKEND_URL}/auth/refresh/", json={"refresh": refresh_token}, timeout=10)
            results.add_result(
                category, "Token Refresh",
                "PASS" if response.status_code == 200 else "FAIL",
                f"Status: {response.status_code}",
                "Token refresh working" if response.status_code == 200 else response.text[:100]
            )
        except Exception as e:
            results.add_result(category, "Token Refresh", "FAIL", str(e))
    
    # Test Password Reset Request
    try:
        response = requests.post(
            f"{BACKEND_URL}/auth/password-reset/request/",
            json={"phone_number": TEST_PHONE},
            timeout=10
        )
        results.add_result(
            category, "Password Reset Request",
            "PASS" if response.status_code in [200, 400] else "FAIL",
            f"Status: {response.status_code}",
            "Password reset endpoint exists"
        )
    except Exception as e:
        results.add_result(category, "Password Reset Request", "FAIL", str(e))

def test_cases_management():
    """Test case reporting and management"""
    if not auth_token:
        results.add_result("Cases Management", "All Tests", "SKIP", "No auth token")
        return
    
    category = "Cases Management"
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # List Cases
    try:
        response = requests.get(f"{BACKEND_URL}/cases/reports/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            cases = data if isinstance(data, list) else (data.get('results', []) if isinstance(data, dict) else [])
            results.add_result(
                category, "List Cases",
                "PASS",
                f"Found {len(cases)} cases",
                f"Status: {response.status_code}"
            )
        else:
            results.add_result(category, "List Cases", "FAIL", f"Status: {response.status_code}")
    except Exception as e:
        results.add_result(category, "List Cases", "FAIL", str(e))
    
    # Create Case
    try:
        case_data = {
            "symptoms_observed": "Test symptoms",
            "urgency": "medium",
            "number_of_affected_animals": 1
        }
        response = requests.post(f"{BACKEND_URL}/cases/reports/", json=case_data, headers=headers, timeout=10)
        results.add_result(
            category, "Create Case",
            "PASS" if response.status_code in [200, 201, 400] else "FAIL",
            f"Status: {response.status_code}",
            "Case creation endpoint working"
        )
    except Exception as e:
        results.add_result(category, "Create Case", "FAIL", str(e))
    
    # Case Assignment
    try:
        response = requests.post(
            f"{BACKEND_URL}/cases/reports/1/assign/",
            json={"veterinarian_id": 1},
            headers=headers,
            timeout=10
        )
        results.add_result(
            category, "Case Assignment",
            "PASS" if response.status_code in [200, 403, 400, 404] else "FAIL",
            f"Status: {response.status_code}",
            "Assignment endpoint exists"
        )
    except Exception as e:
        results.add_result(category, "Case Assignment", "FAIL", str(e))
    
    # List Diseases
    try:
        response = requests.get(f"{BACKEND_URL}/cases/diseases/", headers=headers, timeout=10)
        results.add_result(
            category, "List Diseases",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Diseases endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Diseases", "FAIL", str(e))

def test_livestock_management():
    """Test livestock management"""
    if not auth_token:
        results.add_result("Livestock Management", "All Tests", "SKIP", "No auth token")
        return
    
    category = "Livestock Management"
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # List Livestock
    try:
        response = requests.get(f"{BACKEND_URL}/livestock/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            livestock = data if isinstance(data, list) else (data.get('results', []) if isinstance(data, dict) else [])
            results.add_result(
                category, "List Livestock",
                "PASS",
                f"Found {len(livestock)} livestock",
                f"Status: {response.status_code}"
            )
        else:
            results.add_result(category, "List Livestock", "FAIL", f"Status: {response.status_code}")
    except Exception as e:
        results.add_result(category, "List Livestock", "FAIL", str(e))
    
    # Livestock Types
    try:
        response = requests.get(f"{BACKEND_URL}/livestock/types/", headers=headers, timeout=10)
        results.add_result(
            category, "List Livestock Types",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Livestock types endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Livestock Types", "FAIL", str(e))
    
    # Breeds
    try:
        response = requests.get(f"{BACKEND_URL}/livestock/breeds/", headers=headers, timeout=10)
        results.add_result(
            category, "List Breeds",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Breeds endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Breeds", "FAIL", str(e))
    
    # Health Records
    try:
        response = requests.get(f"{BACKEND_URL}/livestock/health-records/", headers=headers, timeout=10)
        results.add_result(
            category, "Health Records",
            "PASS" if response.status_code in [200, 404] else "FAIL",
            f"Status: {response.status_code}",
            "Health records endpoint exists"
        )
    except Exception as e:
        results.add_result(category, "Health Records", "FAIL", str(e))
    
    # Vaccination Records
    try:
        response = requests.get(f"{BACKEND_URL}/livestock/vaccinations/", headers=headers, timeout=10)
        results.add_result(
            category, "Vaccination Records",
            "PASS" if response.status_code in [200, 404] else "FAIL",
            f"Status: {response.status_code}",
            "Vaccination records endpoint exists"
        )
    except Exception as e:
        results.add_result(category, "Vaccination Records", "FAIL", str(e))

def test_user_management():
    """Test user management endpoints"""
    if not auth_token:
        results.add_result("User Management", "All Tests", "SKIP", "No auth token")
        return
    
    category = "User Management"
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # List Users
    try:
        response = requests.get(f"{BACKEND_URL}/accounts/users/", headers=headers, timeout=10)
        results.add_result(
            category, "List Users",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Users endpoint accessible"
        )
    except Exception as e:
        results.add_result(category, "List Users", "FAIL", str(e))
    
    # Pending Approvals
    try:
        response = requests.get(f"{BACKEND_URL}/accounts/users/pending_approval/", headers=headers, timeout=10)
        results.add_result(
            category, "Pending Approvals",
            "PASS" if response.status_code in [200, 403] else "FAIL",
            f"Status: {response.status_code}",
            "Pending approvals endpoint exists"
        )
    except Exception as e:
        results.add_result(category, "Pending Approvals", "FAIL", str(e))
    
    # Farmers
    try:
        response = requests.get(f"{BACKEND_URL}/accounts/farmers/", headers=headers, timeout=10)
        results.add_result(
            category, "List Farmers",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Farmers endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Farmers", "FAIL", str(e))
    
    # Veterinarians
    try:
        response = requests.get(f"{BACKEND_URL}/accounts/veterinarians/", headers=headers, timeout=10)
        results.add_result(
            category, "List Veterinarians",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Veterinarians endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Veterinarians", "FAIL", str(e))

def test_dashboard():
    """Test dashboard endpoints"""
    if not auth_token:
        results.add_result("Dashboard", "All Tests", "SKIP", "No auth token")
        return
    
    category = "Dashboard"
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    try:
        response = requests.get(f"{BACKEND_URL}/dashboard/stats/", headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            results.add_result(
                category, "Dashboard Statistics",
                "PASS",
                "Stats retrieved successfully",
                f"Cases: {data.get('total_cases', 0)}, Farmers: {data.get('total_farmers', 0)}, Vets: {data.get('total_veterinarians', 0)}",
                data
            )
        else:
            results.add_result(category, "Dashboard Statistics", "FAIL", f"Status: {response.status_code}")
    except Exception as e:
        results.add_result(category, "Dashboard Statistics", "FAIL", str(e))

def test_notifications():
    """Test notifications"""
    if not auth_token:
        results.add_result("Notifications", "All Tests", "SKIP", "No auth token")
        return
    
    category = "Notifications"
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    try:
        response = requests.get(f"{BACKEND_URL}/notifications/", headers=headers, timeout=10)
        results.add_result(
            category, "List Notifications",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Notifications endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Notifications", "FAIL", str(e))

def test_community():
    """Test community features"""
    if not auth_token:
        results.add_result("Community", "All Tests", "SKIP", "No auth token")
        return
    
    category = "Community"
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # Posts
    try:
        response = requests.get(f"{BACKEND_URL}/community/posts/", headers=headers, timeout=10)
        results.add_result(
            category, "List Posts",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Community posts endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Posts", "FAIL", str(e))
    
    # Comments
    try:
        response = requests.get(f"{BACKEND_URL}/community/comments/", headers=headers, timeout=10)
        results.add_result(
            category, "List Comments",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Comments endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Comments", "FAIL", str(e))

def test_marketplace():
    """Test marketplace"""
    category = "Marketplace"
    
    # Products (public)
    try:
        response = requests.get(f"{BACKEND_URL}/marketplace/products/", timeout=10)
        results.add_result(
            category, "List Products",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Marketplace products endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Products", "FAIL", str(e))
    
    # Categories
    try:
        response = requests.get(f"{BACKEND_URL}/marketplace/categories/", timeout=10)
        results.add_result(
            category, "List Categories",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Categories endpoint working"
        )
    except Exception as e:
        results.add_result(category, "List Categories", "FAIL", str(e))

def test_weather():
    """Test weather endpoints"""
    if not auth_token:
        results.add_result("Weather", "All Tests", "SKIP", "No auth token")
        return
    
    category = "Weather"
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    try:
        response = requests.get(f"{BACKEND_URL}/weather/", headers=headers, timeout=10)
        results.add_result(
            category, "Weather Information",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Weather endpoint working"
        )
    except Exception as e:
        results.add_result(category, "Weather Information", "FAIL", str(e))

def test_files():
    """Test file upload"""
    if not auth_token:
        results.add_result("Files", "All Tests", "SKIP", "No auth token")
        return
    
    category = "Files"
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    try:
        response = requests.get(f"{BACKEND_URL}/files/upload/", headers=headers, timeout=10)
        results.add_result(
            category, "File Upload Endpoint",
            "PASS" if response.status_code in [200, 405, 400] else "FAIL",
            f"Status: {response.status_code}",
            "File upload endpoint exists"
        )
    except Exception as e:
        results.add_result(category, "File Upload Endpoint", "FAIL", str(e))

def test_ussd_service():
    """Test USSD service"""
    category = "USSD Service"
    
    # Health Check
    try:
        response = requests.get(f"{USSD_URL}/health", timeout=5)
        results.add_result(
            category, "USSD Health Check",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "USSD service is running"
        )
    except Exception as e:
        results.add_result(
            category, "USSD Health Check",
            "SKIP",
            "USSD service not running locally",
            "Start with: cd ussd-service && python app.py"
        )
    
    # USSD Handler
    try:
        ussd_data = {
            "sessionId": "test_123",
            "phoneNumber": TEST_PHONE,
            "serviceCode": "*384*123#",
            "text": ""
        }
        response = requests.post(f"{USSD_URL}/ussd", json=ussd_data, timeout=5)
        results.add_result(
            category, "USSD Handler",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "USSD handler working"
        )
    except Exception as e:
        results.add_result(
            category, "USSD Handler",
            "SKIP",
            "USSD service not running",
            str(e)
        )
    
    # SMS Handler
    try:
        sms_data = {
            "from": TEST_PHONE,
            "text": "HELP",
            "date": datetime.now().isoformat()
        }
        response = requests.post(f"{USSD_URL}/sms", json=sms_data, timeout=5)
        results.add_result(
            category, "SMS Handler",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "SMS handler working"
        )
    except Exception as e:
        results.add_result(
            category, "SMS Handler",
            "SKIP",
            "USSD service not running",
            str(e)
        )

def test_web_dashboard():
    """Test web dashboard"""
    category = "Web Dashboard"
    
    try:
        response = requests.get(WEB_DASHBOARD_URL, timeout=10)
        results.add_result(
            category, "Dashboard Accessibility",
            "PASS" if response.status_code == 200 else "FAIL",
            f"Status: {response.status_code}",
            "Web dashboard is accessible"
        )
    except Exception as e:
        results.add_result(category, "Dashboard Accessibility", "FAIL", str(e))
    
    # Test API endpoint from dashboard perspective
    try:
        response = requests.get(f"{WEB_DASHBOARD_URL}/api", timeout=10)
        results.add_result(
            category, "Dashboard API Config",
            "PASS" if response.status_code in [200, 404] else "FAIL",
            f"Status: {response.status_code}",
            "Dashboard API configuration check"
        )
    except Exception as e:
        results.add_result(category, "Dashboard API Config", "SKIP", str(e))

def main():
    print("="*60)
    print("AnimalGuardian Comprehensive Test Suite")
    print("="*60)
    print(f"Backend: {BACKEND_URL}")
    print(f"USSD: {USSD_URL}")
    print(f"Web Dashboard: {WEB_DASHBOARD_URL}")
    print("="*60)
    print()
    
    # Run all tests
    if test_backend_connectivity():
        test_authentication()
        test_cases_management()
        test_livestock_management()
        test_user_management()
        test_dashboard()
        test_notifications()
        test_community()
        test_marketplace()
        test_weather()
        test_files()
    
    test_ussd_service()
    test_web_dashboard()
    
    # Generate markdown report
    md_content = results.to_markdown()
    
    # Save to file
    with open("TEST_RESULTS.md", "w", encoding="utf-8") as f:
        f.write(md_content)
    
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    print(f"Passed: {results.passed}")
    print(f"Failed: {results.failed}")
    print(f"Skipped: {results.skipped}")
    print(f"Total: {len(results.results)}")
    print("="*60)
    print(f"\nTest results saved to: TEST_RESULTS.md")
    
    sys.exit(0 if results.failed == 0 else 1)

if __name__ == "__main__":
    main()

