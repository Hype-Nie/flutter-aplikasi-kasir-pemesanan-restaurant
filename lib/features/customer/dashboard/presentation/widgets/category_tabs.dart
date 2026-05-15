import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF4D06);
    const muted = Color(0xFFA4A4A4);
    final width = MediaQuery.sizeOf(context).width;
    final tabFont = (width * 0.047).clamp(15.0, 18.0);
    if (categories.isEmpty) return const SizedBox(height: 62);
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 18, right: 18),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (_, index) {
          final active = index == selectedIndex;
          return InkWell(
            onTap: () => onSelect(index),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active ? accent : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  categories[index],
                  style: TextStyle(
                    fontSize: tabFont,
                    fontWeight: FontWeight.w500,
                    color: active ? accent : muted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShimmerCategoryTabs extends StatelessWidget {
  const ShimmerCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: List.generate(4, (i) => Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 18),
            child: const ShimmerBlock(width: 80, height: 36, radius: 8),
          )),
        ),
      ),
    );
  }
}
