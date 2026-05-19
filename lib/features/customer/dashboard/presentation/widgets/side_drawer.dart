import 'package:flutter/material.dart';
import 'package:restaurant/core/utils/helpers.dart';
import 'package:restaurant/features/auth/logout/presentation/pages/auth_logout_page.dart';
import 'package:restaurant/features/customer/order_history/presentation/pages/customer_order_history_page.dart';
import 'package:restaurant/features/customer/profile/presentation/pages/customer_profile_page.dart';
import 'package:restaurant/shared/pages/no_internet_page.dart';

import '../pages/customer_offers_page.dart';

class SideDrawer extends StatelessWidget {
  final bool open;
  final VoidCallback onClose;

  const SideDrawer({super.key, required this.open, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: open ? 1 : 0,
      child: IgnorePointer(
        ignoring: !open,
        child: Container(
          color: const Color(0xFFFF4D06),
          padding: EdgeInsets.fromLTRB(20, topInset + 42, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              DrawerAction(
                title: 'Profile',
                icon: Icons.person_outline_rounded,
                onTap: () => _push(context, const CustomerProfilePage()),
              ),
              DrawerAction(
                title: 'orders',
                icon: Icons.sync_alt_rounded,
                onTap: () => _push(context, const CustomerOrderHistoryPage()),
              ),
              DrawerAction(
                title: 'offer and promo',
                icon: Icons.local_offer_outlined,
                onTap: () => _push(context, const CustomerOffersPage()),
              ),
              DrawerAction(
                title: 'Privacy policy',
                icon: Icons.chat_bubble_outline_rounded,
              ),
              DrawerAction(
                title: 'Security',
                icon: Icons.shield_outlined,
                onTap: () => _push(context, const NoInternetPage()),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  onClose();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthLogoutPage()),
                  );
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

  void _push(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

class DrawerAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const DrawerAction({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          onTap ??
          () => AppHelpers.showSnackBar(context, '$title tapped'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.28)),
          ],
        ),
      ),
    );
  }
}
