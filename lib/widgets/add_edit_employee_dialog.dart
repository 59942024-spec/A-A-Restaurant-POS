import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class AddEditEmployeeDialog extends StatefulWidget {
  final Employee? employee;
  final Function(Employee emp) onSave;

  const AddEditEmployeeDialog({
    super.key,
    this.employee,
    required this.onSave,
  });

  @override
  State<AddEditEmployeeDialog> createState() => _AddEditEmployeeDialogState();
}

class _AddEditEmployeeDialogState extends State<AddEditEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final AppState _appState = AppState();

  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late String _selectedRole;
  late bool _isActive;

  final List<String> _roles = ['Cashier', 'Server', 'Cook', 'Manager'];

  /// EMP001, EMP002, ... based on existing records.
  String _nextEmployeeId() {
    int max = 0;
    final re = RegExp(r'^EMP(\d+)$');
    for (final e in _appState.employees) {
      final m = re.firstMatch(e.id.trim());
      if (m != null) {
        final n = int.tryParse(m.group(1)!) ?? 0;
        if (n > max) max = n;
      }
    }
    return 'EMP${(max + 1).toString().padLeft(3, '0')}';
  }

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;
    _nameController = TextEditingController(text: emp?.name ?? '');
    _idController =
        TextEditingController(text: emp?.id ?? _nextEmployeeId());
    _usernameController = TextEditingController(text: emp?.username ?? '');
    _passwordController = TextEditingController(text: emp?.password ?? '');
    _selectedRole = emp?.role ?? 'Cashier';
    _isActive = emp?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Employee' : 'Add Employee',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Maria Santos',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),

              // Employee ID
              const Text('Employee ID', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _idController,
                validator: (v) => v == null || v.trim().isEmpty ? 'ID is required' : null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              // Username
              const SizedBox(height: 12),
              const Text('Username',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _usernameController,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Username is required';
                  final editingId = widget.employee?.id;
                  final taken = _appState.employees.any(
                      (e) => e.username == value && e.id != editingId);
                  if (taken) return 'That username is already taken';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'e.g. juan_cashier',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              // Password
              const SizedBox(height: 12),
              const Text('Password',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (v) => v == null || v.isEmpty
                    ? 'Password is required'
                    : (v.length < 6 ? 'Use at least 6 characters' : null),
                decoration: InputDecoration(
                  hintText: 'At least 6 characters',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 12),

              // Role
              const Text('Role', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedRole,
                    items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedRole = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Active status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Switch(
                    value: _isActive,
                    activeTrackColor: AppTheme.success,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final emp = Employee(
                            id: _idController.text.trim(),
                            name: _nameController.text.trim(),
                            role: _selectedRole,
                            isActive: _isActive,
                            username: _usernameController.text.trim(),
                            password: _passwordController.text,
                          );
                          widget.onSave(emp);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(isEditing ? 'Save' : 'Add Employee'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
