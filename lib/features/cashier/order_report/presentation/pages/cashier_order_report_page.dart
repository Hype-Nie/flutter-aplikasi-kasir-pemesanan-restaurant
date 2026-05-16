import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/shared/models/order.dart';
import 'package:restaurant/core/utils/report_printer.dart';
import '../riverpod/cashier_order_report_provider.dart';

class CashierOrderReportPage extends ConsumerStatefulWidget {
  const CashierOrderReportPage({super.key});

  @override
  ConsumerState<CashierOrderReportPage> createState() =>
      _CashierOrderReportPageState();
}

class _CashierOrderReportPageState
    extends ConsumerState<CashierOrderReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cashierOrderReportProvider.notifier).fetchReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierOrderReportProvider);
    return _CashierOrderReportView(
      state: state,
      onRefresh: () =>
          ref.read(cashierOrderReportProvider.notifier).fetchReport(),
      onDateFilter: (start, end) =>
          ref.read(cashierOrderReportProvider.notifier).setDateRange(start, end),
    );
  }
}

class _CashierOrderReportView extends StatefulWidget {
  const _CashierOrderReportView({
    required this.state,
    required this.onRefresh,
    required this.onDateFilter,
  });

  final CashierOrderReportState state;
  final Future<void> Function() onRefresh;
  final void Function(DateTime?, DateTime?) onDateFilter;

  @override
  State<_CashierOrderReportView> createState() =>
      _CashierOrderReportViewState();
}

class _CashierOrderReportViewState extends State<_CashierOrderReportView>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _CashierOrderReportView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.status != widget.state.status &&
        widget.state.status == CashierOrderReportStatus.success) {
      _animCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final isLoading = s.status == CashierOrderReportStatus.loading;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: RefreshIndicator(
                color: _accent,
                onRefresh: widget.onRefresh,
                child: isLoading && s.orders.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 220),
                          const Center(
                            child: CircularProgressIndicator(color: _accent),
                          ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                        children: [
                          // --- Revenue card ---
                          _buildAnimatedCard(
                            delay: 0.0,
                            child: _RevenueCard(
                              accent: _accent,
                              revenue: _formatPrice(s.totalRevenue),
                              orderCount: s.completedOrders.length,
                            ),
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
                                    value: '${s.orders.length}',
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
                                    value:
                                        '${s.orders.map((o) => o.userId).toSet().length}',
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
                                    value: '${s.completedOrders.length}',
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
                                    value: '${s.cancelledOrders.length}',
                                    color: const Color(0xFFE74C3C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // --- Sales chart ---
                          _buildAnimatedCard(
                            delay: 0.45,
                            child: _SalesChart(
                              accent: _accent,
                              revenueByWeekday: s.revenueByWeekday,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // --- Top selling ---
                          _buildAnimatedCard(
                            delay: 0.55,
                            child: _TopSellingSection(
                              accent: _accent,
                              items: s.topSellingItems,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // --- Payment method breakdown ---
                          _buildAnimatedCard(
                            delay: 0.65,
                            child: _PaymentBreakdown(
                              accent: _accent,
                              orders: s.completedOrders,
                            ),
                          ),
                        ],
                      ),
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
      builder: (context, _) {
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.black87,
            ),
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
              onPressed: () async {
                final currentStart = widget.state.startDate ?? DateTime.now().subtract(const Duration(days: 30));
                final currentEnd = widget.state.endDate ?? DateTime.now();
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(start: currentStart, end: currentEnd),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: _accent,
                          onPrimary: Colors.white,
                          onSurface: Color(0xFF121212),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (range != null) {
                  widget.onDateFilter(range.start, range.end);
                }
              },
              icon: Icon(Icons.date_range_rounded, size: 22, color: _accent),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => ReportPrinter.printReport(context, widget.state),
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
  const _RevenueCard({
    required this.accent,
    required this.revenue,
    required this.orderCount,
  });

  final Color accent;
  final String revenue;
  final int orderCount;

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
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 22,
                ),
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
          Text(
            revenue,
            style: const TextStyle(
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
            child: Text(
              '$orderCount completed orders',
              style: const TextStyle(
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
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8B8B8B),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Sales Chart ----------

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.accent, required this.revenueByWeekday});

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

// ---------- Top Selling ----------

class _TopSellingSection extends StatelessWidget {
  const _TopSellingSection({required this.accent, required this.items});

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

// ---------- Payment Breakdown ----------

class _PaymentBreakdown extends StatelessWidget {
  const _PaymentBreakdown({required this.accent, required this.orders});

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
