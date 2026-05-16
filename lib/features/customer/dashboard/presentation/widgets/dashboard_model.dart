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
    final imageSize = (width * 0.56).clamp(108.0, 156.0);
    final bodyTop = imageSize * 0.44;
    final bodyHeight = (width * 0.86).clamp(188.0, 236.0);
    final totalHeight = bodyTop + bodyHeight + 8;
    return MenuCardMetrics(
      imageSize: imageSize,
      bodyTop: bodyTop,
      bodyHeight: bodyHeight,
      contentTopPadding: imageSize * 0.60,
      totalHeight: totalHeight,
      nameFont: (width * 0.072).clamp(14.0, 18.0),
      priceFont: (width * 0.12).clamp(24.0, 32.0),
    );
  }
}

String formatDashboardPrice(String raw) {
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
