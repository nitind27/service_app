import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../config/app_theme.dart';

class BookingChatScreen extends StatefulWidget {
  final int bookingId;
  final String bookingNumber;
  final String serviceTitle;

  const BookingChatScreen({
    super.key,
    required this.bookingId,
    required this.bookingNumber,
    required this.serviceTitle,
  });

  @override
  State<BookingChatScreen> createState() => _BookingChatScreenState();
}

class _BookingChatScreenState extends State<BookingChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  final List<String> _quickPresets = [
    'I have arrived at your doorstep',
    'Where can I park my vehicle?',
    'Please give me 5 minutes',
    'Calling you shortly',
    'Doorstep security OTP ready',
  ];

  @override
  void initState() {
    super.initState();
    final chat = context.read<ChatProvider>();
    chat.fetchMessages(widget.bookingId);

    // Live polling every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        context.read<ChatProvider>().fetchMessages(widget.bookingId, silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    final chat = context.read<ChatProvider>();
    _msgController.clear();
    final success = await chat.sendMessage(widget.bookingId, text);
    if (success) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chat = context.watch<ChatProvider>();
    final currentUserId = auth.user?.id ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${widget.bookingNumber}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            Text(widget.serviceTitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMedium), maxLines: 1),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Presets
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.grey.shade50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _quickPresets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final preset = _quickPresets[idx];
                return ActionChip(
                  label: Text(preset, style: const TextStyle(fontSize: 11)),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  onPressed: () => _send(preset),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Messages List
          Expanded(
            child: chat.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chat.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppTheme.textLight),
                            const SizedBox(height: 12),
                            const Text('No messages yet', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              'Start conversation with your ${auth.isProvider ? 'customer' : 'service technician'}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chat.messages.length,
                        itemBuilder: (context, idx) {
                          final msg = chat.messages[idx];
                          final isMe = msg.isMe(currentUserId);

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? AppTheme.primaryBlue : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(14),
                                  topRight: const Radius.circular(14),
                                  bottomLeft: isMe ? const Radius.circular(14) : Radius.zero,
                                  bottomRight: isMe ? Radius.zero : const Radius.circular(14),
                                ),
                                border: isMe ? null : Border.all(color: AppTheme.borderColor),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        '${msg.senderName} (${msg.senderRole.toUpperCase()})',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    msg.message,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : AppTheme.textDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg.createdAt.length >= 16 ? msg.createdAt.substring(11, 16) : '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe ? Colors.white70 : AppTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _send(_msgController.text),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
