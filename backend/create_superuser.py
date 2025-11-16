#!/usr/bin/env python
"""
Script to create a superuser for AnimalGuardian
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'animalguardian.settings')
django.setup()

from accounts.models import User

def create_superuser():
    """Create a superuser with the specified credentials"""
    
    phone_number = '+250780570632'
    email = 'mutesijosephine324@gmail.com'
    username = 'admin'  # Required field
    # Default password - CHANGE THIS IN PRODUCTION!
    password = os.environ.get('ADMIN_PASSWORD', 'Admin@123456')
    
    # Check if migrations have been run
    from django.db import connection
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1 FROM information_schema.tables WHERE table_name='users'")
            table_exists = cursor.fetchone()
            if not table_exists:
                print('❌ ERROR: Database tables do not exist!')
                print('Please run migrations first:')
                print('  railway run python manage.py migrate')
                print('Or via Railway Dashboard terminal:')
                print('  python manage.py migrate')
                return
    except Exception as e:
        print(f'❌ ERROR: Could not check database: {e}')
        print('Make sure DATABASE_URL is set correctly and database is accessible.')
        return
    
    # Check if user already exists
    try:
        if User.objects.filter(phone_number=phone_number).exists():
            user = User.objects.get(phone_number=phone_number)
            user.is_superuser = True
            user.is_staff = True
            user.is_active = True
            user.email = email
            user.username = username
            user.user_type = 'admin'
            user.is_verified = True
            user.set_password(password)
            user.save()
            print(f'✅ Updated existing user {phone_number} to superuser')
        else:
            # Create new superuser
            try:
                user = User.objects.create_superuser(
                    phone_number=phone_number,
                    username=username,
                    email=email,
                    password=password,
                    user_type='admin',
                    is_verified=True,
                )
                print(f'✅ Created superuser: {phone_number}')
            except Exception as e:
                print(f'❌ Error creating superuser: {e}')
                import traceback
                traceback.print_exc()
                return
    except Exception as e:
        print(f'❌ Error checking for existing user: {e}')
        import traceback
        traceback.print_exc()
        return
    
    print(f'   Email: {email}')
    print(f'   Phone: {phone_number}')
    print(f'   Username: {username}')
    print(f'   Password: {password} (CHANGE THIS!)')
    print(f'   Is Superuser: {user.is_superuser}')
    print(f'   Is Staff: {user.is_staff}')
    print(f'\n⚠️  IMPORTANT: Change the password after first login!')

if __name__ == '__main__':
    create_superuser()

