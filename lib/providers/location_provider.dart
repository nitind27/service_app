import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class StateCity {
  final String state;
  final List<String> cities;
  const StateCity({required this.state, required this.cities});
}

class LocationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String _city = 'New Delhi';
  String _state = 'Delhi';
  String _pincode = '110001';
  bool _isDetecting = false;

  String get city => _city;
  String get state => _state;
  String get pincode => _pincode;
  String get displayText => '$_city, $_state';
  bool get isDetecting => _isDetecting;

  // 28 Indian States with major cities
  static const List<StateCity> indianStates = [
    StateCity(state: 'Delhi', cities: ['New Delhi', 'North Delhi', 'South Delhi', 'Dwarka', 'Rohini']),
    StateCity(state: 'Maharashtra', cities: ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik', 'Navi Mumbai', 'Aurangabad']),
    StateCity(state: 'Karnataka', cities: ['Bengaluru', 'Mysuru', 'Mangaluru', 'Hubballi', 'Belagavi']),
    StateCity(state: 'Tamil Nadu', cities: ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem']),
    StateCity(state: 'Telangana', cities: ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar']),
    StateCity(state: 'Gujarat', cities: ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar']),
    StateCity(state: 'Uttar Pradesh', cities: ['Noida', 'Lucknow', 'Kanpur', 'Ghaziabad', 'Agra', 'Varanasi', 'Prayagraj']),
    StateCity(state: 'West Bengal', cities: ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri']),
    StateCity(state: 'Rajasthan', cities: ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Bikaner', 'Ajmer']),
    StateCity(state: 'Haryana', cities: ['Gurugram', 'Faridabad', 'Panipat', 'Ambala', 'Karnal']),
    StateCity(state: 'Punjab', cities: ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala']),
    StateCity(state: 'Madhya Pradesh', cities: ['Indore', 'Bhopal', 'Jabalpur', 'Gwalior', 'Ujjain']),
    StateCity(state: 'Bihar', cities: ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur']),
    StateCity(state: 'Andhra Pradesh', cities: ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Tirupati']),
    StateCity(state: 'Kerala', cities: ['Kochi', 'Thiruvananthapuram', 'Kozhikode', 'Thrissur']),
    StateCity(state: 'Assam', cities: ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat']),
    StateCity(state: 'Odisha', cities: ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri']),
    StateCity(state: 'Jharkhand', cities: ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro']),
    StateCity(state: 'Uttarakhand', cities: ['Dehradun', 'Haridwar', 'Rishikesh', 'Haldwani', 'Roorkee']),
    StateCity(state: 'Himachal Pradesh', cities: ['Shimla', 'Dharamshala', 'Mandi', 'Solan']),
    StateCity(state: 'Goa', cities: ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa']),
    StateCity(state: 'Chhattisgarh', cities: ['Raipur', 'Bhilai', 'Bilaspur', 'Korba']),
    StateCity(state: 'Jammu and Kashmir', cities: ['Srinagar', 'Jammu', 'Anantnag']),
    StateCity(state: 'Tripura', cities: ['Agartala']),
    StateCity(state: 'Meghalaya', cities: ['Shillong']),
    StateCity(state: 'Manipur', cities: ['Imphal']),
    StateCity(state: 'Nagaland', cities: ['Kohima', 'Dimapur']),
    StateCity(state: 'Sikkim', cities: ['Gangtok']),
  ];

  LocationProvider() {
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _city = prefs.getString('user_city') ?? 'New Delhi';
      _state = prefs.getString('user_state') ?? 'Delhi';
      _pincode = prefs.getString('user_pincode') ?? '110001';
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLocation(String newCity, String newState, {String? pincode}) async {
    _city = newCity;
    _state = newState;
    if (pincode != null) _pincode = pincode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_city', _city);
      await prefs.setString('user_state', _state);
      if (pincode != null) await prefs.setString('user_pincode', _pincode);
    } catch (_) {}
  }

  /// Auto-detect using backend /api/location/detect
  Future<bool> autoDetectLocation({double? lat, double? lng}) async {
    _isDetecting = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (lat != null && lng != null) {
        queryParams['lat'] = lat.toString();
        queryParams['lng'] = lng.toString();
      }

      final res = await _apiService.get(ApiConstants.locationDetect, queryParams: queryParams);
      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        _city = data['city']?.toString() ?? 'New Delhi';
        _state = data['state']?.toString() ?? 'Delhi';
        if (data['pincode'] != null && data['pincode'].toString().isNotEmpty) {
          _pincode = data['pincode'].toString();
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_city', _city);
        await prefs.setString('user_state', _state);
        await prefs.setString('user_pincode', _pincode);

        _isDetecting = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isDetecting = false;
    notifyListeners();
    return false;
  }

  /// Check pincode SLA & serviceability
  Future<Map<String, dynamic>?> checkPincode(String pincode) async {
    try {
      final res = await _apiService.get(ApiConstants.pincodeCheck, queryParams: {'pincode': pincode.trim()});
      if (res.success && res.data != null) {
        return res.data as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
