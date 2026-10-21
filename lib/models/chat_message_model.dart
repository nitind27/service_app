class ChatMessageModel {
  final int id;
  final int bookingId;
  final int senderId;
  final String senderRole;
  final String message;
  final String senderName;
  final String? senderAvatar;
  final String createdAt;

  ChatMessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.senderName,
    this.senderAvatar,
    required this.createdAt,
  });

  bool isMe(int currentUserId) => senderId == currentUserId;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bookingId: json['booking_id'] is int ? json['booking_id'] : int.tryParse(json['booking_id']?.toString() ?? '0') ?? 0,
      senderId: json['sender_id'] is int ? json['sender_id'] : int.tryParse(json['sender_id']?.toString() ?? '0') ?? 0,
      senderRole: json['sender_role']?.toString() ?? 'customer',
      message: json['message']?.toString() ?? '',
      senderName: json['sender_name']?.toString() ?? 'User',
      senderAvatar: json['sender_avatar']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
