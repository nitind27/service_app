import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  /// Load cached token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_jwt_token');
  }

  /// Check if user has an auth token
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  String? get token => _authToken;

  /// Save token
  Future<void> setToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_jwt_token', token);
  }

  /// Remove token
  Future<void> clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_jwt_token');
    await prefs.remove('auth_user_data');
  }

  /// Headers builder
  Map<String, String> _buildHeaders({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
      // Also send cookie fallback
      headers['Cookie'] = 'allservice_auth_token=$_authToken';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  /// GET Request
  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final base = ApiConstants.baseUrl;
      var uri = Uri.parse('$base$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network connection error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// POST Request
  Future<ApiResponse<dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final base = ApiConstants.baseUrl;
      final uri = Uri.parse('$base$endpoint');

      final response = await http
          .post(
            uri,
            headers: _buildHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network connection error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// PATCH Request
  Future<ApiResponse<dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final base = ApiConstants.baseUrl;
      final uri = Uri.parse('$base$endpoint');

      final response = await http
          .patch(
            uri,
            headers: _buildHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network connection error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// DELETE Request
  Future<ApiResponse<dynamic>> delete(String endpoint) async {
    try {
      final base = ApiConstants.baseUrl;
      final uri = Uri.parse('$base$endpoint');

      final response = await http
          .delete(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network connection error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Standardized response parser
  ApiResponse<dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final bool success = body['success'] == true;
      final String message = body['message']?.toString() ??
          (success ? 'Success' : 'Request failed');
      final dynamic data = body['data'];

      return ApiResponse(
        success: success,
        message: message,
        data: data,
        statusCode: response.statusCode,
      );
    } catch (_) {
      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        message: response.statusCode == 200 ? 'Success' : 'Server response error: ${response.statusCode}',
        data: null,
        statusCode: response.statusCode,
      );
    }
  }
}
