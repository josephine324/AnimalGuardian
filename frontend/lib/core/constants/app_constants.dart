import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration - Read from .env or use default
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 
           'http://localhost:8000/api'; // Default to localhost for development
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

