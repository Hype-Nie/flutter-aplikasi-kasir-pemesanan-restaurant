import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:restaurant/core/utils/currency_formatter.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

import '../providers/customer_menu_detail_provider.dart';

class MenuDetailImageSection extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final double imageSize;

  const MenuDetailImageSection({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    required this.imageSize,
  });

  @override
  State<MenuDetailImageSection> createState() => _MenuDetailImageSectionState();
}

class _MenuDetailImageSectionState extends State<MenuDetailImageSection> {
  int _activeSlide = 0;

  List<String> get _images {
    if (!widget.imageUrl.startsWith('http')) return [];
    return [widget.imageUrl];
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return Center(
        child: Container(
          width: widget.imageSize,
          height: widget.imageSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const ClipOval(
            child: ColoredBox(
              color: Color(0xFFF0F0F0),
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _images.length,
          options: CarouselOptions(
            height: widget.imageSize + 60,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) =>
                setState(() => _activeSlide = index),
          ),
          itemBuilder: (context, index, realIndex) {
            final image = Container(
              width: widget.imageSize * 1.2,
              height: widget.imageSize * 1.2,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  _images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const ShimmerEffect(
                      child: SizedBox.expand(
                        child: ColoredBox(color: Color(0xFFE0E0E0)),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
            return Center(
              child: index == 0
                  ? Hero(tag: widget.heroTag, child: image)
                  : image,
            );
          },
        ),
        if (_images.isNotEmpty) ...[
          Center(
            child: _IndicatorDots(active: _activeSlide, count: _images.length),
          ),
        ],
      ],
    );
  }
}

class _IndicatorDots extends StatelessWidget {
  final int active, count;
  const _IndicatorDots({required this.active, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: CircleAvatar(
            radius: index == active ? 3 : 2,
            backgroundColor: index == active
                ? const Color(0xFFFF460A)
                : const Color(0xFFC6C6C6),
          ),
        ),
      ),
    );
  }
}

class MenuDetailAddonsSection extends StatelessWidget {
  final CustomerMenuDetailState state;
  final List<int> selectedAddonIds;
  final Color accent;
  final void Function(int addonId) onToggleAddon;

  const MenuDetailAddonsSection({
    super.key,
    required this.state,
    required this.selectedAddonIds,
    required this.accent,
    required this.onToggleAddon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add-ons',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (state.status == CustomerMenuDetailStatus.loading)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: ShimmerEffect(
              child: Column(
                children: [
                  _ShimmerAddonTile(),
                  SizedBox(height: 10),
                  _ShimmerAddonTile(),
                ],
              ),
            ),
          )
        else if (state.addons.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No add-ons available',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          )
        else
          ...state.addons.map(
            (a) => _AddonTile(
              name: a.name,
              price: a.price,
              selected: selectedAddonIds.contains(a.addonId),
              onTap: () => onToggleAddon(a.addonId),
              accent: accent,
            ),
          ),
      ],
    );
  }
}

class _AddonTile extends StatelessWidget {
  final String name, price;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  const _AddonTile({
    required this.name,
    required this.price,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              formatCurrency(price),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? accent : Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerAddonTile extends StatelessWidget {
  const _ShimmerAddonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          ShimmerBlock(width: 160, height: 16),
          Spacer(),
          ShimmerBlock(width: 60, height: 14),
        ],
      ),
    );
  }
}
