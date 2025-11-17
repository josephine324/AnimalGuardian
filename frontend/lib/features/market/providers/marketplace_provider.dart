import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/marketplace_model.dart';
import '../../../core/services/api_service.dart';

class MarketplaceState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<ProductCategory> categories;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final String searchQuery;
  final int? selectedCategoryId;
  final ProductStatus selectedStatus;

  const MarketplaceState({
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.selectedStatus = ProductStatus.available,
  });

  MarketplaceState copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    List<ProductCategory>? categories,
    bool? isLoading,
    String? error,
    bool? hasMore,
    String? searchQuery,
    int? selectedCategoryId,
    ProductStatus? selectedStatus,
    bool clearError = false,
  }) {
    return MarketplaceState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  MarketplaceNotifier() : super(const MarketplaceState()) {
    loadCategories();
    loadProducts(refresh: true);
  }

  final ApiService _apiService = ApiService();
  int _currentPage = 1;

  Future<void> loadCategories() async {
    try {
      final categories = await _apiService.getProductCategories();
      state = state.copyWith(categories: categories);
    } catch (_) {}
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(
        products: const [],
        filteredProducts: const [],
        hasMore: true,
        isLoading: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final products = await _apiService.getProducts(
        status: state.selectedStatus,
        category: state.selectedCategoryId,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        page: _currentPage,
      );

      final merged = refresh ? products : [...state.products, ...products];
      state = state.copyWith(
        products: merged,
        filteredProducts: _filterProducts(merged, state.searchQuery, state.selectedCategoryId),
        isLoading: false,
        hasMore: products.length >= AppConstants.defaultPageSize,
      );

      if (products.isNotEmpty) {
        _currentPage++;
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await loadProducts();
  }

  void updateSearch(String query) {
    final trimmed = query.trimLeft();
    if (trimmed == state.searchQuery) return;

    state = state.copyWith(
      searchQuery: trimmed,
      filteredProducts: _filterProducts(state.products, trimmed, state.selectedCategoryId),
    );
  }

  void setCategory(int? categoryId) {
    if (categoryId == state.selectedCategoryId) return;
    state = state.copyWith(
      selectedCategoryId: categoryId,
      filteredProducts: _filterProducts(state.products, state.searchQuery, categoryId),
    );
    loadProducts(refresh: true);
  }

  void setStatus(ProductStatus status) {
    if (status == state.selectedStatus) return;
    state = state.copyWith(selectedStatus: status);
    loadProducts(refresh: true);
  }

  Future<Product?> createProduct(Map<String, dynamic> payload) async {
    try {
      final product = await _apiService.createProduct(payload);
      final updatedProducts = [product, ...state.products];
      state = state.copyWith(
        products: updatedProducts,
        filteredProducts: _filterProducts(updatedProducts, state.searchQuery, state.selectedCategoryId),
      );
      return product;
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return null;
    }
  }

  List<Product> _filterProducts(List<Product> products, String query, int? categoryId) {
    Iterable<Product> filtered = products;

    if (categoryId != null) {
      filtered = filtered.where((product) => product.categoryId == categoryId);
    }

    if (query.trim().isEmpty) {
      return filtered.toList();
    }

    final lower = query.toLowerCase();
    return filtered.where((product) {
      final titleMatch = product.title.toLowerCase().contains(lower);
      final descriptionMatch = product.description.toLowerCase().contains(lower);
      final locationMatch = product.location.toLowerCase().contains(lower) ||
          product.district.toLowerCase().contains(lower) ||
          product.sector.toLowerCase().contains(lower);
      final sellerMatch = product.sellerName.toLowerCase().contains(lower);
      return titleMatch || descriptionMatch || locationMatch || sellerMatch;
    }).toList();
  }
}

final marketplaceProvider = StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
  return MarketplaceNotifier();
});

