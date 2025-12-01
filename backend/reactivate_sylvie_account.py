#!/usr/bin/env python
"""
Reactivate Sylvie's account (Iturinde sylvie) so she can login.
Phone: 0780555261
"""
import os
import sys
import django

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User

def reactivate_sylvie():
    """Reactivate Sylvie's account."""
    
    phone_number = '0780555261'
    
    try:
        user = User.objects.get(phone_number=phone_number)
        
        print("\n" + "="*60)
        print(f"Reactivating Account: {user.get_full_name()}")
        print("="*60 + "\n")
        
        print(f"Current status:")
        print(f"  - is_active: {user.is_active}")
        print(f"  - is_approved: {user.is_approved_by_admin}")
        print(f"  - user_type: {user.user_type}")
        
        # Ensure account is active and approved
        user.is_active = True
        user.is_approved_by_admin = True
        user.save(update_fields=['is_active', 'is_approved_by_admin'])
        
        print(f"\n✅ Account reactivated successfully!")
        print(f"  - is_active: {user.is_active}")
        print(f"  - is_approved: {user.is_approved_by_admin}")
        print("\n" + "="*60)
        print("Sylvie can now login and toggle her availability.")
        print("Going offline will NOT deactivate the account.")
        print("="*60 + "\n")
        
    except User.DoesNotExist:
        print(f"\n❌ Error: User with phone number {phone_number} not found!")
        print("Please check the phone number and try again.\n")
    except Exception as e:
        print(f"\n❌ Error: {str(e)}\n")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    reactivate_sylvie()

