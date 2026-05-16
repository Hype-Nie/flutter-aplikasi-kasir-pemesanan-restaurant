import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/order_history/presentation/pages/customer_order_history_page.dart';
import 'package:restaurant/features/customer/profile/presentation/pages/customer_profile_page.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const BottomNavBar({super.key, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 0),
      child: SizedBox(
        height: 72,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          BottomNavIcon(icon: Icons.home_rounded, active: selectedIndex == 0, onTap: () => onSelect(0)),
          BottomNavIcon(
            icon: Icons.person_outline_rounded, active: selectedIndex == 1,
            onTap: () async {
              onSelect(1);
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfilePage()));
              onSelect(0);
            },
          ),
          BottomNavIcon(
            icon: Icons.history_rounded, active: selectedIndex == 2,
            onTap: () async {
              onSelect(2);
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerOrderHistoryPage()));
              onSelect(0);
            },
          ),
        ]),
      ),
    );
  }
}

class BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const BottomNavIcon({super.key, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: active
              ? const [BoxShadow(color: Color(0x44FF4D06), blurRadius: 16, blurStyle: BlurStyle.normal, offset: Offset(0, 4))]
              : const [],
        ),
        child: Icon(icon, color: active ? const Color(0xFFFF4D06) : const Color(0xFFA8A8A8), size: 26),
      ),
    );
  }
}
