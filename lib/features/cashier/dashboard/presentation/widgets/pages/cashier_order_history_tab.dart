import 'package:flutter/material.dart';

/// Order History tab – past completed / cancelled orders.
/// Template only; real data will be connected later.
class CashierOrderHistoryTab extends StatelessWidget {
  const CashierOrderHistoryTab({super.key});

  static const _accent = Color(0xFFFF4D06);

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('history'),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      children: [
        // --- Date filter ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Icon(Icons.calendar_today_rounded,
                  size: 18, color: _accent),
              const SizedBox(width: 10),
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF121212),
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_drop_down_rounded,
                  size: 24, color: _accent),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // --- History summary ---
        Row(
          children: [
            _MiniStat(label: 'Total', value: '—', color: _accent),
            const SizedBox(width: 10),
            _MiniStat(
              label: 'Completed',
              value: '—',
              color: const Color(0xFF2ECC71),
            ),
            const SizedBox(width: 10),
            _MiniStat(
              label: 'Cancelled',
              value: '—',
              color: const Color(0xFFE74C3C),
            ),
          ],
        ),
        const SizedBox(height: 22),

        const Text(
          'Order List',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 12),

        // --- Order history tiles ---
        ...List.generate(6, (i) => _HistoryTile(index: i)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.index});

  final int index;

  static const _statuses = [
    'Completed',
    'Completed',
    'Cancelled',
    'Completed',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final status = _statuses[index % _statuses.length];
    final isCompleted = status == 'Completed';
    final color =
        isCompleted ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);

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
            child: Icon(
              isCompleted
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${4000 + index}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '— items · —',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
