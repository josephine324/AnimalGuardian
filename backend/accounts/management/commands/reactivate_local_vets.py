"""
Django management command to reactivate all local veterinarian accounts.
Run: python manage.py reactivate_local_vets
"""
from django.core.management.base import BaseCommand
from accounts.models import User

class Command(BaseCommand):
    help = 'Reactivate all local veterinarian accounts (ensures they can login even when offline)'

    def handle(self, *args, **options):
        local_vets = User.objects.filter(user_type='local_vet')
        
        reactivated_count = 0
        already_active_count = 0
        
        self.stdout.write("\n" + "="*60)
        self.stdout.write(self.style.SUCCESS("Reactivating Local Veterinarian Accounts"))
        self.stdout.write("="*60 + "\n")
        
        for vet in local_vets:
            if not vet.is_active:
                vet.is_active = True
                vet.save(update_fields=['is_active'])
                reactivated_count += 1
                self.stdout.write(
                    self.style.SUCCESS(f"✓ Reactivated: {vet.get_full_name()} ({vet.phone_number})")
                )
            else:
                already_active_count += 1
                self.stdout.write(
                    f"✓ Already active: {vet.get_full_name()} ({vet.phone_number})"
                )
        
        self.stdout.write("\n" + "="*60)
        self.stdout.write("Summary:")
        self.stdout.write("="*60)
        self.stdout.write(f"Total local vets: {local_vets.count()}")
        self.stdout.write(f"Reactivated: {reactivated_count}")
        self.stdout.write(f"Already active: {already_active_count}")
        self.stdout.write("="*60 + "\n")
        
        self.stdout.write(self.style.SUCCESS(
            "✅ All local veterinarians can now login!"
        ))
        self.stdout.write(
            self.style.WARNING(
                "Note: Offline status (is_available=False) does NOT affect login capability.\n"
            )
        )

