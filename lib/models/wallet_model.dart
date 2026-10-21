class WalletTransaction {
  final int id;
  final String type; // credit, debit
  final double amount;
  final double balanceAfter;
  final String description;
  final String createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
  });

  bool get isCredit => type.toLowerCase() == 'credit';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? 'credit',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      balanceAfter: (json['balance_after'] is num) ? (json['balance_after'] as num).toDouble() : double.tryParse(json['balance_after']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString() ?? 'Transaction',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class WalletModel {
  final double balance;
  final List<WalletTransaction> transactions;

  WalletModel({
    required this.balance,
    required this.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final txList = (json['transactions'] as List?)
            ?.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return WalletModel(
      balance: (json['balance'] is num) ? (json['balance'] as num).toDouble() : double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      transactions: txList,
    );
  }
}
