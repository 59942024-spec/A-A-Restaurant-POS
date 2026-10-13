import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/employee.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_edit_employee_dialog.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _openAddEditEmployee([Employee? emp]) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditEmployeeDialog(
        employee: emp,
        onSave: (savedEmp) {
          if (emp == null) {
            _appState.addEmployee(savedEmp);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added "${savedEmp.name}" to team!')),
            );
          } else {
            _appState.updateEmployee(savedEmp);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Updated "${savedEmp.name}"!')),
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteEmployee(Employee emp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee?'),
        content: Text('Are you sure you want to remove "${emp.name}" from the system?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              _appState.deleteEmployee(emp.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed "${emp.name}".')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employees = _appState.employees;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employees Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage staff credentials, assigned roles, and activity status',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Employee'),
                  onPressed: () => _openAddEditEmployee(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Employee List Cards
            Expanded(
              child: employees.isEmpty
                  ? const Center(
                      child: Text('No employees found.', style: TextStyle(color: Colors.grey)),
                    )
                  : Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListView.separated(
                        itemCount: employees.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final emp = employees[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.secondary,
                              child: Text(
                                emp.name[0],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              emp.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text(
                              'ID: ${emp.id} • Role: ${emp.role}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Active / Inactive Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: emp.isActive ? Colors.green.shade50 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: emp.isActive ? Colors.green.shade300 : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    emp.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: emp.isActive ? AppTheme.success : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: emp.isActive,
                                  activeTrackColor: AppTheme.success,
                                  onChanged: (val) {
                                    _appState.toggleEmployeeActive(emp.id);
                                  },
                                ),
                                const SizedBox(width: 8),

                                // Edit Button
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => _openAddEditEmployee(emp),
                                ),

                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _confirmDeleteEmployee(emp),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
