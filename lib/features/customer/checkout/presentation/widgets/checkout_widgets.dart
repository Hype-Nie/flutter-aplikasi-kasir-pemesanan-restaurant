import 'package:flutter/material.dart';
import 'package:restaurant/core/utils/currency_formatter.dart';
import 'package:restaurant/features/customer/cart/domain/entities/cart_item.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final List<CartItem> items;
  final Color accent;
  const CheckoutOrderSummary({
    super.key, required this.items, required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              if (i > 0)
                Divider(color: Colors.grey.shade200, height: 20),
              _ItemRow(item: item, accent: accent),
            ],
          );
        }),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  final Color accent;
  const _ItemRow({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 50, height: 50,
            child: item.menuImageUrl.isNotEmpty
                ? Image.network(item.menuImageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder())
                : _placeholder(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.menuName, style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14,
              )),
              const SizedBox(height: 2),
              Text('${item.quantity}x  ${formatCurrency(item.unitPrice)}',
                style: const TextStyle(
                  color: Colors.black54, fontSize: 12,
                ),
              ),
              if (item.addons.isNotEmpty) ...[
                const SizedBox(height: 4),
                ...item.addons.map((a) => Text(
                  '+ ${a.addonName} (${formatCurrency(a.addonPrice)})',
                  style: const TextStyle(
                    color: Colors.black38, fontSize: 11,
                  ),
                )),
              ],
            ],
          ),
        ),
        Text(
          formatCurrency(item.totalWithAddons),
          style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 14, color: accent,
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFF5F5F8),
    child: const Icon(Icons.fastfood_outlined, size: 24, color: Colors.grey),
  );
}

class CheckoutPriceBreakdown extends StatelessWidget {
  final String total;
  final Color accent;
  const CheckoutPriceBreakdown({
    super.key, required this.total, required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total', style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w600,
          )),
          Text(formatCurrency(total), style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800, color: accent,
          )),
        ],
      ),
    );
  }
}

class CheckoutNotesField extends StatelessWidget {
  final TextEditingController tableController;
  final TextEditingController notesController;
  const CheckoutNotesField({
    super.key,
    required this.tableController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(text: const TextSpan(
          text: 'Table Number ',
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            TextSpan(text: '*', style: TextStyle(color: Colors.redAccent)),
          ],
        )),
        const SizedBox(height: 6),
        TextField(
          controller: tableController,
          decoration: InputDecoration(
            hintText: 'e.g. Table 1',
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
            prefixIcon: const Icon(Icons.table_restaurant_outlined,
                color: Colors.black38, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Notes (optional)',
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
            prefixIcon: const Icon(Icons.notes_outlined,
                color: Colors.black38, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
