from rest_framework import serializers
from .models import Product, Category
from accounts.serializers import UserSerializer


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'name_kinyarwanda', 'description', 'icon', 'created_at']


class ProductSerializer(serializers.ModelSerializer):
    seller = UserSerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(),
        source='category',
        write_only=True,
        required=False
    )
    
    class Meta:
        model = Product
        fields = ['id', 'seller', 'category', 'category_id', 'name', 'description',
                  'price', 'currency', 'quantity_available', 'unit', 'image',
                  'location', 'district', 'sector', 'is_available', 'is_featured',
                  'views_count', 'created_at', 'updated_at']
        read_only_fields = ['seller', 'views_count', 'created_at', 'updated_at']

