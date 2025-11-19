import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration - Read from .env or use default
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 
           'https://animalguardian-backend-production-b5a8.up.railway.app/api';
  }
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 60); // Increased for registration (email sending)
  static const Duration receiveTimeout = Duration(seconds: 60);
}

