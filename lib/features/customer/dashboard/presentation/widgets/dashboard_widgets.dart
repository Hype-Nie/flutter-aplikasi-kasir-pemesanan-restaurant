import 'package:flutter/material.dart';

import 'category_tabs.dart';
import 'dashboard_header.dart';
import 'dashboard_model.dart';
import 'dashboard_placeholder.dart';
import 'bottom_nav.dart';
import 'product_carousel.dart';

class DashboardHomeContent extends StatelessWidget {
  final Color bg;
  final Color accent;
  final double iconSize;
  final double titleSize;
  final bool isDrawerOpen;
  final TextEditingController searchController;
  final String selectedCategoryName;
  final List<String> categories;
  final int selectedCategory;
  final int selectedBottomNav;
  final List<FoodItem> showingItems;
  final bool isLoading;
  final int cartCount;
  final double cardWidth;
  final VoidCallback onMenuTap;
  final VoidCallback onCartTap;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmit;
  final ValueChanged<int> onSelectCategory;
  final ValueChanged<int> onSelectBottomNav;
  final VoidCallback onSeeMoreTap;
  final ValueChanged<int> onVisibleMenuChanged;

  const DashboardHomeContent({
    super.key,
    required this.bg,
    required this.accent,
    required this.iconSize,
    required this.titleSize,
    required this.isDrawerOpen,
    required this.searchController,
    required this.selectedCategoryName,
    required this.categories,
    required this.selectedCategory,
    required this.selectedBottomNav,
    required this.showingItems,
    required this.isLoading,
    required this.cartCount,
    required this.cardWidth,
    required this.onMenuTap,
    required this.onCartTap,
    required this.onSearchChanged,
    required this.onSearchSubmit,
    required this.onSelectCategory,
    required this.onSelectBottomNav,
    required this.onSeeMoreTap,
    required this.onVisibleMenuChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: bg,
      child: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: DashboardHeader(
                    iconSize: iconSize,
                    titleSize: titleSize,
                    isDrawerOpen: isDrawerOpen,
                    searchController: searchController,
                    onMenuTap: onMenuTap,
                    onCartTap: onCartTap,
                    onSearchChanged: onSearchChanged,
                    onSearchSubmit: onSearchSubmit,
                    cartCount: cartCount,
                  ),
                ),
                SliverToBoxAdapter(
                  child: categories.isEmpty
                      ? const ShimmerCategoryTabs()
                      : CategoryTabs(
                          categories: categories,
                          selectedIndex: selectedCategory,
                          onSelect: onSelectCategory,
                        ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onSeeMoreTap,
                        style: TextButton.styleFrom(foregroundColor: accent),
                        child: const Text(
                          'see more',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 24,
                      ),
                      child: ProductCarouselShimmer(),
                    ),
                  )
                else if (showingItems.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 60,
                      ),
                      child: _EmptyCategoryContent(),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: ProductCarousel(
                      items: showingItems,
                      cardWidth: cardWidth,
                      onVisibleIndexChanged: onVisibleMenuChanged,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavBar(
                selectedIndex: selectedBottomNav,
                onSelect: onSelectBottomNav,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryContent extends StatelessWidget {
  const _EmptyCategoryContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2_outlined, size: 120, color: Color(0xFFC7C7C7)),
        SizedBox(height: 24),
        Text(
          'No items found',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 12),
        Text(
          'This category has no items.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
        ),
      ],
    );
  }
}
