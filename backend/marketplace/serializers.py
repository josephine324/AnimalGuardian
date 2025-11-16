from rest_framework import serializers
from .models import Product, Category


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'name_kinyarwanda', 'description', 'icon', 'created_at']


class ProductSerializer(serializers.ModelSerializer):
    seller_name = serializers.SerializerMethodField()
    seller_id = serializers.IntegerField(source='seller.id', read_only=True)
    category = CategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(),
        source='category',
        write_only=True,
        required=False
    )
    
    class Meta:
        model = Product
        fields = ['id', 'seller', 'seller_id', 'seller_name', 'category', 'category_id', 'name', 'description',
                  'price', 'currency', 'quantity_available', 'unit', 'image',
                  'location', 'district', 'sector', 'is_available', 'is_featured',
                  'views_count', 'created_at', 'updated_at']
        read_only_fields = ['seller', 'views_count', 'created_at', 'updated_at']
    
    def get_seller_name(self, obj):
        return obj.seller.get_full_name() or obj.seller.username

