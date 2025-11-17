class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://animalguardian-backend-production-b5a8.up.railway.app/api';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

