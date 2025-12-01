import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration - Read from .env or use production URL
  static String get baseUrl {
    try {
      // Safely check if dotenv is initialized and access env variables
      if (dotenv.isInitialized) {
        final apiUrl = dotenv.env['API_BASE_URL'];
        if (apiUrl != null && apiUrl.isNotEmpty) {
          return apiUrl;
        }
      }
    } catch (e) {
      // If dotenv is not initialized or throws error, use default
      // This handles NotInitializedError gracefully
    }
    // Default to production URL for APK/release builds
    // For local development, set API_BASE_URL in .env file
    return 'https://animalguardian.onrender.com/api';
  }
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userTypeKey = 'user_type';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 60); // Increased for registration (email sending)
  static const Duration receiveTimeout = Duration(seconds: 60);
}

