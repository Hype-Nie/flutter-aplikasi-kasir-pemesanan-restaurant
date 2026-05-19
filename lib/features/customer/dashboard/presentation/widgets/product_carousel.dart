import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:restaurant/core/utils/currency_formatter.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

import 'dashboard_model.dart';
import 'dashboard_placeholder.dart';

class ProductCarousel extends StatelessWidget {
  final List<FoodItem> items;
  final double cardWidth;
  final ValueChanged<int> onVisibleIndexChanged;

  const ProductCarousel({
    super.key,
    required this.items,
    required this.cardWidth,
    required this.onVisibleIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = MenuCardMetrics.fromWidth(cardWidth);
    final topInset = (cardWidth * 0.06).clamp(10.0, 18.0);
    final renderItems = items.isEmpty
        ? const [
            FoodItem(
              id: 0,
              name: 'No item found',
              price: '-',
              imageUrl: '',
              category: 'Foods',
            ),
          ]
        : items;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: ValueKey(
          renderItems.first.category + renderItems.length.toString(),
        ),
        height: metrics.totalHeight + topInset,
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: CarouselSlider.builder(
            itemCount: renderItems.length,
            options: CarouselOptions(
              height: metrics.totalHeight,
              viewportFraction: 0.7,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) => onVisibleIndexChanged(index),
            ),
            itemBuilder: (_, index, __) =>
                FoodCard(item: renderItems[index], width: cardWidth),
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
      width: width,
      height: metrics.totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: metrics.bodyTop,
            left: 0,
            right: 0,
            child: Container(
              height: metrics.bodyHeight,
              padding: EdgeInsets.fromLTRB(
                16,
                metrics.contentTopPadding,
                16,
                18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: metrics.nameFont,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatCurrency(item.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: metrics.priceFont,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: imageLeft,
            child: Hero(
              tag: 'menu-${item.id}',
              child: Container(
                width: metrics.imageSize,
                height: metrics.imageSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const ShimmerEffect(
                              child: SizedBox.expand(
                                child: ColoredBox(color: Color(0xFFE0E0E0)),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) =>
                              const ImagePlaceholder(),
                        )
                      : const ImagePlaceholder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
