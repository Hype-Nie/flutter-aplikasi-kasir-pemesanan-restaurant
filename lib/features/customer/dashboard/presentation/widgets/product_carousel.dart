import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

import 'dashboard_model.dart';
import 'dashboard_placeholder.dart';

class ProductCarousel extends StatelessWidget {
  final List<FoodItem> items;
  final double cardWidth;
  final ValueChanged<int> onVisibleIndexChanged;

  const ProductCarousel({super.key, required this.items, required this.cardWidth, required this.onVisibleIndexChanged});

  @override
  Widget build(BuildContext context) {
    final metrics = MenuCardMetrics.fromWidth(cardWidth);
    final topInset = (cardWidth * 0.06).clamp(10.0, 18.0);
    final renderItems = items.isEmpty
        ? const [FoodItem(id: 0, name: 'No item found', price: '-', imageUrl: '', category: 'Foods')]
        : items;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: ValueKey(renderItems.first.category + renderItems.length.toString()),
        height: metrics.totalHeight + topInset,
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: CarouselSlider.builder(
            itemCount: renderItems.length,
            options: CarouselOptions(
              height: metrics.totalHeight,
              viewportFraction: 0.6,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) => onVisibleIndexChanged(index),
            ),
            itemBuilder: (_, index, __) => FoodCard(item: renderItems[index], width: cardWidth),
          ),
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final FoodItem item;
  final double width;

  const FoodCard({super.key, required this.item, required this.width});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF4D06);
    final metrics = MenuCardMetrics.fromWidth(width);
    final imageLeft = (width - metrics.imageSize) / 2;
    return SizedBox(
      width: width, height: metrics.totalHeight,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          top: metrics.bodyTop, left: 0, right: 0,
          child: Container(
            height: metrics.bodyHeight,
            padding: EdgeInsets.fromLTRB(16, metrics.contentTopPadding, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(32),
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0, 9))],
            ),
            child: Column(children: [
              Text(item.name, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: metrics.nameFont, fontWeight: FontWeight.w700, height: 1.1)),
              const SizedBox(height: 18),
              Text(formatDashboardPrice(item.price),
                  style: TextStyle(fontSize: metrics.priceFont, fontWeight: FontWeight.w700, color: accent)),
            ]),
          ),
        ),
        Positioned(
          left: imageLeft,
          child: Hero(
            tag: item.name,
            child: Container(
              width: metrics.imageSize, height: metrics.imageSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, 10))],
              ),
              child: ClipOval(
                child: item.imageUrl.isNotEmpty
                    ? Image.network(item.imageUrl, fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const ShimmerEffect(
                            child: SizedBox.expand(child: ColoredBox(color: Color(0xFFE0E0E0))),
                          );
                        },
                        errorBuilder: (_, __, ___) => const ImagePlaceholder())
                    : const ImagePlaceholder(),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
