import 'package:flutter/material.dart';
import '../../models/cashier_session.dart';
import '../../models/employee.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'cashier_main_shell.dart';

class CashierRegisterScreen extends StatefulWidget {
  const CashierRegisterScreen({super.key});

  @override
  State<CashierRegisterScreen> createState() => _CashierRegisterScreenState();
}

class _CashierRegisterScreenState extends State<CashierRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppState _appState = AppState();

  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _idController.text = _nextEmployeeId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// CSH001, CSH002, ... based on existing Cashier records.
  String _nextEmployeeId() {
    int max = 0;
    for (final e in _appState.employees) {
      final m = RegExp(r'^CSH(\d+)$').firstMatch(e.id.trim());
      if (m != null) {
        final n = int.tryParse(m.group(1)!) ?? 0;
        if (n > max) max = n;
      }
    }
    return 'CSH${(max + 1).toString().padLeft(3, '0')}';
  }

  void _handleRegister() {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final emp = Employee(
      id: _idController.text.trim(),
      name: _nameController.text.trim(),
      role: 'Cashier',
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    final error = _appState.registerCashier(emp);
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    // Registered successfully — start their shift right away.
    _appState.loginCashier(CashierSession(
      fullName: emp.name,
      username: emp.username,
      employeeId: emp.id,
      password: emp.password,
      managerToday: 'Registered shift',
      shiftStart: TimeOfDay.now().format(context),
      shiftEnd: TimeOfDay.now().format(context),
      loginTime: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created. Welcome, ${emp.name}!'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CashierMainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.badge_outlined,
                                  size: 38, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Cashier Registration',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a login so you can operate the POS terminal',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppTheme.danger, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildField(
                              label: 'Full Name',
                              controller: _nameController,
                              icon: Icons.person_outline,
                              hint: 'e.g. Juan Dela Cruz',
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Full name is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildField(
                              label: 'Employee ID',
                              controller: _idController,
                              icon: Icons.badge_outlined,
                              hint: 'CSH001',
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'ID is required'
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      _buildField(
                        label: 'Username',
                        controller: _usernameController,
                        icon: Icons.account_circle_outlined,
                        hint: 'e.g. juan_cashier',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Username is required';
                          }
                          if (_appState.employees
                              .any((e) => e.username == v.trim())) {
                            return 'That username is already taken';
                          }
                          return null;
                        },
                      ),
                      _buildField(
                        label: 'Password',
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        hint: 'At least 6 characters',
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Use at least 6 characters';
                          return null;
                        },
                      ),
                      _buildField(
                        label: 'Confirm Password',
                        controller: _confirmController,
                        icon: Icons.lock_reset_outlined,
                        hint: 'Re-enter password',
                        obscure: _obscurePassword,
                        validator: (v) =>
                            v != _passwordController.text ? 'Passwords do not match' : null,
                      ),

                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.how_to_reg),
                          label: const Text(
                            'Create Account & Start Shift',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _handleRegister,
                        ),
                      ),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Login'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required String? Function(String?) validator,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
              suffixIcon: suffix,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
