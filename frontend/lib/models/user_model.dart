class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? company;
  final bool active;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.company,
    required this.active,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'client',
      company: json['company'],
      active: json['active'] ?? true,
    );
  }
}
