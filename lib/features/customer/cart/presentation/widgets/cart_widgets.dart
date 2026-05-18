import 'package:flutter/material.dart';
import 'package:restaurant/core/utils/currency_formatter.dart';
import 'package:restaurant/features/customer/cart/domain/entities/cart_item.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final Color accent;
  final VoidCallback onRemove, onDec, onInc;

  const CartItemTile({
    super.key,
    required this.item,
    required this.accent,
    required this.onRemove,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ActionBtn(
              icon: Icons.delete_outline,
              color: const Color(0xFFDF2C2C),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: item.menuImageUrl.isNotEmpty
                    ? Image.network(
                        item.menuImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          size: 28,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.broken_image_outlined,
                        size: 28,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menuName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatCurrency(item.unitPrice),
                    style: const TextStyle(
                      color: Color(0xFFFF460A),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Subtotal: ${formatCurrency(item.subtotal)}',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                  if (item.addons.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    ...item.addons.map(
                      (a) => Text(
                        '+ ${a.addonName} (${formatCurrency(a.addonPrice)})',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            QtyControl(
              qty: item.quantity,
              accent: accent,
              onDec: onDec,
              onInc: onInc,
            ),
          ],
        ),
      ),
    );
  }
}

class QtyControl extends StatelessWidget {
  final int qty;
  final Color accent;
  final VoidCallback onDec, onInc;

  const QtyControl({
    super.key,
    required this.qty,
    required this.accent,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(label: '-', onTap: onDec),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$qty',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          _Btn(label: '+', onTap: onInc),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.transparent,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _ActionBtn({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class EmptyCartView extends StatelessWidget {
  final Color accent;
  final VoidCallback onStartOrdering;

  const EmptyCartView({
    super.key,
    required this.accent,
    required this.onStartOrdering,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          const Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Color(0xFFC7C7C7),
          ),
          const SizedBox(height: 24),
          const Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hit the orange button down\nbelow to Create an order',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: onStartOrdering,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start ordering',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
