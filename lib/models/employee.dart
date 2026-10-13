class Employee {
  final String id;
  String name;
  String role;
  bool isActive;
  String avatarUrl;
  String username;
  String password;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    this.isActive = true,
    this.avatarUrl = '',
    this.username = '',
    this.password = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'isActive': isActive,
    'avatarUrl': avatarUrl,
    'username': username,
    'password': password,
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? 'Cashier',
    isActive: json['isActive'] as bool? ?? true,
    avatarUrl: json['avatarUrl'] as String? ?? '',
    // Records saved before accounts existed load with empty credentials.
    username: json['username'] as String? ?? '',
    password: json['password'] as String? ?? '',
  );
}
