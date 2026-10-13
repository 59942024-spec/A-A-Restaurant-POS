import 'package:flutter/material.dart';
import '../../models/cashier_session.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'cashier_main_shell.dart';
import 'cashier_register_screen.dart';

class CashierLoginScreen extends StatefulWidget {
  const CashierLoginScreen({super.key});

  @override
  State<CashierLoginScreen> createState() => _CashierLoginScreenState();
}

class _CashierLoginScreenState extends State<CashierLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppState _appState = AppState();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _managerController = TextEditingController();
  final TextEditingController _shiftStartController = TextEditingController();
  final TextEditingController _shiftEndController = TextEditingController();

  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _managerController.dispose();
    _shiftStartController.dispose();
    _shiftEndController.dispose();
    super.dispose();
  }

  /// Autofills the username only. The password is never filled in for the user.
  void _quickFillFromEmployee(String empId) {
    final emp = _appState.employees.firstWhere(
      (e) => e.id == empId,
      orElse: () => _appState.employees.first,
    );
    setState(() => _usernameController.text = emp.username);
  }

  void _handleLogin() {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final emp = _appState.authenticateCashier(
      _usernameController.text,
      _passwordController.text,
    );

    if (emp == null) {
      setState(() => _errorMessage =
          'Invalid username or password, or this account is inactive.');
      return;
    }

    final session = CashierSession(
      // Identity comes from the matched employee, not from form input.
      fullName: emp.name,
      username: emp.username,
      employeeId: emp.id,
      password: emp.password,
      managerToday: _managerController.text.trim(),
      shiftStart: _shiftStartController.text.trim(),
      shiftEnd: _shiftEndController.text.trim(),
      loginTime: DateTime.now(),
    );

    _appState.loginCashier(session);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome, ${session.fullName}! Shift session started.'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CashierMainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cashierEmployees =
        _appState.employees.where((e) => e.role == 'Cashier').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Branding
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.badge_outlined,
                                size: 38,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Cashier Shift Login',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Record your shift details to operate the POS terminal for today',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Staff Selector
                      if (cashierEmployees.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on,
                                  color: AppTheme.primary, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Quick Select Cashier:',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: cashierEmployees.map((emp) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: ActionChip(
                                          label: Text(
                                            '${emp.name} (${emp.id})',
                                            style:
                                                const TextStyle(fontSize: 11),
                                          ),
                                          onPressed: () =>
                                              _quickFillFromEmployee(emp.id),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: AppTheme.danger, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Row: Username & Password
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Username',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _usernameController,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Username is required'
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: 'juan_cashier',
                                    prefixIcon:
                                        const Icon(Icons.account_circle_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Password / Temp Password',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Password is required'
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Manager for Today
                      const Text('Manager for Today',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _managerController,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Manager name is required'
                            : null,
                        decoration: InputDecoration(
                          hintText: '(Available Manager)',
                          prefixIcon:
                              const Icon(Icons.supervisor_account_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Shift Start & Shift End
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Shift Start',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _shiftStartController,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Start time required'
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: '08:00 AM',
                                    prefixIcon:
                                        const Icon(Icons.access_time_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Shift End',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _shiftEndController,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'End time required'
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: '04:00 PM',
                                    prefixIcon: const Icon(Icons.timelapse),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.login),
                          label: const Text(
                            'Start Shift & Open POS',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Register a new cashier account
                      TextButton.icon(
                        icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                        label: const Text('Register as Cashier'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CashierRegisterScreen()),
                        ),
                      ),

                      // Back Button
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Role Selection'),
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
}
