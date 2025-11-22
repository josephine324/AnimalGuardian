import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration - Read from .env or use Render backend as default
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 
           'https://animalguardian.onrender.com/api'; // Default to Render backend
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

