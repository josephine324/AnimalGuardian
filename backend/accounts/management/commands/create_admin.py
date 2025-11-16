"""
Django management command to create admin superuser
Run: python manage.py create_admin
"""
from django.core.management.base import BaseCommand
from accounts.models import User
import os


class Command(BaseCommand):
    help = 'Creates or updates admin superuser with predefined credentials'

    def handle(self, *args, **options):
        phone_number = '+250780570632'
        email = 'mutesijosephine324@gmail.com'
        username = 'admin'
        password = os.environ.get('ADMIN_PASSWORD', 'Admin@123456')
        
        # Check if user exists by phone number
        if User.objects.filter(phone_number=phone_number).exists():
            user = User.objects.get(phone_number=phone_number)
            user.is_superuser = True
            user.is_staff = True
            user.is_active = True
            user.email = email
            user.username = username
            user.user_type = 'admin'
            user.is_verified = True
            user.is_approved_by_admin = True
            user.set_password(password)
            user.save()
            self.stdout.write(
                self.style.SUCCESS(f'Successfully updated user {phone_number} to superuser')
            )
        # Check if user exists by username
        elif User.objects.filter(username=username).exists():
            user = User.objects.get(username=username)
            user.phone_number = phone_number
            user.is_superuser = True
            user.is_staff = True
            user.is_active = True
            user.email = email
            user.user_type = 'admin'
            user.is_verified = True
            user.is_approved_by_admin = True
            user.set_password(password)
            user.save()
            self.stdout.write(
                self.style.SUCCESS(f'Successfully updated user {username} to superuser with phone {phone_number}')
            )
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
                user.is_approved_by_admin = True
                user.save()
                self.stdout.write(
                    self.style.SUCCESS(f'Successfully created superuser: {phone_number}')
                )
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(f'Error creating superuser: {e}')
                )
                return
        
        self.stdout.write(f'   Email: {email}')
        self.stdout.write(f'   Phone: {phone_number}')
        self.stdout.write(f'   Username: {username}')
        self.stdout.write(f'   Password: {password} (CHANGE THIS!)')
        self.stdout.write(f'   Is Superuser: {user.is_superuser}')
        self.stdout.write(f'   Is Staff: {user.is_staff}')
        self.stdout.write(self.style.WARNING('\nIMPORTANT: Change the password after first login!'))

