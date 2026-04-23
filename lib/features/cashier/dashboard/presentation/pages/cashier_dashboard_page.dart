import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_dashboard_bloc.dart';
import '../bloc/cashier_dashboard_event.dart';
import '../widgets/cashier_bottom_nav_bar.dart';
import '../widgets/cashier_side_drawer.dart';
import '../widgets/pages/cashier_home_tab.dart';
import '../widgets/pages/cashier_incoming_orders_tab.dart';
import '../widgets/pages/cashier_order_status_tab.dart';
import '../widgets/pages/cashier_order_history_tab.dart';

class CashierDashboardPage extends StatelessWidget {
  const CashierDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CashierDashboardBloc()..add(const CashierDashboardStarted()),
      child: const _CashierDashboardView(),
    );
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
        return const CashierHomeTab();
      case 1:
        return const CashierIncomingOrdersTab();
      case 2:
        return const CashierOrderStatusTab();
      case 3:
        return const CashierOrderHistoryTab();
      default:
        return const CashierHomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: Colors.transparent),
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
                      borderRadius:
                          BorderRadius.circular(_drawerOpen ? 30 : 0),
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
                                        () => _drawerOpen = !_drawerOpen),
                                  ),
                                  Expanded(
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 280),
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

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar({
    required this.title,
    required this.accent,
    required this.onMenuTap,
  });

  final String title;
  final Color accent;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 14, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu_rounded, size: 28, color: Colors.black87),
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
              onPressed: () {},
              icon: Icon(Icons.notifications_none_rounded,
                  size: 24, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
