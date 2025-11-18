#!/usr/bin/env python
"""Check user details for debugging login"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User

def check_user(email):
    print(f"\n{'='*60}")
    print(f"Checking user with email: {email}")
    print(f"{'='*60}\n")
    
    # Use only() to avoid loading fields that might not exist in DB
    user = User.objects.filter(email=email).only('id', 'email', 'phone_number', 'username', 'user_type', 'is_active', 'is_verified', 'is_approved_by_admin', 'is_staff', 'is_superuser').first()
    
    if not user:
        print(f"[ERROR] No user found with email: {email}\n")
        print("Available users in database:")
        all_users = User.objects.all()[:20]
        if all_users:
            for u in all_users:
                print(f"  - Email: {u.email or '(no email)'}, Phone: {u.phone_number or '(no phone)'}, Username: {u.username}, Active: {u.is_active}, Type: {u.user_type}")
        else:
            print("  (No users found in database)")
        return None
    
    print(f"[OK] User found!")
    print(f"   - ID: {user.id}")
    print(f"   - Email: {user.email}")
    print(f"   - Phone Number: {user.phone_number or '(NOT SET - THIS WILL CAUSE LOGIN TO FAIL!)'}")
    print(f"   - Username: {user.username}")
    print(f"   - User Type: {user.user_type}")
    print(f"   - Is Active: {user.is_active}")
    print(f"   - Is Verified: {user.is_verified}")
    print(f"   - Is Approved: {user.is_approved_by_admin}")
    print(f"   - Is Staff: {user.is_staff}")
    print(f"   - Is Superuser: {user.is_superuser}")
    
    if not user.phone_number:
        print(f"\n[WARNING] User has no phone_number!")
        print("   Authentication requires phone_number as USERNAME_FIELD")
        print("   Login will fail until phone_number is set")
    
    if not user.is_active:
        print(f"\n[WARNING] User is not active!")
        print("   Login will fail for inactive users")
    
    if user.user_type == 'farmer' and not user.is_verified:
        print(f"\n[WARNING] Farmer account is not verified!")
        print("   Login will fail for unverified farmers")
    
    if user.user_type == 'farmer' and not user.is_approved_by_admin:
        print(f"\n[WARNING] Farmer account is not approved!")
        print("   Login will fail for unapproved farmers")
    
    return user

if __name__ == '__main__':
    # Check the email from the error
    email = 'j.mutesi@alustudent.com'
    if len(sys.argv) > 1:
        email = sys.argv[1]
    
    user = check_user(email)
    
    if user:
        print(f"\n{'='*60}")
        print("To test login, run:")
        print(f"  python test_login.py")
        print(f"{'='*60}\n")

