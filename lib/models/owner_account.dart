class OwnerAccount {
  final String fullName;
  final String username;
  final String password;

  OwnerAccount({
    required this.fullName,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'username': username,
        'password': password,
      };

  factory OwnerAccount.fromJson(Map<String, dynamic> json) => OwnerAccount(
        fullName: json['fullName'] as String? ?? '',
        username: json['username'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );
}
