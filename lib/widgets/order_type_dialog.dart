import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrderTypeDialog extends StatefulWidget {
  final String currentType;
  final String currentTable;
  final Function(String type, String table) onSave;

  const OrderTypeDialog({
    super.key,
    required this.currentType,
    required this.currentTable,
    required this.onSave,
  });

  @override
  State<OrderTypeDialog> createState() => _OrderTypeDialogState();
}

class _OrderTypeDialogState extends State<OrderTypeDialog> {
  late String _selectedType;
  late String _selectedTable;

  final List<String> _tables = List.generate(12, (index) => 'Table ${index + 1}');

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentType;
    _selectedTable = widget.currentTable.startsWith('Table') ? widget.currentTable : 'Table 1';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Order Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order Type Options: Dine In, Takeout, Delivery
            Row(
              children: [
                _buildTypeCard('Dine In', Icons.restaurant),
                const SizedBox(width: 8),
                _buildTypeCard('Takeout', Icons.shopping_bag_outlined),
                const SizedBox(width: 8),
                _buildTypeCard('Delivery', Icons.delivery_dining_outlined),
              ],
            ),
            const SizedBox(height: 20),

            // Table Selection (Only for Dine In)
            if (_selectedType == 'Dine In') ...[
              const Text(
                'Table Number',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTable,
                    items: _tables.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTable = val);
                      }
                    },
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _selectedType == 'Takeout'
                          ? 'Counter pickup package will be prepared.'
                          : 'Rider dispatch package will be prepared.',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Action Buttons
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
                      widget.onSave(_selectedType, _selectedTable);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String type, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.12) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey.shade700),
              const SizedBox(height: 6),
              Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primary : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
