import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class DashboardState {
  final Map<String, dynamic>? stats;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiService _apiService = ApiService();

  DashboardNotifier() : super(DashboardState()) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final stats = await _apiService.getDashboardStats();
      state = state.copyWith(
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

