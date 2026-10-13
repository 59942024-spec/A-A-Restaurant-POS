import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToMenu;

  const OwnerDashboardScreen({
    super.key,
    required this.onNavigateToMenu,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
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

  String _formatFullDate(DateTime dt) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _weekRangeString(DateTime dt) {
    final todayStart = DateTime(dt.year, dt.month, dt.day);
    final monday = todayStart.subtract(Duration(days: dt.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[monday.month - 1]} ${monday.day} – ${months[sunday.month - 1]} ${sunday.day}, ${sunday.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayString = _formatFullDate(now);
    final weeklySales = _appState.weeklySalesByDay;
    final totalWeekSales = _appState.thisWeekSales;

    // Find highest day sales for scaling bar chart heights
    double maxDaySales = 0.0;
    weeklySales.forEach((_, val) {
      if (val > maxDaySales) maxDaySales = val;
    });
    if (maxDaySales == 0.0) maxDaySales = 100.0; // Baseline scale when 0

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Dynamic Date & Welcome
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome, Owner!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              todayString,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Administrator Portal • enchang • ${_appState.restaurantName}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Manage Menu'),
                    onPressed: widget.onNavigateToMenu,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // TODAY'S OVERVIEW HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Overview (Today Only)",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Live Day Stats',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Metric Cards (TODAY ONLY)
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.8,
                children: [
                  _buildStatCard(
                    title: "Today's Sales",
                    value: '₱${_appState.todaySales.toStringAsFixed(2)}',
                    icon: Icons.payments_outlined,
                    color: AppTheme.primary,
                  ),
                  _buildStatCard(
                    title: "Today's Orders",
                    value: '${_appState.todayOrdersCount}',
                    icon: Icons.receipt_long_outlined,
                    color: Colors.blue.shade700,
                  ),
                  _buildStatCard(
                    title: 'Completed Orders',
                    value: '${_appState.todayCompletedCount}',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.success,
                  ),
                  _buildStatCard(
                    title: 'Pending Orders',
                    value: '${_appState.todayPendingCount}',
                    icon: Icons.hourglass_empty,
                    color: AppTheme.warning,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 2 Inventory Cards (Available vs Out of Stock)
          Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_box_outlined, color: AppTheme.success, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Available Menu Items', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              '${_appState.availableItemsCount}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.success),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.block, color: AppTheme.danger, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Out of Stock Items', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              '${_appState.outOfStockCount}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.danger),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SALES THIS WEEK CARD (Dynamic & Real)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sales This Week',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _weekRangeString(now),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Total: ₱${totalWeekSales.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  if (totalWeekSales == 0.0) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            'Newly initialized session. Sales This Week = ₱0.00. Live sales will chart below as POS transactions are made.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Dynamic Pure Flutter Bar Chart
                  SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildChartBar('Mon', weeklySales['Mon'] ?? 0.0, maxDaySales, now.weekday == 1),
                        _buildChartBar('Tue', weeklySales['Tue'] ?? 0.0, maxDaySales, now.weekday == 2),
                        _buildChartBar('Wed', weeklySales['Wed'] ?? 0.0, maxDaySales, now.weekday == 3),
                        _buildChartBar('Thu', weeklySales['Thu'] ?? 0.0, maxDaySales, now.weekday == 4),
                        _buildChartBar('Fri', weeklySales['Fri'] ?? 0.0, maxDaySales, now.weekday == 5),
                        _buildChartBar('Sat', weeklySales['Sat'] ?? 0.0, maxDaySales, now.weekday == 6),
                        _buildChartBar('Sun', weeklySales['Sun'] ?? 0.0, maxDaySales, now.weekday == 7),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String day, double amount, double maxScale, bool isToday) {
    final factor = maxScale > 0 ? (amount / maxScale).clamp(0.05, 1.0) : 0.05;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              amount > 0 ? '₱${amount.toStringAsFixed(0)}' : '₱0',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? AppTheme.primary : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 120 * factor,
              decoration: BoxDecoration(
                color: isToday
                    ? AppTheme.primary
                    : (amount > 0 ? Colors.blue.shade400 : Colors.grey.shade300),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: isToday
                  ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                  : EdgeInsets.zero,
              decoration: isToday
                  ? BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isToday ? AppTheme.primary : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
