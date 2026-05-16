import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

class AddonTile extends StatelessWidget {
  final String name, price;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  const AddonTile({super.key, required this.name, required this.price, required this.selected, required this.onTap, required this.accent});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: selected ? accent : Colors.transparent, width: 1.5)),
        child: Row(children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accent)),
          const SizedBox(width: 12),
          Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? accent : Colors.grey[300]),
        ]),
      ),
    );
  }
}

class IndicatorDots extends StatelessWidget {
  final int active, count;
  final Color accent;
  const IndicatorDots({super.key, required this.active, required this.count, required this.accent});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(count, (index) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: CircleAvatar(radius: index == active ? 3 : 2, backgroundColor: index == active ? accent : const Color(0xFFC6C6C6)),
    )));
  }
}

class ShimmerAddonTile extends StatelessWidget {
  const ShimmerAddonTile({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: const Row(children: [ShimmerBlock(width: 160, height: 16), Spacer(), ShimmerBlock(width: 60, height: 14)]),
    );
  }
}

String formatPrice(String raw) {
  try {
    final amount = double.parse(raw);
    final whole = amount.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    return 'Rp $whole';
  } catch (_) { return raw; }
}

Widget buildImagePlaceholder(double size) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Center(
      child: Container(
        width: size, height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
        child: const ClipOval(
          child: ColoredBox(
            color: Color(0xFFF0F0F0),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
              SizedBox(height: 4),
              Text('Image not available', style: TextStyle(color: Colors.grey, fontSize: 11)),
            ])),
          ),
        ),
      ),
    ),
  );
}
