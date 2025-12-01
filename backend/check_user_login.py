#!/usr/bin/env python
"""Check user login status and approval."""
import os
import sys
import django

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User
from django.contrib.auth import authenticate

phone_number = '0780480780'
password = 'Aggyirakiza123'

print("\n" + "="*60)
print("Checking User Login Status")
print("="*60 + "\n")

user = User.objects.filter(phone_number=phone_number).first()

if not user:
    print(f"❌ User with phone {phone_number} NOT FOUND in local database!")
    print("\nPossible reasons:")
    print("  1. Account was created on PRODUCTION, not local")
    print("  2. Account doesn't exist yet")
    print("\nSolution: Create the account on local backend or sync from production")
else:
    print(f"✓ User found: {user.get_full_name()}")
    print(f"  Phone: {user.phone_number}")
    print(f"  User type: {user.user_type}")
    print(f"  is_active: {user.is_active}")
    print(f"  is_approved_by_admin: {user.is_approved_by_admin}")
    print(f"  is_verified: {user.is_verified}")
    
    # Test password
    auth_user = authenticate(username=user.username, password=password)
    password_correct = auth_user is not None
    
    print(f"\nPassword check:")
    print(f"  Password correct: {password_correct}")
    
    if not password_correct:
        print("\n❌ PASSWORD IS INCORRECT!")
        print("The password you're using doesn't match the stored password.")
    else:
        print("\n✓ Password is correct")
        
        # Check if user can login
        can_login = True
        issues = []
        
        if not user.is_active:
            can_login = False
            issues.append("Account is deactivated (is_active=False)")
        
        if user.user_type == 'local_vet' and not user.is_approved_by_admin:
            can_login = False
            issues.append("Local vet account not approved (is_approved_by_admin=False)")
        
        if can_login:
            print("\n✅ USER CAN LOGIN - All checks passed!")
        else:
            print("\n❌ USER CANNOT LOGIN - Issues found:")
            for issue in issues:
                print(f"  - {issue}")
            
            print("\nSolutions:")
            if not user.is_active:
                print("  - Reactivate account: user.is_active = True")
            if user.user_type == 'local_vet' and not user.is_approved_by_admin:
                print("  - Approve account: user.is_approved_by_admin = True")
                print("  - Or approve via dashboard: /user-approval")

print("\n" + "="*60 + "\n")
