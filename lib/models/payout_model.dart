class PayoutModel {
  final int id;
  final double amount;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;
  final String status; // pending, processed, rejected
  final String createdAt;

  PayoutModel({
    required this.id,
    required this.amount,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.upiId,
    required this.status,
    required this.createdAt,
  });

  bool get isProcessed => status.toLowerCase() == 'processed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      upiId: json['upi_id']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
