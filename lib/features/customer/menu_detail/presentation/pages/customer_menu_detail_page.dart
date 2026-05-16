import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/customer/cart/domain/entities/cart_item.dart';
import 'package:restaurant/features/customer/cart/presentation/providers/customer_cart_provider.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

import '../providers/customer_menu_detail_provider.dart';

String _formatPrice(String raw) {
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

  Widget _buildImagePlaceholder(double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
          child: const ClipOval(
            child: ColoredBox(
              color: Color(0xFFF0F0F0),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 4),
                Text('Image not available', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ])),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerMenuDetailProvider);
    final cartState = ref.watch(customerCartProvider);
    final isInCart = cartState.items.any((i) => i.id == widget.menuId);
    const accent = Color(0xFFFF460A);
    final width = MediaQuery.sizeOf(context).width;
    final imageSize = (width * 0.48).clamp(150.0, 210.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_images.isEmpty)
                      _buildImagePlaceholder(imageSize)
                    else
                      CarouselSlider.builder(
                        itemCount: _images.length,
                        options: CarouselOptions(
                          height: imageSize,
                          viewportFraction: 1,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) => setState(() => _activeSlide = index),
                        ),
                        itemBuilder: (context, index, realIndex) {
                          final image = Container(
                            width: imageSize, height: imageSize,
                            decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
                            child: ClipOval(
                              child: Image.network(_images[index], fit: BoxFit.cover,
                                  loadingBuilder: (_, child, progress) {
                                    if (progress == null) return child;
                                    return const ShimmerEffect(
                                      child: SizedBox.expand(
                                        child: ColoredBox(color: Color(0xFFE0E0E0)),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey)),
                            ),
                          );
                          return Center(child: index == 0 ? Hero(tag: widget.heroTag, child: image) : image);
                        },
                      ),
                    if (_images.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Center(child: _IndicatorDots(active: _activeSlide, count: _images.length, accent: accent)),
                    ],
                    const SizedBox(height: 26),
                    Center(child: Text(widget.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700))),
                    const SizedBox(height: 8),
                    Center(child: Text(_formatPrice(widget.price), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: accent))),
                    const SizedBox(height: 32),
                    const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    if (widget.description.isNotEmpty)
                      Text(widget.description, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4))
                    else
                      const ShimmerEffect(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBlock(width: double.infinity, height: 14),
                            SizedBox(height: 6),
                            ShimmerBlock(width: 200, height: 14),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Text('Add-ons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                    else
                      ...state.addons.map((a) => _AddonTile(
                      name: a.name,
                      price: _formatPrice(a.price),
                      selected: _selectedAddonIds.contains(a.id),
                      onTap: () => setState(() {
                        if (_selectedAddonIds.contains(a.id)) {
                          _selectedAddonIds.remove(a.id);
                        } else {
                          _selectedAddonIds.add(a.id);
                        }
                      }),
                      accent: accent,
                    )),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Padding(
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
                              id: widget.menuId,
                              name: widget.name,
                              price: widget.price,
                              imageUrl: widget.imageUrl,
                            ));
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isInCart ? 'Removed from cart' : 'Added to cart')));
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isAvailable
                        ? (isInCart ? Colors.green : accent)
                        : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: Text(isInCart ? 'Update cart' : 'Add to cart', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddonTile extends StatelessWidget {
  final String name, price;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  const _AddonTile({required this.name, required this.price, required this.selected, required this.onTap, required this.accent});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: selected ? accent : Colors.transparent, width: 1.5)),
        child: Row(
          children: [
            Expanded(child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accent)),
            const SizedBox(width: 12),
            Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? accent : Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}

class _IndicatorDots extends StatelessWidget {
  const _IndicatorDots({required this.active, required this.count, required this.accent});
  final int active, count;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(count, (index) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: CircleAvatar(radius: index == active ? 3 : 2, backgroundColor: index == active ? accent : const Color(0xFFC6C6C6)),
    )));
  }
}

class _ShimmerAddonTile extends StatelessWidget {
  const _ShimmerAddonTile();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: const Row(children: [
        ShimmerBlock(width: 160, height: 16),
        Spacer(),
        ShimmerBlock(width: 60, height: 14),
      ]),
    );
  }
}
