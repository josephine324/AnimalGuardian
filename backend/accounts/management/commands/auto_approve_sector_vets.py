"""
Django management command to auto-approve all existing sector vets that are pending approval.
This ensures all sector vets are approved as per the new registration logic.

Usage:
    python manage.py auto_approve_sector_vets
"""
from django.core.management.base import BaseCommand
from accounts.models import User


class Command(BaseCommand):
    help = 'Auto-approve all sector vets that are currently pending approval'

    def handle(self, *args, **options):
        """Auto-approve all sector vets that are currently pending approval."""
        pending_sector_vets = User.objects.filter(
            user_type='sector_vet',
            is_approved_by_admin=False
        )
        
        count = pending_sector_vets.count()
        
        if count == 0:
            self.stdout.write(
                self.style.SUCCESS('No pending sector vets found. All sector vets are already approved.')
            )
            return
        
        self.stdout.write(f'Found {count} sector vet(s) pending approval. Auto-approving...')
        
        updated = pending_sector_vets.update(is_approved_by_admin=True)
        
        self.stdout.write(
            self.style.SUCCESS(f'Successfully auto-approved {updated} sector vet(s).')
        )
        
        # List the approved users
        approved_users = User.objects.filter(
            user_type='sector_vet',
            is_approved_by_admin=True,
            id__in=[u.id for u in pending_sector_vets]
        )
        
        for user in approved_users:
            self.stdout.write(f'  - {user.get_full_name()} ({user.email or user.phone_number})')

