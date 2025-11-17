enum ProductStatus {
  available,
  sold,
  pending,
  expired,
}

extension ProductStatusExtension on ProductStatus {
  String get name {
    switch (this) {
      case ProductStatus.available:
        return 'Available';
      case ProductStatus.sold:
        return 'Sold';
      case ProductStatus.pending:
        return 'Pending';
      case ProductStatus.expired:
        return 'Expired';
    }
  }

  String get apiValue {
    switch (this) {
      case ProductStatus.available:
        return 'available';
      case ProductStatus.sold:
        return 'sold';
      case ProductStatus.pending:
        return 'pending';
      case ProductStatus.expired:
        return 'expired';
    }
  }

  static ProductStatus fromString(String value) {
    switch (value) {
      case 'available':
        return ProductStatus.available;
      case 'sold':
        return ProductStatus.sold;
      case 'pending':
        return ProductStatus.pending;
      case 'expired':
        return ProductStatus.expired;
      default:
        return ProductStatus.available;
    }
  }
}

class ProductCategory {
  final int id;
  final String name;
  final String nameKinyarwanda;
  final String description;
  final String icon;

  ProductCategory({
    required this.id,
    required this.name,
    required this.nameKinyarwanda,
    required this.description,
    required this.icon,
  });

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
      id: map['id'] as int,
      name: map['name'] ?? '',
      nameKinyarwanda: map['name_kinyarwanda'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
    );
  }
}

class Product {
  final int id;
  final int sellerId;
  final String sellerName;
  final String sellerUsername;
  final int? categoryId;
  final String? categoryName;
  final String title;
  final String description;
  final double price;
  final String currency;
  final bool isNegotiable;
  final int quantity;
  final String unit;
  final List<String> images;
  final String location;
  final String district;
  final String sector;
  final String contactPhone;
  final String contactEmail;
  final ProductStatus status;
  final bool isFeatured;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerUsername,
    this.categoryId,
    this.categoryName,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.isNegotiable,
    required this.quantity,
    required this.unit,
    required this.images,
    required this.location,
    required this.district,
    required this.sector,
    required this.contactPhone,
    required this.contactEmail,
    required this.status,
    required this.isFeatured,
    required this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      sellerId: map['seller'] as int,
      sellerName: map['seller_name'] ?? '',
      sellerUsername: map['seller_username'] ?? '',
      categoryId: map['category'] as int?,
      categoryName: map['category_name'] as String?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      currency: map['currency'] ?? 'RWF',
      isNegotiable: map['is_negotiable'] ?? false,
      quantity: map['quantity'] ?? 1,
      unit: map['unit'] ?? 'piece',
      images: List<String>.from(map['images'] ?? []),
      location: map['location'] ?? '',
      district: map['district'] ?? '',
      sector: map['sector'] ?? '',
      contactPhone: map['contact_phone'] ?? '',
      contactEmail: map['contact_email'] ?? '',
      status: ProductStatusExtension.fromString(map['status'] ?? 'available'),
      isFeatured: map['is_featured'] ?? false,
      viewsCount: map['views_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'is_negotiable': isNegotiable,
      'quantity': quantity,
      'unit': unit,
      'images': images,
      'location': location,
      'district': district,
      'sector': sector,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
    };
  }
}

