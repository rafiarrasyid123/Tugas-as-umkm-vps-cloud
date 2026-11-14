class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String? phone;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
  });

  bool get isAdmin => role == 'admin';
  bool get isClient => role == 'client';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'phone': phone,
    };
  }
}
