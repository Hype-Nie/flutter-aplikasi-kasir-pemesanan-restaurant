import 'package:flutter/material.dart';

/// Order Status tab – track and update the status of active orders.
/// Template only; real data will be connected later.
class CashierOrderStatusTab extends StatelessWidget {
  const CashierOrderStatusTab({super.key});

  static const _statusLabels = ['Preparing', 'Ready', 'Served'];
  static const _statusColors = [
    Color(0xFFF39C12),
    Color(0xFF2ECC71),
    Color(0xFF3498DB),
  ];
  static const _statusIcons = [
    Icons.outdoor_grill_rounded,
    Icons.check_circle_rounded,
    Icons.room_service_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('status'),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      children: [
        // --- Status summary row ---
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _statusLabels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              return Container(
                width: 110,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _statusColors[i].withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _statusColors[i].withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_statusIcons[i], color: _statusColors[i], size: 22),
                    const Spacer(),
                    Text(
                      _statusLabels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _statusColors[i],
                      ),
                    ),
                    Text(
                      '— orders',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _statusColors[i].withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),

        // --- Active orders list ---
        const Text(
          'Active Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(5, (i) => _OrderStatusCard(index: i)),
      ],
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({required this.index});

  final int index;

  static const _accent = Color(0xFFFF4D06);
  static const _statuses = ['Preparing', 'Ready', 'Preparing', 'Served', 'Ready'];
  static const _colors = [
    Color(0xFFF39C12),
    Color(0xFF2ECC71),
    Color(0xFFF39C12),
    Color(0xFF3498DB),
    Color(0xFF2ECC71),
  ];

  @override
  Widget build(BuildContext context) {
    final status = _statuses[index % _statuses.length];
    final color = _colors[index % _colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
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
                      'Order #${3000 + index}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121212),
                      ),
                    ),
                    const SizedBox(height: 2),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
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
          const SizedBox(height: 12),

          // --- Progress indicator ---
          _OrderProgress(status: status),

          const SizedBox(height: 12),

          // --- Update button ---
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _accent.withValues(alpha: 0.10),
                foregroundColor: _accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Update Status',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderProgress extends StatelessWidget {
  const _OrderProgress({required this.status});

  final String status;

  int get _step {
    switch (status) {
      case 'Preparing':
        return 1;
      case 'Ready':
        return 2;
      case 'Served':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Accepted', 'Preparing', 'Ready', 'Served'];
    return Row(
      children: List.generate(labels.length, (i) {
        final done = i < _step;
        final current = i == _step;
        final color = done || current
            ? const Color(0xFF2ECC71)
            : const Color(0xFFD0D0D0);
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? color : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check, size: 8, color: Colors.white)
                    : null,
              ),
              if (i < labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFFD0D0D0),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
