import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String _defaultPort = '3000';
  static const String defaultLanIp = '192.168.1.14'; // User's local network IP
  
  // Custom baseUrl stored in memory and SharedPreferences
  static String? _customBaseUrl;

  /// Returns the smart base URL depending on the runtime platform
  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    
    if (kIsWeb) {
      return 'http://localhost:$_defaultPort/api';
    }
    
    try {
      if (Platform.isAndroid) {
        // Standard Android emulator loopback alias
        // When running on physical Android, user can switch to LAN IP via settings
        return 'http://10.0.2.2:$_defaultPort/api';
      } else if (Platform.isIOS) {
        return 'http://localhost:$_defaultPort/api';
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return 'http://localhost:$_defaultPort/api';
      }
    } catch (_) {
      // Fallback
    }

    return 'http://localhost:$_defaultPort/api';
  }

  /// Initialize custom base URL from persistent storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _customBaseUrl = prefs.getString('api_base_url');
  }

  /// Update base URL at runtime (e.g. from developer / server settings screen)
  static Future<void> setCustomBaseUrl(String url) async {
    _customBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    final prefs = await SharedPreferences.getInstance();
    if (_customBaseUrl!.isEmpty) {
      await prefs.remove('api_base_url');
      _customBaseUrl = null;
    } else {
      await prefs.setString('api_base_url', _customBaseUrl!);
    }
  }

  // Pre-configured options for quick selection
  static const String localhostUrl = 'http://localhost:3000/api';
  static const String androidEmulatorUrl = 'http://10.0.2.2:3000/api';
  static const String lanWifiUrl = 'http://$defaultLanIp:3000/api';

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  static const String categories = '/categories';
  static const String services = '/services';
  static const String locationDetect = '/location/detect';
  static const String pincodeCheck = '/pincode/check';

  static const String bookings = '/bookings';
  static const String wallet = '/user/wallet';
  static const String notifications = '/notifications';

  static const String providerPayouts = '/provider/payouts';
  static const String providerEarnings = '/provider/earnings';
}
