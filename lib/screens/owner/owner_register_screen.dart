import 'package:flutter/material.dart';
import '../../models/owner_account.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'owner_main_shell.dart';

class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppState _appState = AppState();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();

    if (username.toLowerCase() == 'enchang') {
      setState(() => _errorMessage = 'That username is reserved.');
      return;
    }

    _appState.registerOwner(OwnerAccount(
      fullName: _nameController.text.trim(),
      username: username,
      password: _passwordController.text,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Owner account created. Welcome, ${_nameController.text.trim()}!'),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OwnerMainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_add_alt_1,
                            size: 36, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Create Owner Account',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set up the administrator login for this terminal',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),

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
                            style: const TextStyle(color: AppTheme.danger, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _buildField(
                        label: 'Full Name',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        hint: 'e.g. Enchang Reyes',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Full name is required' : null,
                      ),
                      _buildField(
                        label: 'Username',
                        controller: _usernameController,
                        icon: Icons.account_circle_outlined,
                        hint: 'e.g. enchang_admin',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Username is required' : null,
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

                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text(
                            'Create Account',
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
