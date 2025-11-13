from django.db import models
from accounts.models import User


class Category(models.Model):
    """Product categories."""
    
    name = models.CharField(max_length=100, unique=True)
    name_kinyarwanda = models.CharField(max_length=100, blank=True)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=50, blank=True)  # Icon name or emoji
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        app_label = 'marketplace'
        db_table = 'marketplace_categories'
        verbose_name_plural = 'Categories'
    
    def __str__(self):
        return self.name


class Product(models.Model):
    """Marketplace products."""
    
    seller = models.ForeignKey(User, on_delete=models.CASCADE, related_name='products')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)
    
    name = models.CharField(max_length=200)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='RWF')
    
    # Product details
    quantity_available = models.PositiveIntegerField(default=1)
    unit = models.CharField(max_length=20, default='piece')  # piece, kg, liter, etc.
    image = models.URLField(blank=True)  # URL to uploaded image
    
    # Location
    location = models.CharField(max_length=200, blank=True)
    district = models.CharField(max_length=100, blank=True)
    sector = models.CharField(max_length=100, blank=True)
    
    # Status
    is_available = models.BooleanField(default=True)
    is_featured = models.BooleanField(default=False)
    
    # Metadata
    views_count = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        app_label = 'marketplace'
        db_table = 'marketplace_products'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.name} - {self.price} {self.currency}"

