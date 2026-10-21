class BookingModel {
  final int id;
  final String bookingNumber;
  final String serviceOtp;
  final int? userId;
  final int? providerId;
  final int serviceId;
  final String serviceTitle;
  final String? serviceThumbnail;
  final String? serviceSlug;
  final String categoryName;
  final String? providerName;
  final String? providerMobile;
  final String? variantTitle;
  final String customerName;
  final String customerMobile;
  final String? customerEmail;
  final String addressSnapshot;
  final String bookingDate;
  final String timeSlot;
  final String? specialInstructions;
  final double baseAmount;
  final double taxAmount;
  final double discountAmount;
  final double convenienceFee;
  final double walletAmountUsed;
  final double totalAmount;
  final String paymentMode;
  final String paymentStatus;
  final String bookingStatus; // pending, confirmed, assigned, in_progress, completed, cancelled
  final String? createdAt;

  BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.serviceOtp,
    this.userId,
    this.providerId,
    required this.serviceId,
    required this.serviceTitle,
    this.serviceThumbnail,
    this.serviceSlug,
    required this.categoryName,
    this.providerName,
    this.providerMobile,
    this.variantTitle,
    required this.customerName,
    required this.customerMobile,
    this.customerEmail,
    required this.addressSnapshot,
    required this.bookingDate,
    required this.timeSlot,
    this.specialInstructions,
    this.baseAmount = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    this.convenienceFee = 49.0,
    this.walletAmountUsed = 0.0,
    required this.totalAmount,
    this.paymentMode = 'cod',
    this.paymentStatus = 'pending',
    this.bookingStatus = 'pending',
    this.createdAt,
  });

  bool get isActive => bookingStatus == 'pending' || bookingStatus == 'confirmed' || bookingStatus == 'assigned' || bookingStatus == 'in_progress';
  bool get isCompleted => bookingStatus == 'completed';
  bool get isCancelled => bookingStatus == 'cancelled';
  bool get isInProgress => bookingStatus == 'in_progress';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      bookingNumber: json['booking_number']?.toString() ?? '',
      serviceOtp: json['service_otp']?.toString() ?? '****',
      userId: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
      providerId: json['provider_id'] != null ? int.tryParse(json['provider_id'].toString()) : null,
      serviceId: json['service_id'] is int ? json['service_id'] : int.tryParse(json['service_id']?.toString() ?? '0') ?? 0,
      serviceTitle: json['service_title']?.toString() ?? 'Service Booking',
      serviceThumbnail: json['service_thumbnail']?.toString(),
      serviceSlug: json['service_slug']?.toString(),
      categoryName: json['category_name']?.toString() ?? 'General',
      providerName: json['provider_name']?.toString(),
      providerMobile: json['provider_mobile']?.toString(),
      variantTitle: json['variant_title']?.toString(),
      customerName: json['customer_name']?.toString() ?? 'Customer',
      customerMobile: json['customer_mobile']?.toString() ?? '',
      customerEmail: json['customer_email']?.toString(),
      addressSnapshot: json['address_snapshot']?.toString() ?? 'Doorstep Service Address',
      bookingDate: json['booking_date']?.toString() ?? '',
      timeSlot: json['time_slot']?.toString() ?? 'Anytime',
      specialInstructions: json['special_instructions']?.toString(),
      baseAmount: (json['base_amount'] is num) ? (json['base_amount'] as num).toDouble() : double.tryParse(json['base_amount']?.toString() ?? '0') ?? 0.0,
      taxAmount: (json['tax_amount'] is num) ? (json['tax_amount'] as num).toDouble() : double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      discountAmount: (json['discount_amount'] is num) ? (json['discount_amount'] as num).toDouble() : double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      convenienceFee: (json['convenience_fee'] is num) ? (json['convenience_fee'] as num).toDouble() : double.tryParse(json['convenience_fee']?.toString() ?? '49') ?? 49.0,
      walletAmountUsed: (json['wallet_amount_used'] is num) ? (json['wallet_amount_used'] as num).toDouble() : double.tryParse(json['wallet_amount_used']?.toString() ?? '0') ?? 0.0,
      totalAmount: (json['total_amount'] is num) ? (json['total_amount'] as num).toDouble() : double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paymentMode: json['payment_mode']?.toString() ?? 'cod',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      bookingStatus: json['booking_status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
    );
  }
}
