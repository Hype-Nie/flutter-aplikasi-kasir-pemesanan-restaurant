import 'package:flutter/material.dart';

/// Home tab – dashboard overview with summary cards and recent activity.
/// Data is template / placeholder; real data will be connected later.
class CashierHomeTab extends StatelessWidget {
  const CashierHomeTab({super.key});

  static const _accent = Color(0xFFFF4D06);

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      children: [
        // --- Greeting ---
        const Text(
          'Good morning,',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B8B8B),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Cashier 👋',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 22),

        // --- Summary cards row ---
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.receipt_long_rounded,
                label: 'Total Orders',
                value: '—',
                color: _accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.attach_money_rounded,
                label: 'Revenue',
                value: '—',
                color: const Color(0xFF2ECC71),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.pending_actions_rounded,
                label: 'Pending',
                value: '—',
                color: const Color(0xFFF39C12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.check_circle_outline_rounded,
                label: 'Completed',
                value: '—',
                color: const Color(0xFF3498DB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // --- Recent orders section ---
        Row(
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121212),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: _accent),
              child: const Text(
                'See all',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // --- Placeholder order list ---
        ...List.generate(4, (i) => _RecentOrderTile(index: i)),

        const SizedBox(height: 18),

        // --- Quick actions ---
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _QuickActionChip(
              icon: Icons.add_circle_outline_rounded,
              label: 'New Order',
              color: _accent,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _QuickActionChip(
              icon: Icons.print_rounded,
              label: 'Print Receipt',
              color: const Color(0xFF3498DB),
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _QuickActionChip(
              icon: Icons.assessment_rounded,
              label: 'Report',
              color: const Color(0xFF2ECC71),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

// ---------- Summary card ----------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8B8B8B),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Recent order tile ----------

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.index});

  final int index;

  static const _statuses = ['Pending', 'Preparing', 'Ready', 'Completed'];
  static const _statusColors = [
    Color(0xFFF39C12),
    Color(0xFF3498DB),
    Color(0xFF2ECC71),
    Color(0xFF8B8B8B),
  ];

  @override
  Widget build(BuildContext context) {
    final status = _statuses[index % _statuses.length];
    final color = _statusColors[index % _statusColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#${index + 1}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${1000 + index}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Table ${index + 1} · — items',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Quick action chip ----------

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.20)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
