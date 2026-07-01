import 'package:flutter/material.dart';

class TopSellingSection extends StatelessWidget {
  const TopSellingSection({super.key, required this.accent, required this.items});

  final Color accent;
  final Map<String, int> items;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Text(
                'Top Selling',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121212),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.emoji_events_rounded,
                size: 20,
                color: accent.withValues(alpha: 0.50),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No sales data yet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B8B8B),
                ),
              ),
            )
          else
            ...items.entries.toList().asMap().entries.map((entry) {
              final i = entry.key;
              final name = entry.value.key;
              final count = entry.value.value;
              return Padding(
                padding: EdgeInsets.only(bottom: i < items.length - 1 ? 10 : 0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.restaurant_rounded,
                      size: 18,
                      color: accent.withValues(alpha: 0.40),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF121212),
                        ),
                      ),
                    ),
                    Text(
                      '$count sold',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
