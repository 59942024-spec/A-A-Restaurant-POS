import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../models/menu_item.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_edit_menu_item_dialog.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final AppState _appState = AppState();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
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
    _appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  List<MenuItem> get _filteredItems {
    return _appState.menuItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openAddEditDialog([MenuItem? item]) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditMenuItemDialog(
        item: item,
        onSave: (savedItem) {
          if (item == null) {
            _appState.addMenuItem(savedItem);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added "${savedItem.name}" to menu!')),
            );
          } else {
            _appState.updateMenuItem(savedItem);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Updated "${savedItem.name}"!')),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(MenuItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Menu Item?'),
        content: Text('Are you sure you want to remove "${item.name}" from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              _appState.deleteMenuItem(item.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed "${item.name}" from menu.')),
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
    final items = _filteredItems;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Title & "+ Add Menu Item" Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menu Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add, update, or adjust menu availability in real time',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Menu Item'),
                  onPressed: () => _openAddEditDialog(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar & Filter Pills
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Table / List of Menu Items
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'No menu items found.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.orange.shade50,
                                  child: const Icon(Icons.fastfood, color: AppTheme.primary),
                                ),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text(
                              '${item.category} • Base: ₱${item.basePrice.toStringAsFixed(0)} (${item.sizePrices.entries.map((e) => "${e.key}: ₱${e.value.toInt()}").join(", ")})',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Availability Badge & Switch
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: item.isAvailable ? Colors.green.shade300 : Colors.red.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    item.isAvailable ? 'Available' : 'Not Available',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: item.isAvailable ? AppTheme.success : AppTheme.danger,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: item.isAvailable,
                                  activeTrackColor: AppTheme.success,
                                  onChanged: (val) {
                                    _appState.toggleItemAvailability(item.id);
                                  },
                                ),
                                const SizedBox(width: 8),

                                // Edit Button
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  tooltip: 'Edit Item',
                                  onPressed: () => _openAddEditDialog(item),
                                ),

                                // Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Delete Item',
                                  onPressed: () => _confirmDelete(item),
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
