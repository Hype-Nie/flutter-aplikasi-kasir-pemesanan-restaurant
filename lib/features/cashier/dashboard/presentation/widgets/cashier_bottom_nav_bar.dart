import 'package:flutter/material.dart';

class CashierBottomNavBar extends StatelessWidget {
  const CashierBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.accent,
    required this.onSelect,
  });

  final int selectedIndex;
  final Color accent;
  final ValueChanged<int> onSelect;

  static const _items = <_NavDef>[
    _NavDef(icon: Icons.dashboard_rounded, label: 'Home'),
    _NavDef(icon: Icons.receipt_long_rounded, label: 'Incoming'),
    _NavDef(icon: Icons.sync_alt_rounded, label: 'Status'),
    _NavDef(icon: Icons.history_rounded, label: 'History'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final active = i == selectedIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? accent.withValues(alpha: 0.10) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.30),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      _items[i].icon,
                      color: active ? accent : const Color(0xFFA8A8A8),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _items[i].label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? accent : const Color(0xFFA8A8A8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavDef {
  const _NavDef({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
