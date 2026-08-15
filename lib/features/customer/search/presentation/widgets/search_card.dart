import 'package:flutter/material.dart';
import 'package:restaurant/config/constants/api_constants.dart';
import 'package:restaurant/core/utils/currency_formatter.dart';
import 'package:restaurant/features/customer/dashboard/presentation/widgets/dashboard_placeholder.dart';
import 'package:restaurant/features/customer/menu_detail/presentation/pages/customer_menu_detail_page.dart';
import 'package:restaurant/shared/widgets/tappable_card.dart';

class SearchCard extends StatelessWidget {
  final Map<String, String> item;
  final bool isRight;

  const SearchCard({super.key, required this.item, required this.isRight});

  @override
  Widget build(BuildContext context) {
    String imageUrl = item['imageUrl'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '${ApiConstants.baseUrl}/$imageUrl';
    }

    return TappableCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerMenuDetailPage(
            menuId: int.tryParse(item['id'] ?? '') ?? 0,
            name: item['name'] ?? '',
            price: item['price'] ?? '0',
            imageUrl: imageUrl,
            heroTag: 'search-${item['id']}',
            description: item['description'] ?? '',
            isAvailable: item['is_available'] != 'false',
            category: item['category'] ?? '',
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 60),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['name'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatCurrency(item['price'] ?? '0'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF460A),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -40,
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: 'search-${item['id']}',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
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
