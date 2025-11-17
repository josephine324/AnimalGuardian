import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class WeatherState {
  final Map<String, dynamic>? weather;
  final bool isLoading;
  final String? error;

  WeatherState({
    this.weather,
    this.isLoading = false,
    this.error,
  });

  WeatherState copyWith({
    Map<String, dynamic>? weather,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WeatherState(
      weather: weather ?? this.weather,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final ApiService _apiService = ApiService();

  WeatherNotifier() : super(WeatherState()) {
    loadWeather();
  }

  Future<void> loadWeather({String? location}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final weather = await _apiService.getWeather(location: location);
      state = state.copyWith(
        weather: weather,
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

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier();
});

