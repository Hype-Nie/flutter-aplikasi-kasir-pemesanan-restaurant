import 'package:flutter/material.dart';
import 'package:restaurant/features/auth/login/presentation/widgets/role_tile.dart';

const _accent = Color(0xFFFF4D06);

void showRolePickerSheet(
  BuildContext context, {
  required VoidCallback onCustomer,
  required VoidCallback onCashier,
}) {
  showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D0D0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Login as',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121212)),
          ),
          const SizedBox(height: 18),
          RoleTile(
            icon: Icons.person_outline_rounded,
            label: 'Customer',
            subtitle: 'Browse menu & place orders',
            color: _accent,
            onTap: () {
              Navigator.pop(context);
              onCustomer();
            },
          ),
          const SizedBox(height: 10),
          RoleTile(
            icon: Icons.point_of_sale_rounded,
            label: 'Cashier',
            subtitle: 'Manage orders & transactions',
            color: _accent,
            onTap: () {
              Navigator.pop(context);
              onCashier();
            },
          ),
        ],
      ),
    ),
  );
}
