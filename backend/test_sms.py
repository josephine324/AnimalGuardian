#!/usr/bin/env python
"""
Test script for sending SMS via Africa's Talking
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from django.conf import settings
import africastalking

def test_sms():
    """Test sending SMS via Africa's Talking"""
    
    # Get credentials from settings
    username = settings.AFRICASTALKING_USERNAME
    api_key = settings.AFRICASTALKING_API_KEY
    
    print("=" * 50)
    print("Testing Africa's Talking SMS")
    print("=" * 50)
    print(f"Username: {username}")
    print(f"API Key: {api_key[:20]}..." if api_key else "API Key: Not set")
    print()
    
    if not username or not api_key:
        print("❌ ERROR: Africa's Talking credentials not configured!")
        print("Please check your .env file or environment variables.")
        return
    
    # Initialize SMS service
    try:
        # Initialize Africa's Talking SDK
        africastalking.initialize(username, api_key)
        
        # Get SMS service
        sms = africastalking.SMS
        
        # Test message
        message = "Hello from AnimalGuardian! This is a test SMS."
        recipients = ["+250780570632"]
        
        print(f"Sending SMS to: {recipients[0]}")
        print(f"Message: {message}")
        print()
        
        # Send SMS
        response = sms.send(message, recipients)
        
        print("SUCCESS: SMS Sent Successfully!")
        print("Response:")
        print(response)
        print()
        print("Check your phone (+250780570632) for the message!")
        
    except Exception as e:
        print(f"ERROR: Failed to send SMS")
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        print()
        print("Troubleshooting:")
        print("1. Check if your API key is correct")
        print("2. Verify your phone number is registered in sandbox")
        print("3. Check your account balance")
        print("4. Ensure you're using sandbox credentials for testing")

if __name__ == "__main__":
    test_sms()

