class CashierSession {
  final String fullName;
  final String username;
  final String employeeId;
  final String password;
  final String managerToday;
  final String shiftStart;
  final String shiftEnd;
  final DateTime loginTime;

  CashierSession({
    required this.fullName,
    required this.username,
    required this.employeeId,
    required this.password,
    required this.managerToday,
    required this.shiftStart,
    required this.shiftEnd,
    required this.loginTime,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'username': username,
    'employeeId': employeeId,
    'password': password,
    'managerToday': managerToday,
    'shiftStart': shiftStart,
    'shiftEnd': shiftEnd,
    'loginTime': loginTime.toIso8601String(),
  };

  factory CashierSession.fromJson(Map<String, dynamic> json) => CashierSession(
    fullName: json['fullName'] as String? ?? '',
    username: json['username'] as String? ?? '',
    employeeId: json['employeeId'] as String? ?? '',
    password: json['password'] as String? ?? '',
    managerToday: json['managerToday'] as String? ?? '',
    shiftStart: json['shiftStart'] as String? ?? '',
    shiftEnd: json['shiftEnd'] as String? ?? '',
    loginTime: json['loginTime'] != null
        ? DateTime.tryParse(json['loginTime'] as String) ?? DateTime.now()
        : DateTime.now(),
  );
}
