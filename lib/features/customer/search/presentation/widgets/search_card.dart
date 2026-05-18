import 'package:flutter/material.dart';
import 'package:restaurant/config/constants/api_constants.dart';
import 'package:restaurant/core/utils/currency_formatter.dart';
import 'package:restaurant/features/customer/dashboard/presentation/widgets/dashboard_placeholder.dart';
import 'package:restaurant/features/customer/menu_detail/presentation/pages/customer_menu_detail_page.dart';

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

    return GestureDetector(
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
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 50, top: isRight ? 40 : 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 90, 16, 20),
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
                children: [
                  Text(
                    item['name'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
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
              top: -30,
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: 'search-${item['id']}',
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 8),
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
