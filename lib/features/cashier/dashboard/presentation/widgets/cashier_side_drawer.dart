import 'package:flutter/material.dart';

import '../../../menu_management/presentation/pages/cashier_menu_management_page.dart';
import '../../../category_management/presentation/pages/cashier_category_management_page.dart';
import '../../../addon_management/presentation/pages/cashier_addon_management_page.dart';
import '../../../order_report/presentation/pages/cashier_order_report_page.dart';

class CashierSideDrawer extends StatelessWidget {
  const CashierSideDrawer({
    super.key,
    required this.open,
    required this.accent,
    required this.onClose,
  });

  final bool open;
  final Color accent;
  final VoidCallback onClose;

  void _navigateTo(BuildContext context, Widget page) {
    onClose();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: open ? 1 : 0,
      child: IgnorePointer(
        ignoring: !open,
        child: Container(
          color: accent,
          padding: EdgeInsets.fromLTRB(20, topInset + 42, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.20),
              ),
              const SizedBox(height: 10),

              // --- Drawer menu items (secondary features) ---
              _DrawerAction(
                title: 'Menu Management',
                icon: Icons.restaurant_menu_rounded,
                onTap: () => _navigateTo(
                    context, const CashierMenuManagementPage()),
              ),
              _DrawerAction(
                title: 'Category Management',
                icon: Icons.category_rounded,
                onTap: () => _navigateTo(
                    context, const CashierCategoryManagementPage()),
              ),
              _DrawerAction(
                title: 'Addon Management',
                icon: Icons.add_box_outlined,
                onTap: () => _navigateTo(
                    context, const CashierAddonManagementPage()),
              ),
              _DrawerAction(
                title: 'Order Report',
                icon: Icons.assessment_rounded,
                onTap: () => _navigateTo(
                    context, const CashierOrderReportPage()),
              ),

              const Spacer(),

              // --- Sign-out ---
              InkWell(
                onTap: () {
                  onClose();
                  Navigator.of(context).maybePop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        'Sign-out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerAction extends StatelessWidget {
  const _DrawerAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  String _toTwoLineTitle(String value) {
    final firstSpace = value.indexOf(' ');
    if (firstSpace == -1) return value;

    final firstPart = value.substring(0, firstSpace);
    final secondPart = value.substring(firstSpace + 1);
    return '$firstPart\n$secondPart';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _toTwoLineTitle(title),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.white54),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.28),
            ),
          ],
        ),
      ),
    );
  }
}
