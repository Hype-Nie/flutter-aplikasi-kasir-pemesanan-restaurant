import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/customer/cart/domain/entities/cart_item.dart';
import 'package:restaurant/features/customer/cart/presentation/providers/customer_cart_provider.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

import '../providers/customer_menu_detail_provider.dart';
import '../widgets/menu_detail_tiles.dart';

class CustomerMenuDetailPage extends ConsumerStatefulWidget {
  final int menuId;
  final String name;
  final String price;
  final String imageUrl;
  final String heroTag;
  final String description;
  final bool isAvailable;

  const CustomerMenuDetailPage({
    super.key,
    required this.menuId,
    this.name = 'Veggie tomato mix',
    this.price = 'N1,900',
    this.imageUrl = 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200',
    this.heroTag = 'menu-detail',
    this.description = '',
    this.isAvailable = true,
  });

  @override
  ConsumerState<CustomerMenuDetailPage> createState() => _CustomerMenuDetailPageState();
}

class _CustomerMenuDetailPageState extends ConsumerState<CustomerMenuDetailPage> {
  int _activeSlide = 0;
  final List<int> _selectedAddonIds = [];

  List<String> get _images {
    if (!widget.imageUrl.startsWith('http')) return [];
    return [widget.imageUrl];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerMenuDetailProvider.notifier).fetchMenuAddons(widget.menuId);
    });
  }

  Widget _buildButton(Color accent, bool isInCart, List<String> addonNames) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity, height: 64,
        child: ElevatedButton(
          onPressed: widget.isAvailable
              ? () {
                  final notifier = ref.read(customerCartProvider.notifier);
                  if (isInCart) {
                    notifier.removeItem(widget.menuId);
                  } else {
                    notifier.addItem(CartItem(
                      id: widget.menuId, name: widget.name,
                      price: widget.price, imageUrl: widget.imageUrl,
                      addonIds: List.of(_selectedAddonIds),
                      addonNames: addonNames,
                    ));
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isInCart ? 'Removed from cart' : 'Added to cart')));
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isAvailable ? (isInCart ? Colors.green : accent) : Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: Text(isInCart ? 'Update cart' : 'Add to cart',
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerMenuDetailProvider);
    final cartState = ref.watch(customerCartProvider);
    final isInCart = cartState.items.any((i) => i.id == widget.menuId);
    final selectedAddonNames = state.addons
        .where((a) => _selectedAddonIds.contains(a.id))
        .map((a) => a.name)
        .toList();
    const accent = Color(0xFFFF460A);
    final width = MediaQuery.sizeOf(context).width;
    final imageSize = (width * 0.48).clamp(150.0, 210.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            child: Row(children: [
              IconButton(onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
              const Spacer(),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_images.isEmpty)
                buildImagePlaceholder(imageSize)
              else
                CarouselSlider.builder(
                  itemCount: _images.length,
                  options: CarouselOptions(height: imageSize, viewportFraction: 1,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) => setState(() => _activeSlide = index)),
                  itemBuilder: (context, index, realIndex) {
                    final image = Container(
                      width: imageSize, height: imageSize,
                      decoration: const BoxDecoration(shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
                      child: ClipOval(
                        child: Image.network(_images[index], fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return const ShimmerEffect(
                                  child: SizedBox.expand(child: ColoredBox(color: Color(0xFFE0E0E0))));
                            },
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey)),
                      ),
                    );
                    return Center(child: index == 0 ? Hero(tag: widget.heroTag, child: image) : image);
                  },
                ),
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 14),
                Center(child: IndicatorDots(active: _activeSlide, count: _images.length, accent: accent)),
              ],
              const SizedBox(height: 26),
              Center(child: Text(widget.name, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700))),
              const SizedBox(height: 8),
              Center(child: Text(formatPrice(widget.price),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: accent))),
              const SizedBox(height: 32),
              const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (widget.description.isNotEmpty)
                Text(widget.description, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4))
              else
                const ShimmerEffect(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ShimmerBlock(width: double.infinity, height: 14),
                  SizedBox(height: 6),
                  ShimmerBlock(width: 200, height: 14),
                ])),
              const SizedBox(height: 24),
              const Text('Add-ons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (state.status == CustomerMenuDetailStatus.loading)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: ShimmerEffect(child: Column(children: [
                    ShimmerAddonTile(), SizedBox(height: 10), ShimmerAddonTile(),
                  ])),
                )
              else
                ...state.addons.map((a) => AddonTile(
                  name: a.name, price: formatPrice(a.price),
                  selected: _selectedAddonIds.contains(a.id),
                  onTap: () => setState(() {
                    (_selectedAddonIds.contains(a.id)
                        ? _selectedAddonIds.remove
                        : _selectedAddonIds.add)(a.id);
                  }),
                  accent: accent,
                )),
              const SizedBox(height: 100),
            ]),
          )),
          _buildButton(accent, isInCart, selectedAddonNames),
        ]),
      ),
    );
  }
}
