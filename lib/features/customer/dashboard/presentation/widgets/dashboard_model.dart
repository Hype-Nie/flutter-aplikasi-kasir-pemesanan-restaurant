class FoodItem {
  final int id;
  final String name;
  final String price;
  final String imageUrl;
  final String category;
  final String description;
  final bool isAvailable;

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.description = '',
    this.isAvailable = true,
  });
}

class MenuCardMetrics {
  final double imageSize;
  final double bodyTop;
  final double bodyHeight;
  final double contentTopPadding;
  final double totalHeight;
  final double nameFont;
  final double priceFont;

  const MenuCardMetrics({
    required this.imageSize,
    required this.bodyTop,
    required this.bodyHeight,
    required this.contentTopPadding,
    required this.totalHeight,
    required this.nameFont,
    required this.priceFont,
  });

  factory MenuCardMetrics.fromWidth(double width) {
    final imageSize = (width * 0.58).clamp(115.0, 165.0);
    final bodyTop = imageSize * 0.40;
    final bodyHeight = (width * 0.95).clamp(200.0, 260.0);
    final totalHeight = bodyTop + bodyHeight + 10;
    return MenuCardMetrics(
      imageSize: imageSize,
      bodyTop: bodyTop,
      bodyHeight: bodyHeight,
      contentTopPadding: imageSize * 0.65,
      totalHeight: totalHeight,
      nameFont: (width * 0.08).clamp(16.0, 20.0),
      priceFont: (width * 0.09).clamp(17.0, 22.0),
    );
  }
}
