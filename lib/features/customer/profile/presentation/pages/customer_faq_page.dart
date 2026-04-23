import 'package:flutter/material.dart';

class CustomerFaqPage extends StatelessWidget {
  const CustomerFaqPage({super.key});
  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    final faqs = [
      {'q': 'How to order?', 'a': 'Choose your menu, add to cart, and complete the order.'},
      {'q': 'Payment methods?', 'a': 'We support cash, credit cards, and digital wallets.'},
      {'q': 'Delivery time?', 'a': 'Usually within 30-45 minutes depending on location.'},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black), onPressed: () => Navigator.pop(context)), title: const Text('FAQ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(faqs[i]['q']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accent)),
              const SizedBox(height: 8),
              Text(faqs[i]['a']!, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}
