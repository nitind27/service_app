import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  int? _currentBookingId;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  int? get currentBookingId => _currentBookingId;

  /// Fetch messages for a booking
  Future<void> fetchMessages(int bookingId, {bool silent = false}) async {
    _currentBookingId = bookingId;
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final res = await _apiService.get('${ApiConstants.bookings}/$bookingId/messages');
      if (res.success && res.data != null && res.data['messages'] != null) {
        final list = res.data['messages'] as List;
        _messages = list.map((m) => ChatMessageModel.fromJson(m)).toList();
      }
    } catch (_) {
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Send message in chat
  Future<bool> sendMessage(int bookingId, String text) async {
    if (text.trim().isEmpty) return false;

    _isSending = true;
    notifyListeners();

    try {
      final res = await _apiService.post(
        '${ApiConstants.bookings}/$bookingId/messages',
        {'message': text.trim()},
      );

      _isSending = false;
      if (res.success && res.data != null && res.data['message'] != null) {
        final newMsg = ChatMessageModel.fromJson(res.data['message']);
        _messages.add(newMsg);
        notifyListeners();
        return true;
      }
    } catch (_) {
      _isSending = false;
      notifyListeners();
    }
    return false;
  }
}
