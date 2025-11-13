from django.contrib.auth.hashers import make_password
from django.db import migrations


def create_default_admin(apps, schema_editor):
    User = apps.get_model('accounts', 'User')

    admin_defaults = {
        'phone_number': '+250123456789',
        'email': 'admin@animalguardian.rw',
        'user_type': 'admin',
        'is_staff': True,
        'is_superuser': True,
        'is_active': True,
        'password': make_password('admin123'),
    }

    admin_user, created = User.objects.get_or_create(
        username='admin',
        defaults=admin_defaults,
    )

    if not created:
        admin_user.phone_number = admin_defaults['phone_number']
        admin_user.email = admin_defaults['email']
        admin_user.user_type = admin_defaults['user_type']
        admin_user.is_staff = admin_defaults['is_staff']
        admin_user.is_superuser = admin_defaults['is_superuser']
        admin_user.is_active = admin_defaults['is_active']
        admin_user.password = admin_defaults['password']
        admin_user.save(update_fields=[
            'phone_number',
            'email',
            'user_type',
            'is_staff',
            'is_superuser',
            'is_active',
            'password',
        ])


def remove_default_admin(apps, schema_editor):
    User = apps.get_model('accounts', 'User')
    User.objects.filter(username='admin', email='admin@animalguardian.rw').delete()


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(create_default_admin, remove_default_admin),
    ]

