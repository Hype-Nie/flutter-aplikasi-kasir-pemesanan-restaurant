import 'package:flutter/material.dart';

class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.name,
    required this.quantity,
    required this.subtotal,
  });

  final String name;
  final int quantity;
  final String subtotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
          'x$quantity',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B8B8B),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          subtotal,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF4D06),
          ),
        ),
      ],
    );
  }
}
