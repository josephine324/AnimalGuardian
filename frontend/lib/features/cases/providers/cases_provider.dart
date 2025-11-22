import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/case_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';

class CasesState {
  final List<CaseReport> cases;
  final List<CaseReport> filteredCases;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final String searchQuery;

  const CasesState({
    this.cases = const [],
    this.filteredCases = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.searchQuery = '',
  });

  CasesState copyWith({
    List<CaseReport>? cases,
    List<CaseReport>? filteredCases,
    bool? isLoading,
    String? error,
    bool? hasMore,
    String? searchQuery,
    bool clearError = false,
  }) {
    return CasesState(
      cases: cases ?? this.cases,
      filteredCases: filteredCases ?? this.filteredCases,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CasesNotifier extends StateNotifier<CasesState> {
  CasesNotifier() : super(const CasesState()) {
    loadCases(refresh: true);
  }

  final ApiService _apiService = ApiService();
  int _currentPage = 1;

  Future<void> loadCases({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(
        cases: const [],
        filteredCases: const [],
        hasMore: true,
        isLoading: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final cases = await _apiService.getCases(page: _currentPage);
      final merged = refresh ? cases : [...state.cases, ...cases];

      state = state.copyWith(
        cases: merged,
        filteredCases: _filterCases(merged, state.searchQuery),
        isLoading: false,
        hasMore: cases.length >= AppConstants.defaultPageSize,
      );

      if (cases.isNotEmpty) {
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
    if (state.isLoading || !state.hasMore || state.searchQuery.isNotEmpty) {
      return;
    }
    await loadCases();
  }

  void updateSearch(String query) {
    final trimmed = query.trimLeft();
    if (trimmed == state.searchQuery) return;

    state = state.copyWith(
      searchQuery: trimmed,
      filteredCases: _filterCases(state.cases, trimmed),
    );
  }

  void clearSearch() {
    if (state.searchQuery.isEmpty) return;
    state = state.copyWith(
      searchQuery: '',
      filteredCases: state.cases,
    );
  }

  Future<CaseReport?> createCase(Map<String, dynamic> payload) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final newCase = await _apiService.createCase(payload);
      final updatedCases = [newCase, ...state.cases];

      state = state.copyWith(
        cases: updatedCases,
        filteredCases: _filterCases(updatedCases, state.searchQuery),
        isLoading: false,
      );

      return newCase;
    } catch (error) {
      // Extract more detailed error message
      String errorMessage = error.toString();
      if (error.toString().contains('HTTP 400')) {
        // Parse validation errors
        final errorStr = error.toString();
        if (errorStr.contains('case_id') || errorStr.contains('reporter')) {
          errorMessage = 'Server error: Please try again. If the problem persists, contact support.';
        } else {
          errorMessage = errorStr.replaceAll('Exception: ', '');
        }
      }
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return null;
    }
  }

  Future<CaseReport?> getCaseById(int id) async {
    try {
      return await _apiService.getCaseById(id);
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return null;
    }
  }

  Future<bool> updateCase(int id, Map<String, dynamic> payload) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final updatedCase = await _apiService.updateCase(id, payload);

      final index = state.cases.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updatedCases = List<CaseReport>.from(state.cases);
        updatedCases[index] = updatedCase;
        state = state.copyWith(
          cases: updatedCases,
          filteredCases: _filterCases(updatedCases, state.searchQuery),
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

  Future<bool> deleteCase(int id) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _apiService.deleteCase(id);

      // Remove case from state
      final updatedCases = state.cases.where((c) => c.id != id).toList();
      state = state.copyWith(
        cases: updatedCases,
        filteredCases: _filterCases(updatedCases, state.searchQuery),
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

  List<CaseReport> _filterCases(List<CaseReport> cases, String query) {
    if (query.trim().isEmpty) {
      return cases;
    }

    final lower = query.toLowerCase();
    return cases.where((caseReport) {
      final caseIdMatch = caseReport.caseId.toLowerCase().contains(lower);
      final livestockMatch = (caseReport.livestockName ?? '').toLowerCase().contains(lower);
      final reporterMatch = (caseReport.reporterName ?? '').toLowerCase().contains(lower);
      final symptomMatch = caseReport.symptomsObserved.toLowerCase().contains(lower);
      return caseIdMatch || livestockMatch || reporterMatch || symptomMatch;
    }).toList();
  }
}

final casesProvider = StateNotifierProvider<CasesNotifier, CasesState>((ref) {
  return CasesNotifier();
});

