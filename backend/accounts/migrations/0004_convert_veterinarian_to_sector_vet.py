# Generated migration to convert existing 'veterinarian' users to 'sector_vet'

from django.db import migrations


def convert_veterinarians_to_sector_vets(apps, schema_editor):
    """Convert all existing 'veterinarian' user types to 'sector_vet'."""
    User = apps.get_model('accounts', 'User')
    User.objects.filter(user_type='veterinarian').update(user_type='sector_vet')


def reverse_conversion(apps, schema_editor):
    """Reverse: convert 'sector_vet' back to 'veterinarian'."""
    User = apps.get_model('accounts', 'User')
    User.objects.filter(user_type='sector_vet').update(user_type='veterinarian')


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0003_user_approval_notes_user_approved_at_and_more'),
    ]

    operations = [
        migrations.RunPython(convert_veterinarians_to_sector_vets, reverse_conversion),
    ]

