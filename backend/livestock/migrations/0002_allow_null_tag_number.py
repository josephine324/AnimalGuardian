# Generated migration to fix tag_number unique constraint issue

from django.db import migrations, models


def convert_empty_tag_numbers_to_null(apps, schema_editor):
    """Convert empty string tag_numbers to NULL to fix unique constraint."""
    Livestock = apps.get_model('livestock', 'Livestock')
    # Update all records with empty string tag_number to NULL
    Livestock.objects.filter(tag_number='').update(tag_number=None)


def reverse_convert_empty_tag_numbers_to_null(apps, schema_editor):
    """Reverse migration: convert NULL tag_numbers back to empty strings."""
    Livestock = apps.get_model('livestock', 'Livestock')
    # Update all records with NULL tag_number to empty string
    Livestock.objects.filter(tag_number__isnull=True).update(tag_number='')


class Migration(migrations.Migration):

    dependencies = [
        ('livestock', '0001_initial'),
    ]

    operations = [
        # First, convert existing empty strings to NULL
        migrations.RunPython(
            convert_empty_tag_numbers_to_null,
            reverse_convert_empty_tag_numbers_to_null,
        ),
        # Then, alter the field to allow NULL
        migrations.AlterField(
            model_name='livestock',
            name='tag_number',
            field=models.CharField(blank=True, max_length=50, null=True, unique=True),
        ),
    ]

