import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/livestock_model.dart';
import '../../../core/services/api_service.dart';

class LivestockState {
  final List<Livestock> livestock;
  final List<Livestock> filteredLivestock;
  final List<LivestockType> livestockTypes;
  final List<Breed> breeds;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final String searchQuery;

  const LivestockState({
    this.livestock = const [],
    this.filteredLivestock = const [],
    this.livestockTypes = const [],
    this.breeds = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.searchQuery = '',
  });

  LivestockState copyWith({
    List<Livestock>? livestock,
    List<Livestock>? filteredLivestock,
    List<LivestockType>? livestockTypes,
    List<Breed>? breeds,
    bool? isLoading,
    String? error,
    bool? hasMore,
    String? searchQuery,
    bool clearError = false,
  }) {
    return LivestockState(
      livestock: livestock ?? this.livestock,
      filteredLivestock: filteredLivestock ?? this.filteredLivestock,
      livestockTypes: livestockTypes ?? this.livestockTypes,
      breeds: breeds ?? this.breeds,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LivestockNotifier extends StateNotifier<LivestockState> {
  LivestockNotifier() : super(const LivestockState()) {
    loadLivestock(refresh: true);
    loadLivestockTypes();
  }

  final ApiService _apiService = ApiService();
  int _currentPage = 1;

  Future<void> loadLivestock({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(
        livestock: const [],
        filteredLivestock: const [],
        hasMore: true,
        isLoading: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final livestock = await _apiService.getLivestock(page: _currentPage);
      final merged = refresh ? livestock : [...state.livestock, ...livestock];

      state = state.copyWith(
        livestock: merged,
        filteredLivestock: _filterLivestock(merged, state.searchQuery),
        isLoading: false,
        hasMore: livestock.length >= AppConstants.defaultPageSize,
      );

      if (livestock.isNotEmpty) {
        _currentPage++;
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> loadLivestockTypes() async {
    try {
      final types = await _apiService.getLivestockTypes();
      state = state.copyWith(livestockTypes: types, clearError: true);
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        livestockTypes: const [],
      );
      // Re-throw so UI can show error message
      rethrow;
    }
  }

  Future<void> loadBreeds({int? livestockTypeId}) async {
    try {
      final breeds =
          await _apiService.getBreeds(livestockTypeId: livestockTypeId);
      state = state.copyWith(breeds: breeds, clearError: true);
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        breeds: const [],
      );
      // Re-throw so UI can show error message
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.searchQuery.isNotEmpty) {
      return;
    }
    await loadLivestock();
  }

  void updateSearch(String query) {
    final trimmed = query.trimLeft();
    if (trimmed == state.searchQuery) return;

    state = state.copyWith(
      searchQuery: trimmed,
      filteredLivestock: _filterLivestock(state.livestock, trimmed),
    );
  }

  void clearSearch() {
    if (state.searchQuery.isEmpty) return;
    state = state.copyWith(
      searchQuery: '',
      filteredLivestock: state.livestock,
    );
  }

  Future<Livestock?> createLivestock(Map<String, dynamic> payload) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final newLivestock = await _apiService.createLivestock(payload);
      final updatedList = [newLivestock, ...state.livestock];

      state = state.copyWith(
        livestock: updatedList,
        filteredLivestock: _filterLivestock(updatedList, state.searchQuery),
        isLoading: false,
      );

      return newLivestock;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      return null;
    }
  }

  Future<Livestock?> getLivestockById(int id) async {
    try {
      return await _apiService.getLivestockById(id);
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return null;
    }
  }

  Future<bool> updateLivestock(int id, Map<String, dynamic> payload) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final updatedLivestock = await _apiService.updateLivestock(id, payload);

      final index = state.livestock.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updatedList = List<Livestock>.from(state.livestock);
        updatedList[index] = updatedLivestock;
        state = state.copyWith(
          livestock: updatedList,
          filteredLivestock: _filterLivestock(updatedList, state.searchQuery),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteLivestock(int id) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _apiService.deleteLivestock(id);

      final updatedList =
          state.livestock.where((livestock) => livestock.id != id).toList();
      state = state.copyWith(
        livestock: updatedList,
        filteredLivestock: _filterLivestock(updatedList, state.searchQuery),
        isLoading: false,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      return false;
    }
  }

  List<Livestock> _filterLivestock(List<Livestock> livestock, String query) {
    if (query.trim().isEmpty) {
      return livestock;
    }

    final lower = query.toLowerCase();
    return livestock.where((animal) {
      final nameMatch = (animal.name ?? '').toLowerCase().contains(lower);
      final tagMatch = (animal.tagNumber ?? '').toLowerCase().contains(lower);
      final typeMatch =
          (animal.livestockType?.name ?? '').toLowerCase().contains(lower);
      final breedMatch =
          (animal.breed?.name ?? '').toLowerCase().contains(lower);
      return nameMatch || tagMatch || typeMatch || breedMatch;
    }).toList();
  }
}

final livestockProvider =
    StateNotifierProvider<LivestockNotifier, LivestockState>((ref) {
  return LivestockNotifier();
});
