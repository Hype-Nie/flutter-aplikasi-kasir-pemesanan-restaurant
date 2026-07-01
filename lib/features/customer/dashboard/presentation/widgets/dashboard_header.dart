import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final double iconSize;
  final double titleSize;
  final bool isDrawerOpen;
  final TextEditingController searchController;
  final VoidCallback onMenuTap;
  final VoidCallback onCartTap;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmit;
  final int cartCount;

  const DashboardHeader({
    super.key,
    required this.iconSize,
    required this.titleSize,
    required this.isDrawerOpen,
    required this.searchController,
    required this.onMenuTap,
    required this.onCartTap,
    required this.onSearchChanged,
    required this.onSearchSubmit,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onMenuTap,
                icon: Icon(
                  Icons.menu_rounded,
                  size: iconSize,
                  color: Colors.black87,
                ),
              ),
              if (isDrawerOpen)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'tap again to close',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                ),
              const Spacer(),
              IconButton(
                onPressed: onCartTap,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: iconSize - 2,
                      color: const Color(0xFFA4A4A4),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animation,
                                curve: Curves.elasticOut,
                              ),
                              child: child,
                            );
                          },
                          child: Container(
                            key: ValueKey('cart_badge_$cartCount'),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF4D06),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$cartCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Delicious\nfood for you',
            style: TextStyle(
              fontSize: titleSize,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    onPressed: onSearchSubmit,
                    icon: const Icon(
                      Icons.search,
                      size: 28,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    onSubmitted: (_) => onSearchSubmit(),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF848484),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
