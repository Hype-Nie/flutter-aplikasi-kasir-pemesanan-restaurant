import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_order_report_bloc.dart';
import '../bloc/cashier_order_report_event.dart';

class CashierOrderReportPage extends StatelessWidget {
  const CashierOrderReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CashierOrderReportBloc()..add(const CashierOrderReportStarted()),
      child: const _CashierOrderReportView(),
    );
  }
}

class _CashierOrderReportView extends StatefulWidget {
  const _CashierOrderReportView();

  @override
  State<_CashierOrderReportView> createState() =>
      _CashierOrderReportViewState();
}

class _CashierOrderReportViewState extends State<_CashierOrderReportView>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  late final AnimationController _animCtrl;
  int _selectedPeriod = 0;

  final _periods = const ['Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  // --- Period selector ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: List.generate(_periods.length, (i) {
                        final active = i == _selectedPeriod;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedPeriod = i);
                              _animCtrl
                                ..reset()
                                ..forward();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    active ? _accent : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _periods[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFF8B8B8B),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // --- Revenue card ---
                  _buildAnimatedCard(
                    delay: 0.0,
                    child: _RevenueCard(accent: _accent),
                  ),
                  const SizedBox(height: 14),

                  // --- Stats row ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnimatedCard(
                          delay: 0.15,
                          child: _MiniReportCard(
                            icon: Icons.receipt_long_rounded,
                            label: 'Total Orders',
                            value: '—',
                            color: _accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAnimatedCard(
                          delay: 0.25,
                          child: _MiniReportCard(
                            icon: Icons.people_rounded,
                            label: 'Customers',
                            value: '—',
                            color: const Color(0xFF3498DB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnimatedCard(
                          delay: 0.30,
                          child: _MiniReportCard(
                            icon: Icons.check_circle_rounded,
                            label: 'Completed',
                            value: '—',
                            color: const Color(0xFF2ECC71),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAnimatedCard(
                          delay: 0.40,
                          child: _MiniReportCard(
                            icon: Icons.cancel_rounded,
                            label: 'Cancelled',
                            value: '—',
                            color: const Color(0xFFE74C3C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // --- Chart placeholder ---
                  _buildAnimatedCard(
                    delay: 0.45,
                    child: _ChartPlaceholder(accent: _accent),
                  ),
                  const SizedBox(height: 22),

                  // --- Top selling ---
                  _buildAnimatedCard(
                    delay: 0.55,
                    child: _TopSellingSection(accent: _accent),
                  ),

                  const SizedBox(height: 22),

                  // --- Payment method breakdown ---
                  _buildAnimatedCard(
                    delay: 0.65,
                    child: _PaymentBreakdown(accent: _accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required double delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, __) {
        final curved = CurvedAnimation(
          parent: _animCtrl,
          curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
        );
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - curved.value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 14, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          const Text(
            'Order Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121212),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.download_rounded, size: 22, color: _accent),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Revenue Card ----------

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withValues(alpha: 0.80)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Total Revenue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            '—',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '— vs previous period',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Mini Report Card ----------

class _MiniReportCard extends StatelessWidget {
  const _MiniReportCard({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF121212))),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B8B8B))),
        ],
      ),
    );
  }
}

// ---------- Chart Placeholder ----------

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales Overview',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121212))),
          const SizedBox(height: 18),
          // Simulated bar chart
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final heights = [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.3];
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: heights[i]),
                          duration:
                              Duration(milliseconds: 500 + (i * 100)),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, __) {
                            return Container(
                              height: 100 * value,
                              decoration: BoxDecoration(
                                color: i == 3
                                    ? accent
                                    : accent.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(days[i],
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B8B8B))),
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

// ---------- Top Selling ----------

class _TopSellingSection extends StatelessWidget {
  const _TopSellingSection({required this.accent});

  final Color accent;

  static const _items = [
    ('Nasi Goreng', '— sold', Icons.restaurant_rounded),
    ('Ayam Geprek', '— sold', Icons.restaurant_rounded),
    ('Es Teh Manis', '— sold', Icons.local_cafe_rounded),
    ('Mie Ayam', '— sold', Icons.restaurant_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Top Selling',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121212))),
              const Spacer(),
              Icon(Icons.emoji_events_rounded,
                  size: 20, color: accent.withValues(alpha: 0.50)),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(_items.length, (i) {
            final item = _items[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < _items.length - 1 ? 10 : 0),
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
                            color: accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(item.$3,
                      size: 18, color: accent.withValues(alpha: 0.40)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.$1,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF121212))),
                  ),
                  Text(item.$2,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8B8B8B))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------- Payment Breakdown ----------

class _PaymentBreakdown extends StatelessWidget {
  const _PaymentBreakdown({required this.accent});

  final Color accent;

  static const _methods = [
    ('Cash', Color(0xFF2ECC71), 0.55),
    ('QRIS', Color(0xFF3498DB), 0.30),
    ('Transfer', Color(0xFF9B59B6), 0.15),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Methods',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121212))),
          const SizedBox(height: 16),
          // Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: _methods.map((m) {
                  return Expanded(
                    flex: (m.$3 * 100).toInt(),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => FractionallySizedBox(
                        widthFactor: v,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          color: m.$2,
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
          ...List.generate(_methods.length, (i) {
            final m = _methods[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: m.$2,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(m.$1,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF121212))),
                  const Spacer(),
                  Text('${(m.$3 * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8B8B8B))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
