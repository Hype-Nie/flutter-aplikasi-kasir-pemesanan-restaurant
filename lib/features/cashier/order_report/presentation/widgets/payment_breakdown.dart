import 'package:flutter/material.dart';
import 'package:restaurant/shared/models/order.dart';

class PaymentBreakdown extends StatelessWidget {
  const PaymentBreakdown({super.key, required this.accent, required this.orders});

  final Color accent;
  final List<Order> orders;

  static const _methodColors = {
    'cash': Color(0xFF2ECC71),
    'qris': Color(0xFF3498DB),
    'transfer': Color(0xFF9B59B6),
  };

  @override
  Widget build(BuildContext context) {
    // Count payment methods from actual data
    final counts = <String, int>{};
    for (final o in orders) {
      final pm = o.paymentMethod.toLowerCase();
      counts[pm] = (counts[pm] ?? 0) + 1;
    }
    final total = counts.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 16),
          if (counts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No payment data yet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B8B8B),
                ),
              ),
            )
          else ...[
            // Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: counts.entries.map((e) {
                    final color = _methodColors[e.key] ?? accent;
                    final flex = total > 0 ? (e.value * 100 ~/ total) : 1;
                    return Expanded(
                      flex: flex.clamp(1, 100),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, child) => FractionallySizedBox(
                          widthFactor: v,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            color: color,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...counts.entries.map((e) {
              final color = _methodColors[e.key] ?? accent;
              final pct = total > 0
                  ? (e.value * 100 / total).toStringAsFixed(0)
                  : '0';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      e.key[0].toUpperCase() + e.key.substring(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121212),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
