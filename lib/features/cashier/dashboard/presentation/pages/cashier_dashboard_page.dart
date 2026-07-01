import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/cashier_dashboard_provider.dart';
import '../widgets/cashier_bottom_nav_bar.dart';
import '../widgets/cashier_side_drawer.dart';
import '../widgets/pages/cashier_home_tab.dart';
import '../widgets/pages/cashier_incoming_orders_tab.dart';
import '../widgets/pages/cashier_order_status_tab.dart';
import '../widgets/pages/cashier_order_history_tab.dart';

class CashierDashboardPage extends ConsumerStatefulWidget {
  const CashierDashboardPage({super.key});

  @override
  ConsumerState<CashierDashboardPage> createState() =>
      _CashierDashboardPageState();
}

class _CashierDashboardPageState extends ConsumerState<CashierDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cashierDashboardProvider.notifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(cashierDashboardProvider);
    return const _CashierDashboardView();
  }
}

class _CashierDashboardView extends StatefulWidget {
  const _CashierDashboardView();

  @override
  State<_CashierDashboardView> createState() => _CashierDashboardViewState();
}

class _CashierDashboardViewState extends State<_CashierDashboardView> {
  int _selectedBottomNav = 0;
  bool _drawerOpen = false;

  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  final _tabLabels = const ['Home', 'Incoming', 'Status', 'History'];

  Widget _buildCurrentTab() {
    switch (_selectedBottomNav) {
      case 0:
        return CashierHomeTab(
          onSwitchTab: (i) => setState(() => _selectedBottomNav = i),
        );
      case 1:
        return const CashierIncomingOrdersTab();
      case 2:
        return const CashierOrderStatusTab();
      case 3:
        return const CashierOrderHistoryTab();
      default:
        return CashierHomeTab(
          onSwitchTab: (i) => setState(() => _selectedBottomNav = i),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final shiftX = constraints.maxWidth * 0.36;
            return Stack(
              children: [
                // --- Side Drawer ---
                CashierSideDrawer(
                  open: _drawerOpen,
                  accent: _accent,
                  onClose: () => setState(() => _drawerOpen = false),
                ),

                // --- Main content with drawer shift animation ---
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  top: _drawerOpen ? 42 : 0,
                  bottom: _drawerOpen ? 42 : 0,
                  left: _drawerOpen ? shiftX : 0,
                  right: _drawerOpen ? -shiftX : 0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    scale: _drawerOpen ? 0.86 : 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_drawerOpen ? 30 : 0),
                      child: ColoredBox(
                        color: _bg,
                        child: SafeArea(
                          child: Stack(
                            children: [
                              // --- Tab body ---
                              Column(
                                children: [
                                  _DashboardTopBar(
                                    title: _tabLabels[_selectedBottomNav],
                                    accent: _accent,
                                    onMenuTap: () => setState(
                                      () => _drawerOpen = !_drawerOpen,
                                    ),
                                    onSwitchTab: (i) => setState(
                                      () => _selectedBottomNav = i,
                                    ),
                                  ),
                                  Expanded(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      child: _buildCurrentTab(),
                                    ),
                                  ),
                                  // Space for bottom nav
                                  const SizedBox(height: 72),
                                ],
                              ),

                              // --- Bottom nav ---
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: CashierBottomNavBar(
                                  selectedIndex: _selectedBottomNav,
                                  accent: _accent,
                                  onSelect: (i) =>
                                      setState(() => _selectedBottomNav = i),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------- Top bar ----------

class _DashboardTopBar extends ConsumerWidget {
  const _DashboardTopBar({
    required this.title,
    required this.accent,
    required this.onMenuTap,
    required this.onSwitchTab,
  });

  final String title;
  final Color accent;
  final VoidCallback onMenuTap;
  final void Function(int tabIndex) onSwitchTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashierDashboardProvider);
    final alerts = [
      ...state.pendingOrders,
      ...state.cancelledOrders,
    ];
    // Sort newest first
    alerts.sort((a, b) {
      final aDate = a.createdAt ?? a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    final badgeCount = alerts.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 14, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(
              Icons.menu_rounded,
              size: 28,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121212),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _showNotificationSheet(context, alerts),
              icon: badgeCount > 0
                  ? Badge(
                      label: Text(badgeCount.toString()),
                      backgroundColor: const Color(0xFFE74C3C),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 24,
                        color: accent,
                      ),
                    )
                  : Icon(
                      Icons.notifications_none_rounded,
                      size: 24,
                      color: accent,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationSheet(BuildContext context, List<dynamic> alerts) {
    if (alerts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No new notifications')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    alerts.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  final isPending = alert.status == 'pending';
                  final titleStr = isPending ? 'New Incoming Order!' : 'Order Cancelled';
                  final subtitleStr = isPending 
                      ? 'Order ${alert.orderNumber} is waiting for your approval.'
                      : 'Order ${alert.orderNumber} has been cancelled.';
                  final iconColor = isPending ? const Color(0xFFF39C12) : const Color(0xFFE74C3C);
                  final iconData = isPending ? Icons.add_shopping_cart_rounded : Icons.cancel_outlined;

                  final orderTime = alert.createdAt ?? alert.updatedAt;
                  final timeStr = orderTime != null
                      ? '${orderTime.toLocal().hour.toString().padLeft(2, '0')}:${orderTime.toLocal().minute.toString().padLeft(2, '0')}'
                      : '';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: iconColor, size: 20),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          titleStr,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          timeStr,
                          style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitleStr,
                        style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 13),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      // Switch to Incoming (1) if pending, else History (3)
                      onSwitchTab(isPending ? 1 : 3);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
