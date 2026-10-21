import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class BookingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<BookingModel> get activeBookings =>
      _bookings.where((b) => b.isActive).toList();

  List<BookingModel> get completedBookings =>
      _bookings.where((b) => b.isCompleted).toList();

  List<BookingModel> get cancelledBookings =>
      _bookings.where((b) => b.isCancelled).toList();

  /// Fetch bookings for authenticated user or provider
  Future<void> fetchBookings({String? status, String? query}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final res = await _apiService.get(ApiConstants.bookings, queryParams: queryParams);
      if (res.success && res.data != null && res.data['bookings'] != null) {
        final list = res.data['bookings'] as List;
        _bookings = list.map((b) => BookingModel.fromJson(b)).toList();
      } else {
        _errorMessage = res.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load bookings: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new booking
  Future<Map<String, dynamic>?> createBooking({
    required int serviceId,
    int? variantId,
    required String customerName,
    required String customerMobile,
    String? customerEmail,
    required String addressSnapshot,
    required String bookingDate,
    required String timeSlot,
    String? specialInstructions,
    String? couponCode,
    bool useWallet = false,
    String paymentMode = 'cashfree',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post(ApiConstants.bookings, {
        'service_id': serviceId,
        'variant_id': variantId,
        'customer_name': customerName,
        'customer_mobile': customerMobile,
        'customer_email': customerEmail,
        'address_snapshot': addressSnapshot,
        'booking_date': bookingDate,
        'time_slot': timeSlot,
        'special_instructions': specialInstructions,
        'coupon_code': couponCode,
        'use_wallet': useWallet,
        'payment_mode': paymentMode,
      });

      _isLoading = false;
      notifyListeners();

      if (res.success && res.data != null) {
        // Refresh bookings list
        fetchBookings();
        return res.data as Map<String, dynamic>;
      } else {
        _errorMessage = res.message;
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Cancel booking with instant wallet refund
  Future<bool> cancelBooking(int bookingId, {String? reason}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.patch('${ApiConstants.bookings}/$bookingId/status', {
        'status': 'cancelled',
        'notes': reason ?? 'Cancelled by customer',
      });

      _isLoading = false;
      if (res.success) {
        await fetchBookings();
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

  /// Provider: Start job with customer's 4-digit Doorstep OTP
  Future<bool> startJobWithOtp(int bookingId, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.patch('${ApiConstants.bookings}/$bookingId/status', {
        'status': 'in_progress',
        'otp': otp.trim(),
        'notes': 'Job started after OTP verification',
      });

      _isLoading = false;
      if (res.success) {
        await fetchBookings();
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

  /// Provider: Complete job
  Future<bool> completeJob(int bookingId, {String? notes, String? photos}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.patch('${ApiConstants.bookings}/$bookingId/status', {
        'status': 'completed',
        'notes': notes ?? 'Service successfully delivered to customer',
        'completion_photos': photos,
      });

      _isLoading = false;
      if (res.success) {
        await fetchBookings();
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
