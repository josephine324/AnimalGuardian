"""
Test script for USSD Service endpoints.
Run this to test the USSD service locally.
"""

import requests
import json
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# USSD Service URL
USSD_SERVICE_URL = os.getenv('USSD_SERVICE_URL', 'http://localhost:5000')

def test_health_check():
    """Test health check endpoint."""
    print("\n=== Testing Health Check ===")
    try:
        response = requests.get(f"{USSD_SERVICE_URL}/health")
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {str(e)}")
        return False

def test_ussd_handler():
    """Test USSD handler endpoint."""
    print("\n=== Testing USSD Handler ===")
    try:
        # Test USSD request (step 0 - welcome menu)
        ussd_data = {
            "sessionId": "test_session_123",
            "phoneNumber": "+250123456789",
            "serviceCode": "*123#",
            "text": ""
        }
        
        response = requests.post(
            f"{USSD_SERVICE_URL}/ussd",
            json=ussd_data,
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {str(e)}")
        return False

def test_sms_handler():
    """Test SMS handler endpoint."""
    print("\n=== Testing SMS Handler ===")
    try:
        # Test SMS request
        sms_data = {
            "from": "+250123456789",
            "text": "HELP",
            "date": "2024-01-15T10:00:00Z"
        }
        
        response = requests.post(
            f"{USSD_SERVICE_URL}/sms",
            json=sms_data,
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {str(e)}")
        return False

def test_ussd_flow():
    """Test complete USSD flow."""
    print("\n=== Testing Complete USSD Flow ===")
    
    session_id = "test_flow_123"
    phone_number = "+250123456789"
    service_code = "*123#"
    
    # Step 0: Welcome menu
    print("\nStep 0: Welcome Menu")
    ussd_data = {
        "sessionId": session_id,
        "phoneNumber": phone_number,
        "serviceCode": service_code,
        "text": ""
    }
    
    try:
        response = requests.post(
            f"{USSD_SERVICE_URL}/ussd",
            json=ussd_data
        )
        print(f"Response: {response.json().get('response', '')[:200]}")
        
        # Step 1: Select option 3 (Vaccination Schedule)
        print("\nStep 1: Select Vaccination Schedule")
        ussd_data["text"] = "3"
        response = requests.post(
            f"{USSD_SERVICE_URL}/ussd",
            json=ussd_data
        )
        print(f"Response: {response.json().get('response', '')[:200]}")
        
        # Step 2: Select option 4 (Weather Alerts)
        print("\nStep 2: Select Weather Alerts")
        ussd_data["text"] = "4"
        response = requests.post(
            f"{USSD_SERVICE_URL}/ussd",
            json=ussd_data
        )
        print(f"Response: {response.json().get('response', '')[:200]}")
        
        return True
    except Exception as e:
        print(f"Error: {str(e)}")
        return False

def test_sms_commands():
    """Test SMS commands."""
    print("\n=== Testing SMS Commands ===")
    
    phone_number = "+250123456789"
    commands = ["HELP", "STATUS", "VACCINE", "WEATHER"]
    
    for command in commands:
        print(f"\nTesting command: {command}")
        try:
            sms_data = {
                "from": phone_number,
                "text": command,
                "date": "2024-01-15T10:00:00Z"
            }
            
            response = requests.post(
                f"{USSD_SERVICE_URL}/sms",
                json=sms_data
            )
            
            print(f"Status: {response.status_code}")
            if response.status_code == 200:
                print("Command processed successfully")
            else:
                print(f"Error: {response.text}")
        except Exception as e:
            print(f"Error: {str(e)}")

if __name__ == "__main__":
    print("USSD Service Endpoint Tests")
    print("=" * 50)
    
    # Test endpoints
    results = []
    
    results.append(("Health Check", test_health_check()))
    results.append(("USSD Handler", test_ussd_handler()))
    results.append(("SMS Handler", test_sms_handler()))
    results.append(("USSD Flow", test_ussd_flow()))
    
    # Print summary
    print("\n" + "=" * 50)
    print("Test Results Summary:")
    print("=" * 50)
    
    for test_name, passed in results:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{test_name}: {status}")
    
    # Test SMS commands
    test_sms_commands()
    
    print("\n" + "=" * 50)
    print("Testing complete!")

