import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/core/utils/report_printer.dart';

import '../riverpod/cashier_order_report_provider.dart';
import '../widgets/revenue_card.dart';
import '../widgets/mini_report_card.dart';
import '../widgets/sales_chart.dart';
import '../widgets/top_selling_section.dart';
import '../widgets/payment_breakdown.dart';

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
                            child: RevenueCard(
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
                                  child: MiniReportCard(
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
                                  child: MiniReportCard(
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
                                  child: MiniReportCard(
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
                                  child: MiniReportCard(
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
                            child: SalesChart(
                              accent: _accent,
                              revenueByWeekday: s.revenueByWeekday,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // --- Top selling ---
                          _buildAnimatedCard(
                            delay: 0.55,
                            child: TopSellingSection(
                              accent: _accent,
                              items: s.topSellingItems,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // --- Payment method breakdown ---
                          _buildAnimatedCard(
                            delay: 0.65,
                            child: PaymentBreakdown(
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

