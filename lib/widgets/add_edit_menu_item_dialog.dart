import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../theme/app_theme.dart';

class AddEditMenuItemDialog extends StatefulWidget {
  final MenuItem? item;
  final Function(MenuItem item) onSave;

  const AddEditMenuItemDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  State<AddEditMenuItemDialog> createState() => _AddEditMenuItemDialogState();
}

class _AddEditMenuItemDialogState extends State<AddEditMenuItemDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _smallPriceController;
  late TextEditingController _mediumPriceController;
  late TextEditingController _largePriceController;
  late TextEditingController _imageUrlController;

  late String _selectedCategory;
  late bool _isAvailable;

  final List<String> _categories = [
    'Burgers',
    'Pizza',
    'Pasta',
    'Chicken',
    'Rice Meals',
    'Snacks',
    'Desserts',
    'Coffee',
    'Drinks',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _smallPriceController = TextEditingController(
      text: item?.sizePrices['Small']?.toStringAsFixed(0) ?? '90',
    );
    _mediumPriceController = TextEditingController(
      text: item?.sizePrices['Medium']?.toStringAsFixed(0) ??
          (item?.basePrice.toStringAsFixed(0) ?? '120'),
    );
    _largePriceController = TextEditingController(
      text: item?.sizePrices['Large']?.toStringAsFixed(0) ?? '150',
    );
    _imageUrlController = TextEditingController(
      text: item?.imageUrl ??
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
    );

    _selectedCategory = item != null && _categories.contains(item.category)
        ? item.category
        : 'Burgers';
    _isAvailable = item?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _smallPriceController.dispose();
    _mediumPriceController.dispose();
    _largePriceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
                      isEditing ? 'Edit Menu Item' : 'Add Menu Item',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name
                const Text('Food Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _nameController,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                  decoration: InputDecoration(
                    hintText: 'e.g. Classic Cheeseburger',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                // Category
                const Text('Category',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                      value: _selectedCategory,
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCategory = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Price for 3 sizes: Small, Medium, Large
                const Text('Pricing by Size (₱)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _smallPriceController,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                                ? 'Invalid'
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Small',
                          prefixText: '₱ ',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _mediumPriceController,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                                ? 'Invalid'
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Medium',
                          prefixText: '₱ ',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _largePriceController,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || double.tryParse(v) == null
                                ? 'Invalid'
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Large',
                          prefixText: '₱ ',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Image URL
                const Text('Image URL',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                // Availability Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Available in Menu',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Switch(
                      value: _isAvailable,
                      activeTrackColor: AppTheme.success,
                      onChanged: (val) => setState(() => _isAvailable = val),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Actions
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final smallP =
                                double.parse(_smallPriceController.text.trim());
                            final medP =
                                double.parse(_mediumPriceController.text.trim());
                            final largeP =
                                double.parse(_largePriceController.text.trim());

                            final item = MenuItem(
                              id: widget.item?.id ??
                                  'item-${DateTime.now().millisecondsSinceEpoch}',
                              name: _nameController.text.trim(),
                              category: _selectedCategory,
                              basePrice: medP,
                              sizePrices: {
                                'Small': smallP,
                                'Medium': medP,
                                'Large': largeP,
                              },
                              isAvailable: _isAvailable,
                              imageUrl: _imageUrlController.text.trim(),
                            );

                            widget.onSave(item);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(isEditing ? 'Save Changes' : 'Add Item'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
