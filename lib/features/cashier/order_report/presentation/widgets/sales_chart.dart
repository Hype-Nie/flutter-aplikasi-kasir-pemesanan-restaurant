import 'package:flutter/material.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({super.key, required this.accent, required this.revenueByWeekday});

  final Color accent;
  final Map<int, double> revenueByWeekday;

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxRevenue = revenueByWeekday.values.isNotEmpty
        ? revenueByWeekday.values.reduce((a, b) => a > b ? a : b)
        : 1.0;

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
            'Sales Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final wd = i + 1; // Mon=1..Sun=7
                final revenue = revenueByWeekday[wd] ?? 0;
                final fraction = maxRevenue > 0 ? (revenue / maxRevenue) : 0.0;
                final hasMostRevenue = revenue == maxRevenue && revenue > 0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: fraction),
                          duration: Duration(milliseconds: 500 + (i * 100)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Container(
                              height: (100 * value).clamp(2.0, 100.0),
                              decoration: BoxDecoration(
                                color: hasMostRevenue
                                    ? accent
                                    : accent.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[i],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B8B8B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
