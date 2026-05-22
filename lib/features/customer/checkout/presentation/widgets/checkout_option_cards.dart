import 'package:flutter/material.dart';

class OrderTypeCard extends StatelessWidget {
  final String orderType;
  final ValueChanged<String?> onChanged;
  const OrderTypeCard({
    super.key, required this.orderType, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        _TypeOpt(
          val: 'dine_in', cur: orderType, label: 'Dine In',
          sub: 'Eat at restaurant', icon: Icons.restaurant,
          bg: const Color(0xFFFF460A), accent: accent, onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Divider(color: Colors.grey.shade200, height: 1),
        ),
        _TypeOpt(
          val: 'take_away', cur: orderType, label: 'Take Away',
          sub: 'Pick up your order', icon: Icons.takeout_dining,
          bg: const Color(0xFFEB4794), accent: accent, onChanged: onChanged,
        ),
      ]),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final String payment;
  final ValueChanged<String?> onChanged;
  const PaymentMethodCard({
    super.key, required this.payment, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        _TypeOpt(
          val: 'card', cur: payment, label: 'Online Payment',
          sub: 'Xendit Payment Gateway', icon: Icons.payment,
          bg: const Color(0xFF0038FF), accent: accent, onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Divider(color: Colors.grey.shade200, height: 1),
        ),
        _TypeOpt(
          val: 'cash', cur: payment, label: 'Cash at Cashier',
          sub: 'Pay directly at counter', icon: Icons.payments_outlined,
          bg: const Color(0xFF4CAF50), accent: accent, onChanged: onChanged,
        ),
      ]),
    );
  }
}

class _TypeOpt extends StatelessWidget {
  final String val, cur, label, sub;
  final IconData icon;
  final Color bg, accent;
  final ValueChanged<String?> onChanged;
  const _TypeOpt({
    required this.val, required this.cur, required this.label,
    required this.sub, required this.icon, required this.bg,
    required this.accent, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sel = val == cur;
    return InkWell(
      onTap: () => onChanged(val),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          _RadioDot(selected: sel, accent: accent),
          const SizedBox(width: 12),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
              Text(sub, style: const TextStyle(
                  fontSize: 11, color: Colors.black38)),
            ],
          )),
        ]),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  final Color accent;
  const _RadioDot({required this.selected, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? accent : Colors.black26, width: 2,
        ),
      ),
      child: selected
          ? Center(child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: accent,
              ),
            ))
          : null,
    );
  }
}
