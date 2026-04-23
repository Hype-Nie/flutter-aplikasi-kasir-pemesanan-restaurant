import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomerMenuDetailPage extends StatefulWidget {
  const CustomerMenuDetailPage({
    super.key,
    this.name = 'Veggie tomato mix',
    this.price = 'N1,900',
    this.imageUrl = 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200',
    this.heroTag = 'menu-detail',
  });

  final String name;
  final String price;
  final String imageUrl;
  final String heroTag;

  @override
  State<CustomerMenuDetailPage> createState() => _CustomerMenuDetailPageState();
}

class _CustomerMenuDetailPageState extends State<CustomerMenuDetailPage> {
  bool _added = false;
  int _activeSlide = 0;
  final List<String> _selectedAddons = [];

  final List<Map<String, String>> _addons = [
    {'name': 'Extra Sauce', 'price': '+N500'},
    {'name': 'Cheese Topping', 'price': '+N700'},
    {'name': 'Large Portion', 'price': '+N1,200'},
  ];

  List<String> get _images => [
    widget.imageUrl,
    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=1200',
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200',
  ];

  @override
  Widget build(BuildContext context) {
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
                          child: ClipOval(child: Image.network(_images[index], fit: BoxFit.cover)),
                        );
                        return Center(child: index == 0 ? Hero(tag: widget.heroTag, child: image) : image);
                      },
                    ),
                    const SizedBox(height: 14),
                    Center(child: _IndicatorDots(active: _activeSlide, count: _images.length, accent: accent)),
                    const SizedBox(height: 26),
                    Center(child: Text(widget.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700))),
                    const SizedBox(height: 8),
                    Center(child: Text(widget.price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: accent))),
                    const SizedBox(height: 32),
                    const Text('Delivery info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Delivered between monday aug and thursday 20 from 8 pm to 91:32 pm', style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4)),
                    const SizedBox(height: 24),
                    const Text('Add-ons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ..._addons.map((addon) => _AddonTile(
                      name: addon['name']!, 
                      price: addon['price']!,
                      selected: _selectedAddons.contains(addon['name']),
                      onTap: () => setState(() {
                        if (_selectedAddons.contains(addon['name'])) {
                          _selectedAddons.remove(addon['name']);
                        } else {
                          _selectedAddons.add(addon['name']!);
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
                  onPressed: () {
                    setState(() => _added = !_added);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_added ? 'Added to cart' : 'Removed from cart')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
                  child: Text(_added ? 'Update cart' : 'Add to cart', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
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
