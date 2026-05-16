import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/order_history/presentation/providers/customer_order_history_provider.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

import 'order_widgets.dart';

String formatPrice(String raw) {
  try {
    final amount = double.parse(raw);
    final whole = amount
        .toInt()
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    return 'Rp $whole';
  } catch (_) {
    return raw;
  }
}

List<Widget> buildOrderItemList(CustomerOrderHistoryState state) {
  final items = state.orderItems;
  if (items.isEmpty) {
    return [const Text('No items', style: TextStyle(color: Colors.black54))];
  }
  final widgets = <Widget>[];
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    final menuName = state.menus[item.menuId]?.name ?? 'Menu #${item.menuId}';
    final addonsForItem = state.orderItemAddons
        .where((a) => a.orderItemId == item.id)
        .toList();

    widgets.add(ItemRow(
      name: menuName,
      qty: '${item.quantity}',
      price: formatPrice(item.subtotal),
    ));

    for (final addon in addonsForItem) {
      final addonName =
          state.addons[addon.addonId]?.name ?? 'Addon #${addon.addonId}';
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 24, top: 2, bottom: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('+ $addonName',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text(formatPrice(addon.addonPrice),
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ));
    }
    if (i < items.length - 1) {
      widgets.add(const Divider(height: 24));
    }
  }
  return widgets;
}

class OrderDetailShimmer extends StatelessWidget {
  const OrderDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  ShimmerBlock(width: double.infinity, height: 18),
                  SizedBox(height: 24),
                  ShimmerBlock(width: 200, height: 14),
                  SizedBox(height: 24),
                  ShimmerBlock(width: 160, height: 14),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const ShimmerBlock(width: 60, height: 22),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  ShimmerBlock(width: double.infinity, height: 16),
                  SizedBox(height: 20),
                  ShimmerBlock(width: double.infinity, height: 16),
                  SizedBox(height: 20),
                  ShimmerBlock(width: 160, height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
