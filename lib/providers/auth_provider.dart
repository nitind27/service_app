import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null && _apiService.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isCustomer => _user?.isCustomer ?? true;
  bool get isProvider => _user?.isProvider ?? false;

  /// Check initial auth state from storage and /api/auth/me
  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.init();

      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString('auth_user_data');
      if (userJsonStr != null) {
        _user = UserModel.fromJson(jsonDecode(userJsonStr));
      }

      if (_apiService.isAuthenticated) {
        final res = await _apiService.get(ApiConstants.me);
        if (res.success && res.data != null && res.data['user'] != null) {
          _user = UserModel.fromJson(res.data['user']);
          await prefs.setString('auth_user_data', jsonEncode(_user!.toJson()));
        }
      }
    } catch (_) {
      // Offline fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email or mobile
  Future<bool> login(String emailOrMobile, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post(ApiConstants.login, {
        'emailOrMobile': emailOrMobile.trim(),
        'password': password,
      });

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        
        // Save JWT token
        if (data['token'] != null) {
          await _apiService.setToken(data['token'].toString());
        }

        if (data['user'] != null) {
          _user = UserModel.fromJson(data['user']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_user_data', jsonEncode(_user!.toJson()));
        }

        // Fetch latest profile with wallet balance
        await refreshUser();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register customer or provider
  Future<bool> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
    String city = 'New Delhi',
    String role = 'customer',
    String? businessName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post(ApiConstants.register, {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'mobile': mobile.trim(),
        'password': password,
        'city': city,
        'role': role,
        'businessName': businessName ?? name,
      });

      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        if (data['token'] != null) {
          await _apiService.setToken(data['token'].toString());
        }
        if (data['user'] != null) {
          _user = UserModel.fromJson(data['user']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_user_data', jsonEncode(_user!.toJson()));
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reload user state (e.g. after booking, top-up)
  Future<void> refreshUser() async {
    try {
      if (!_apiService.isAuthenticated) return;
      final res = await _apiService.get(ApiConstants.me);
      if (res.success && res.data != null && res.data['user'] != null) {
        _user = UserModel.fromJson(res.data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user_data', jsonEncode(_user!.toJson()));
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Sign out
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout, {});
    } catch (_) {}
    await _apiService.clearToken();
    _user = null;
    notifyListeners();
  }
}
