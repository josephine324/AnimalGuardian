"""
Django management command to seed livestock types and breeds.
This ensures the database has basic livestock types for the application to work.

Usage:
    python manage.py seed_livestock_types
"""
from django.core.management.base import BaseCommand
from livestock.models import LivestockType, Breed


class Command(BaseCommand):
    help = 'Seed livestock types and breeds into the database'

    def handle(self, *args, **options):
        """Seed livestock types and breeds."""
        livestock_types_data = [
            {
                'name': 'Cattle',
                'description': 'Domesticated cattle including cows and bulls',
                'breeds': [
                    {'name': 'Ankole', 'description': 'Long-horned cattle breed'},
                    {'name': 'Holstein', 'description': 'Dairy cattle breed'},
                    {'name': 'Angus', 'description': 'Beef cattle breed'},
                    {'name': 'Boran', 'description': 'East African cattle breed'},
                ]
            },
            {
                'name': 'Goat',
                'description': 'Domesticated goats',
                'breeds': [
                    {'name': 'Boer', 'description': 'Meat goat breed'},
                    {'name': 'Saanen', 'description': 'Dairy goat breed'},
                    {'name': 'Toggenburg', 'description': 'Dairy goat breed'},
                    {'name': 'Local', 'description': 'Local goat breed'},
                ]
            },
            {
                'name': 'Sheep',
                'description': 'Domesticated sheep',
                'breeds': [
                    {'name': 'Dorper', 'description': 'Meat sheep breed'},
                    {'name': 'Merino', 'description': 'Wool sheep breed'},
                    {'name': 'Local', 'description': 'Local sheep breed'},
                ]
            },
            {
                'name': 'Pig',
                'description': 'Domesticated pigs',
                'breeds': [
                    {'name': 'Large White', 'description': 'Commercial pig breed'},
                    {'name': 'Landrace', 'description': 'Commercial pig breed'},
                    {'name': 'Local', 'description': 'Local pig breed'},
                ]
            },
            {
                'name': 'Chicken',
                'description': 'Domesticated chickens',
                'breeds': [
                    {'name': 'Broiler', 'description': 'Meat chicken breed'},
                    {'name': 'Layer', 'description': 'Egg-laying chicken breed'},
                    {'name': 'Local', 'description': 'Local chicken breed'},
                ]
            },
            {
                'name': 'Rabbit',
                'description': 'Domesticated rabbits',
                'breeds': [
                    {'name': 'New Zealand White', 'description': 'Meat rabbit breed'},
                    {'name': 'Californian', 'description': 'Meat rabbit breed'},
                    {'name': 'Local', 'description': 'Local rabbit breed'},
                ]
            },
        ]
        
        created_types = 0
        created_breeds = 0
        skipped_types = 0
        skipped_breeds = 0
        
        for type_data in livestock_types_data:
            type_name = type_data['name']
            breeds_data = type_data.pop('breeds', [])
            
            # Create or get livestock type
            # Note: LivestockType model doesn't have a description field
            livestock_type, created = LivestockType.objects.get_or_create(
                name=type_name
            )
            
            if created:
                created_types += 1
                self.stdout.write(
                    self.style.SUCCESS(f'Created livestock type: {type_name}')
                )
            else:
                skipped_types += 1
                self.stdout.write(
                    self.style.WARNING(f'Livestock type already exists: {type_name}')
                )
            
            # Create breeds for this type
            for breed_data in breeds_data:
                breed_name = breed_data['name']
                breed, created = Breed.objects.get_or_create(
                    name=breed_name,
                    livestock_type=livestock_type,
                    defaults={'characteristics': breed_data.get('description', '')}
                )
                
                if created:
                    created_breeds += 1
                else:
                    skipped_breeds += 1
        
        self.stdout.write(
            self.style.SUCCESS(
                f'\nSummary:\n'
                f'  Livestock Types: Created {created_types}, Skipped {skipped_types}\n'
                f'  Breeds: Created {created_breeds}, Skipped {skipped_breeds}\n'
                f'  Total Types: {LivestockType.objects.count()}\n'
                f'  Total Breeds: {Breed.objects.count()}'
            )
        )

