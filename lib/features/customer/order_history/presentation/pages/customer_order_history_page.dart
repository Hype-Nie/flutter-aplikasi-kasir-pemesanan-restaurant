import 'package:flutter/material.dart';
import 'customer_order_history_detail_page.dart';

class CustomerOrderHistoryPage extends StatelessWidget {
  const CustomerOrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    final orders = [
      {'id': '#1234', 'date': '20 Apr 2026', 'total': 'N5,700', 'status': 'Completed', 'items': '3 items'},
      {'id': '#1233', 'date': '18 Apr 2026', 'total': 'N1,900', 'status': 'Pending', 'items': '1 item'},
      {'id': '#1230', 'date': '15 Apr 2026', 'total': 'N8,400', 'status': 'Cancelled', 'items': '4 items'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('History', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: orders.isEmpty 
      ? _buildEmptyState(context, accent)
      : ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            final order = orders[i];
            final statusColor = order['status'] == 'Completed' ? Colors.green : (order['status'] == 'Pending' ? Colors.orange : Colors.red);
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerOrderHistoryDetailPage(order: order))),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Row(
                  children: [
                    Container(width: 50, height: 50, decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long_outlined, color: accent)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('${order['items']} • ${order['date']}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(order['total']!, style: const TextStyle(fontWeight: FontWeight.bold, color: accent)),
                        const SizedBox(height: 4),
                        Text(order['status']!, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 100, color: Color(0xFFC7C7C7)),
            const SizedBox(height: 24),
            const Text('No history yet', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black)),
            const SizedBox(height: 12),
            const Text('Hit the orange button down\nbelow to Create an order', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 64,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0), child: const Text('Start ordering', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600))),
            ),
          ],
        ),
      ),
    );
  }
}
