import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/dashboard/presentation/widgets/dashboard_placeholder.dart';
import 'package:restaurant/core/utils/currency_formatter.dart';

class MenuResultCard extends StatelessWidget {
  final int id;
  final String name;
  final String price;
  final String imageUrl;
  final String heroTag;
  final String description;
  final bool isAvailable;
  final int index;
  final VoidCallback onTap;

  const MenuResultCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.heroTag,
    required this.description,
    required this.isAvailable,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final delay = (index * 45).clamp(0, 240);
    final size = MediaQuery.sizeOf(context);
    final img = (size.width * 0.20).clamp(80.0, 92.0);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 280 + delay),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: img * 0.30,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, img * 0.92, 10, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatCurrency(price),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF4D06),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: SizedBox(
                    width: img,
                    height: img,
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const ImagePlaceholder(),
                            )
                          : const ImagePlaceholder(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuResultItem {
  final int id;
  final String name;
  final String price;
  final String imageUrl;
  final String heroTag;
  final String description;
  final bool isAvailable;
  final String category;

  const MenuResultItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.heroTag,
    required this.description,
    required this.isAvailable,
    required this.category,
  });

  factory MenuResultItem.fromMap(Map<String, String> map) {
    return MenuResultItem(
      id: int.tryParse(map['id'] ?? '') ?? 0,
      name: map['name'] ?? 'Unknown item',
      price: map['price'] ?? '0',
      imageUrl: map['imageUrl'] ?? '',
      heroTag: 'menu-results-${map['id']}',
      description: map['description'] ?? '',
      isAvailable: map['is_available'] != 'false',
      category: map['category'] ?? '',
    );
  }
}
