import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF0F0F0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, size: 32, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCarouselShimmer extends StatelessWidget {
  const ProductCarouselShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Row(
        children: [
          Expanded(child: _shimmerCard()),
          const SizedBox(width: 16),
          Expanded(child: _shimmerCard()),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBlock(width: 80, height: 80, radius: 40),
          const SizedBox(height: 14),
          const ShimmerBlock(width: 120, height: 16),
          const SizedBox(height: 8),
          const ShimmerBlock(width: 80, height: 20),
        ],
      ),
    );
  }
}
