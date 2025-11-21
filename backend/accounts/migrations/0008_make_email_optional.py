# Generated migration to make email optional

from django.db import migrations, models
from collections import Counter


def handle_duplicate_emails(apps, schema_editor):
    """Handle duplicate emails before making email field unique and nullable."""
    User = apps.get_model('accounts', 'User')
    
    # Find all users with emails
    users_with_emails = User.objects.exclude(email__isnull=True).exclude(email='')
    
    # Count email occurrences
    email_counts = Counter(user.email for user in users_with_emails if user.email)
    
    # For each duplicate email, keep the first user (by ID) and set others to NULL
    for email, count in email_counts.items():
        if count > 1 and email:  # Only process duplicates
            # Get all users with this email, ordered by ID (keep the oldest)
            duplicate_users = User.objects.filter(email=email).order_by('id')
            
            # Keep the first one, set others to NULL
            for user in duplicate_users[1:]:  # Skip the first one
                user.email = None
                user.save(update_fields=['email'])


def reverse_handle_duplicate_emails(apps, schema_editor):
    """Reverse migration - nothing to do."""
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0007_change_vet_availability_default'),
    ]

    operations = [
        # First, handle duplicate emails
        migrations.RunPython(
            handle_duplicate_emails,
            reverse_handle_duplicate_emails,
        ),
        # Then, alter the field to allow NULL
        migrations.AlterField(
            model_name='user',
            name='email',
            field=models.EmailField(blank=True, max_length=254, null=True, unique=True),
        ),
    ]
