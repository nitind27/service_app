import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class WalletProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  WalletModel? _wallet;
  bool _isLoading = false;
  String? _errorMessage;

  WalletModel? get wallet => _wallet;
  double get balance => _wallet?.balance ?? 0.0;
  List<WalletTransaction> get transactions => _wallet?.transactions ?? [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch wallet balance and transaction ledger
  Future<void> fetchWallet() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.get(ApiConstants.wallet);
      if (res.success && res.data != null) {
        _wallet = WalletModel.fromJson(res.data as Map<String, dynamic>);
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

  /// Top-up wallet balance
  Future<bool> topUp(double amount) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post(ApiConstants.wallet, {'amount': amount});
      _isLoading = false;
      if (res.success) {
        await fetchWallet();
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
