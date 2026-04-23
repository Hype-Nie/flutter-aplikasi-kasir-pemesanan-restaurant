import 'package:flutter/material.dart';

class CustomerOrderHistoryDetailPage extends StatelessWidget {
  final Map<String, String> order;
  const CustomerOrderHistoryDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    final statusColor = order['status'] == 'Completed' ? Colors.green : (order['status'] == 'Pending' ? Colors.orange : Colors.red);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order ${order['id']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildRow('Status', order['status']!, valueColor: statusColor, isBold: true),
                  const Divider(height: 32),
                  _buildRow('Order Date', order['date']!),
                  const Divider(height: 32),
                  _buildRow('Order ID', order['id']!),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Items', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildItem('Veggie tomato mix', '1', 'N1,900'),
                  const Divider(height: 24),
                  _buildItem('Fishwith mix orange', '1', 'N1,900'),
                  const Divider(height: 24),
                  _buildItem('Extra Sauce', '1', 'N500'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Payment Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildRow('Payment Method', 'Card'),
                  const Divider(height: 32),
                  _buildRow('Delivery Method', 'Door delivery'),
                  const Divider(height: 32),
                  _buildRow('Total', order['total']!, isBold: true, valueColor: accent, fontSize: 18),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 64,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
                child: const Text('Re-order', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor, bool isBold = false, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor ?? Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize)),
      ],
    );
  }

  Widget _buildItem(String name, String qty, String price) {
    return Row(
      children: [
        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
        Text('x$qty', style: const TextStyle(color: Colors.black54)),
        const SizedBox(width: 16),
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
