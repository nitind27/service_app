class UserModel {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String role; // customer, provider, admin, subadmin
  final String city;
  final String? profileImage;
  final double walletBalance;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    this.city = 'New Delhi',
    this.profileImage,
    this.walletBalance = 0.0,
  });

  bool get isCustomer => role.toLowerCase() == 'customer';
  bool get isProvider => role.toLowerCase() == 'provider';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      role: json['role']?.toString() ?? json['role_name']?.toString() ?? 'customer',
      city: json['city']?.toString() ?? 'New Delhi',
      profileImage: json['profile_image']?.toString(),
      walletBalance: (json['wallet_balance'] is num)
          ? (json['wallet_balance'] as num).toDouble()
          : double.tryParse(json['wallet_balance']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'city': city,
      'profile_image': profileImage,
      'wallet_balance': walletBalance,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? mobile,
    String? city,
    String? profileImage,
    double? walletBalance,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      role: role,
      city: city ?? this.city,
      profileImage: profileImage ?? this.profileImage,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}
