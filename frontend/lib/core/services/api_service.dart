import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/case_model.dart';
import '../models/livestock_model.dart';
import '../models/community_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get auth token from secure storage
  Future<String?> _getAuthToken() async {
    return await _storage.read(key: AppConstants.authTokenKey);
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return json.decode(response.body);
      } catch (e) {
        // If response is not JSON, return the body as string
        return response.body;
      }
    } else {
      // Try to parse error message from response
      String errorMessage = 'HTTP ${response.statusCode}';
      try {
        // Check if response is HTML (server error page)
        if (response.body.trim().startsWith('<!') || response.body.trim().startsWith('<html')) {
          errorMessage = 'Server Error (${response.statusCode}). Please try again later.';
        } else {
          final errorData = json.decode(response.body);
          if (errorData is Map) {
            // Check for common error message keys
            if (errorData.containsKey('error')) {
              errorMessage = errorData['error'].toString();
              if (errorData.containsKey('detail')) {
                errorMessage += ': ${errorData['detail']}';
              }
            } else if (errorData.containsKey('detail')) {
              errorMessage = errorData['detail'].toString();
            } else if (errorData.containsKey('message')) {
              errorMessage = errorData['message'].toString();
            } else {
              // Format validation errors nicely
              final errors = <String>[];
              errorData.forEach((key, value) {
                if (value is List) {
                  errors.add('$key: ${value.join(", ")}');
                } else if (value is Map) {
                  // Handle nested errors
                  value.forEach((nestedKey, nestedValue) {
                    if (nestedValue is List) {
                      errors.add('$key.$nestedKey: ${nestedValue.join(", ")}');
                    } else {
                      errors.add('$key.$nestedKey: $nestedValue');
                    }
                  });
                } else {
                  errors.add('$key: $value');
                }
              });
              errorMessage = errors.isEmpty ? 'An error occurred' : errors.join('; ');
            }
          } else if (errorData is String) {
            errorMessage = errorData;
          } else {
            errorMessage = errorData.toString();
          }
        }
      } catch (e) {
        // If response is HTML or not parseable, provide a user-friendly message
        if (response.body.trim().startsWith('<!') || response.body.trim().startsWith('<html')) {
          errorMessage = 'Server Error (${response.statusCode}). Please try again later.';
        } else {
          // Try to extract meaningful error from body
          final bodyText = response.body.trim();
          if (bodyText.length > 200) {
            errorMessage = 'Server Error (${response.statusCode}). ${bodyText.substring(0, 200)}...';
          } else {
            errorMessage = 'Server Error (${response.statusCode}): $bodyText';
          }
        }
      }
      throw Exception(errorMessage);
    }
  }

  // Cases API
  Future<List<CaseReport>> getCases({int page = 1}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cases/reports/?page=$page'),
        headers: headers,
      ).timeout(AppConstants.connectionTimeout);

      final data = _handleResponse(response);
      if (data is Map && data.containsKey('results')) {
        final results = data['results'] as List;
        return results.map((json) => CaseReport.fromMap(json as Map<String, dynamic>)).toList();
      } else if (data is List) {
        return data.map((json) => CaseReport.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      // Re-throw error so provider can handle it
      throw Exception('Failed to fetch cases: ${e.toString()}');
    }
  }

  Future<CaseReport> getCaseById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/cases/reports/$id/'),
      headers: headers,
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response);
    return CaseReport.fromMap(data as Map<String, dynamic>);
  }

  Future<CaseReport> createCase(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/cases/reports/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response);
    return CaseReport.fromMap(data as Map<String, dynamic>);
  }

  Future<CaseReport> updateCase(int id, Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/cases/reports/$id/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response);
    return CaseReport.fromMap(data as Map<String, dynamic>);
  }

  Future<void> deleteCase(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/cases/reports/$id/'),
      headers: headers,
    ).timeout(AppConstants.connectionTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Livestock API
  Future<List<Livestock>> getLivestock({int page = 1}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/livestock/?page=$page'),
        headers: headers,
      ).timeout(AppConstants.connectionTimeout);

      final data = _handleResponse(response);
      if (data is Map && data.containsKey('results')) {
        final results = data['results'] as List;
        return results.map((json) => Livestock.fromMap(json as Map<String, dynamic>)).toList();
      } else if (data is List) {
        return data.map((json) => Livestock.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      // Re-throw error so provider can handle it
      throw Exception('Failed to fetch livestock: ${e.toString()}');
    }
  }

  Future<Livestock> getLivestockById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/livestock/$id/'),
      headers: headers,
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response);
    return Livestock.fromMap(data as Map<String, dynamic>);
  }

  Future<Livestock> createLivestock(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/livestock/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response);
    return Livestock.fromMap(data as Map<String, dynamic>);
  }

  Future<Livestock> updateLivestock(int id, Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/livestock/$id/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response);
    return Livestock.fromMap(data as Map<String, dynamic>);
  }

  Future<void> deleteLivestock(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/livestock/$id/'),
      headers: headers,
    ).timeout(AppConstants.connectionTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<LivestockType>> getLivestockTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/livestock/types/'),
        headers: headers,
      ).timeout(AppConstants.connectionTimeout);

      final data = _handleResponse(response);
      if (data is List) {
        return data.map((json) => LivestockType.fromMap(json as Map<String, dynamic>)).toList();
      } else if (data is Map && data.containsKey('results')) {
        // Handle paginated response
        final results = data['results'] as List;
        return results.map((json) => LivestockType.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      // Re-throw error so provider can handle it and show to user
      throw Exception('Failed to fetch livestock types: ${e.toString()}');
    }
  }

  Future<List<Breed>> getBreeds({int? livestockTypeId}) async {
    try {
      final headers = await _getHeaders();
      final uri = livestockTypeId != null
          ? Uri.parse('$baseUrl/livestock/breeds/?livestock_type=$livestockTypeId')
          : Uri.parse('$baseUrl/livestock/breeds/');
      
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(AppConstants.connectionTimeout);

      final data = _handleResponse(response);
      if (data is List) {
        return data.map((json) => Breed.fromMap(json as Map<String, dynamic>)).toList();
      } else if (data is Map && data.containsKey('results')) {
        // Handle paginated response
        final results = data['results'] as List;
        return results.map((json) => Breed.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      // Re-throw error so provider can handle it and show to user
      throw Exception('Failed to fetch breeds: ${e.toString()}');
    }
  }

  // Community API
  Future<List<Post>> getPosts({PostType? type, int page = 1}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{'page': page.toString()};
      if (type != null) {
        queryParams['type'] = type.apiValue;
      }
      
      final uri = Uri.parse('$baseUrl/community/posts/').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(AppConstants.connectionTimeout);

      final data = _handleResponse(response);
      if (data is Map && data.containsKey('results')) {
        final results = data['results'] as List;
        return results.map((json) => Post.fromMap(json as Map<String, dynamic>)).toList();
      } else if (data is List) {
        return data.map((json) => Post.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Post> createPost(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/community/posts/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response);
    return Post.fromMap(data as Map<String, dynamic>);
  }

  Future<List<Comment>> getComments(int postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/community/posts/$postId/comments/'),
        headers: headers,
      ).timeout(AppConstants.connectionTimeout);

      final data = _handleResponse(response);
      if (data is List) {
        return data.map((json) => Comment.fromMap(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Comment> createComment(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/community/comments/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response);
    return Comment.fromMap(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> likePost(int postId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/community/posts/$postId/like/'),
      headers: headers,
    ).timeout(AppConstants.connectionTimeout);

    return _handleResponse(response) as Map<String, dynamic>;
  }

  // Dashboard API
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats/'),
        headers: headers,
      ).timeout(AppConstants.connectionTimeout);

      return _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      // Return empty stats for demo
      return {
        'total_livestock': 0,
        'total_cases': 0,
        'active_cases': 0,
        'resolved_cases': 0,
      };
    }
  }

  // Weather API
  Future<Map<String, dynamic>> getWeather({String? location}) async {
    try {
      final headers = await _getHeaders();
      final Map<String, String> queryParams = location != null ? {'location': location} : {};
      final uri = Uri.parse('$baseUrl/weather/').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(AppConstants.connectionTimeout);

      return _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      // Return empty weather for demo
      return {
        'temperature': 25,
        'condition': 'Sunny',
        'humidity': 60,
      };
    }
  }

  // Authentication API
  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final headers = await _getHeaders(includeAuth: false);
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    return _handleResponse(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String emailOrPhone, String password) async {
    final headers = await _getHeaders(includeAuth: false);
    
    // Determine if input is email or phone number
    final isEmail = emailOrPhone.contains('@');
    final payload = {
      'password': password,
    };
    
    if (isEmail) {
      payload['email'] = emailOrPhone;
    } else {
      payload['phone_number'] = emailOrPhone;
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response) as Map<String, dynamic>;
    
    // Store tokens and user info
    if (data.containsKey('access')) {
      await _storage.write(key: AppConstants.authTokenKey, value: data['access']);
    }
    if (data.containsKey('refresh')) {
      await _storage.write(key: AppConstants.refreshTokenKey, value: data['refresh']);
    }
    if (data.containsKey('user') && data['user'] is Map) {
      final user = data['user'] as Map<String, dynamic>;
      if (user.containsKey('id')) {
        await _storage.write(key: AppConstants.userIdKey, value: user['id'].toString());
      }
      if (user.containsKey('user_type')) {
        await _storage.write(key: AppConstants.userTypeKey, value: user['user_type'].toString());
      }
    }
    
    return data;
  }

  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otpCode, {String? email}) async {
    final headers = await _getHeaders(includeAuth: false);
    final payload = {
      'otp_code': otpCode,
    };
    
    // Use email if provided (for local_vet), otherwise use phone_number
    if (email != null && email.isNotEmpty) {
      payload['email'] = email;
    } else {
      payload['phone_number'] = phoneNumber;
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    final data = _handleResponse(response) as Map<String, dynamic>;
    
    // Store tokens if provided
    if (data.containsKey('access')) {
      await _storage.write(key: AppConstants.authTokenKey, value: data['access']);
    }
    if (data.containsKey('refresh')) {
      await _storage.write(key: AppConstants.refreshTokenKey, value: data['refresh']);
    }
    
    return data;
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.authTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userIdKey);
  }

  // User Profile API
  Future<Map<String, dynamic>> getCurrentUser() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile/'),
      headers: headers,
    ).timeout(AppConstants.connectionTimeout);

    return _handleResponse(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> payload) async {
    final headers = await _getHeaders();
    final userId = await _storage.read(key: AppConstants.userIdKey);
    if (userId == null) {
      throw Exception('User ID not found. Please login again.');
    }
    
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    return _handleResponse(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password/'),
      headers: headers,
      body: json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'password_confirm': newPassword,
      }),
    ).timeout(AppConstants.connectionTimeout);

    return _handleResponse(response) as Map<String, dynamic>;
  }

  // Password Reset
  Future<Map<String, dynamic>> requestPasswordReset(String emailOrPhone) async {
    final headers = await _getHeaders(includeAuth: false);
    
    // Determine if it's email or phone and clean phone number
    final isEmail = emailOrPhone.contains('@');
    String? phoneNumber;
    
    if (!isEmail) {
      // Clean and format phone number
      String cleaned = emailOrPhone.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleaned.startsWith('+')) {
        phoneNumber = cleaned;
      } else if (cleaned.startsWith('250')) {
        phoneNumber = '+$cleaned';
      } else if (cleaned.startsWith('0')) {
        phoneNumber = '+250${cleaned.substring(1)}';
      } else {
        phoneNumber = '+250$cleaned';
      }
    }
    
    final payload = isEmail 
        ? {'email': emailOrPhone.trim()}
        : {'phone_number': phoneNumber};
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password-reset/request/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    return _handleResponse(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyPasswordResetOTP(String emailOrPhone, String otpCode) async {
    final headers = await _getHeaders(includeAuth: false);
    
    // Determine if it's email or phone and clean phone number
    final isEmail = emailOrPhone.contains('@');
    String? phoneNumber;
    
    if (!isEmail) {
      // Clean and format phone number
      String cleaned = emailOrPhone.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleaned.startsWith('+')) {
        phoneNumber = cleaned;
      } else if (cleaned.startsWith('250')) {
        phoneNumber = '+$cleaned';
      } else if (cleaned.startsWith('0')) {
        phoneNumber = '+250${cleaned.substring(1)}';
      } else {
        phoneNumber = '+250$cleaned';
      }
    }
    
    final payload = {
      ...(isEmail ? {'email': emailOrPhone.trim()} : {'phone_number': phoneNumber}),
      'otp_code': otpCode,
    };
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password-reset/verify-otp/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    return _handleResponse(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resetPassword(String emailOrPhone, String otpCode, String newPassword, String passwordConfirm) async {
    final headers = await _getHeaders(includeAuth: false);
    
    // Determine if it's email or phone and clean phone number
    final isEmail = emailOrPhone.contains('@');
    String? phoneNumber;
    
    if (!isEmail) {
      // Clean and format phone number
      String cleaned = emailOrPhone.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleaned.startsWith('+')) {
        phoneNumber = cleaned;
      } else if (cleaned.startsWith('250')) {
        phoneNumber = '+$cleaned';
      } else if (cleaned.startsWith('0')) {
        phoneNumber = '+250${cleaned.substring(1)}';
      } else {
        phoneNumber = '+250$cleaned';
      }
    }
    
    final payload = {
      ...(isEmail ? {'email': emailOrPhone.trim()} : {'phone_number': phoneNumber}),
      'otp_code': otpCode,
      'new_password': newPassword,
      'password_confirm': passwordConfirm,
    };
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password-reset/reset/'),
      headers: headers,
      body: json.encode(payload),
    ).timeout(AppConstants.connectionTimeout);

    return _handleResponse(response) as Map<String, dynamic>;
  }

  // Toggle veterinarian availability (online/offline)
  Future<Map<String, dynamic>> toggleAvailability(bool isOnline) async {
    final headers = await _getHeaders();
    
    // Get current user to get userId and check availability
    final user = await getCurrentUser();
    final userId = user['id'];
    if (userId == null) {
      throw Exception('User ID not found. Please login again.');
    }
    
    final currentAvailability = user['veterinarian_profile']?['is_available'] ?? true;
    
    // Only toggle if different
    if (currentAvailability == isOnline) {
      // Already in desired state, just return
      return user;
    }
    
    // Call toggle endpoint
    final response = await http.post(
      Uri.parse('$baseUrl/veterinarians/$userId/toggle_availability/'),
      headers: headers,
    ).timeout(AppConstants.connectionTimeout);

    return _handleResponse(response) as Map<String, dynamic>;
  }
}

