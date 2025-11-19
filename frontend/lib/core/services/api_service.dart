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
      return json.decode(response.body);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
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
    
    // Store tokens
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
    }
    
    return data;
  }

  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otpCode) async {
    final headers = await _getHeaders(includeAuth: false);
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp/'),
      headers: headers,
      body: json.encode({
        'phone_number': phoneNumber,
        'otp_code': otpCode,
      }),
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
}

