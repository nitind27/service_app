import 'package:flutter/material.dart';
import '../models/payout_model.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class PayoutProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PayoutModel> _payouts = [];
  Map<String, dynamic> _summary = {
    'totalEarnings': 0.0,
    'paidSum': 0.0,
    'pendingSum': 0.0,
    'withdrawable': 0.0,
  };
  Map<String, dynamic> _bankDetails = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<PayoutModel> get payouts => _payouts;
  Map<String, dynamic> get summary => _summary;
  double get withdrawable => (_summary['withdrawable'] is num) ? (_summary['withdrawable'] as num).toDouble() : 0.0;
  double get totalEarnings => (_summary['totalEarnings'] is num) ? (_summary['totalEarnings'] as num).toDouble() : 0.0;
  Map<String, dynamic> get bankDetails => _bankDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch provider payouts and earnings summary
  Future<void> fetchPayouts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.get(ApiConstants.providerPayouts);
      if (res.success && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        if (data['payouts'] != null) {
          final list = data['payouts'] as List;
          _payouts = list.map((p) => PayoutModel.fromJson(p)).toList();
        }
        if (data['summary'] != null) {
          _summary = data['summary'] as Map<String, dynamic>;
        }
        if (data['bankDetails'] != null) {
          _bankDetails = data['bankDetails'] as Map<String, dynamic>;
        }
      } else {
        _errorMessage = res.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request withdrawal payout
  Future<bool> requestPayout({
    required double amount,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? upiId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post(ApiConstants.providerPayouts, {
        'amount': amount,
        'bank_name': bankName,
        'account_number': accountNumber,
        'ifsc_code': ifscCode,
        'upi_id': upiId,
      });

      _isLoading = false;
      if (res.success) {
        await fetchPayouts();
        return true;
      } else {
        _errorMessage = res.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
