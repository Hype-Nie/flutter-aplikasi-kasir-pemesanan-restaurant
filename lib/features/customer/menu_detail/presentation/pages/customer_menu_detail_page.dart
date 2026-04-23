import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomerMenuDetailPage extends StatefulWidget {
  const CustomerMenuDetailPage({
    super.key,
    this.name = 'Veggie tomato mix',
    this.price = 'N1,900',
    this.imageUrl =
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200',
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

  List<String> get _images => [
    widget.imageUrl,
    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=1200',
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200',
    'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=1200',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageSize = (width * 0.48).clamp(150.0, 210.0);

    return Scaffold(
      backgroundColor: const Color(0xFFE7E7E7),
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (_, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border_rounded, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CarouselSlider.builder(
                  itemCount: _images.length,
                  options: CarouselOptions(
                    height: imageSize,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) =>
                        setState(() => _activeSlide = index),
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final image = Container(
                      width: imageSize,
                      height: imageSize,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.network(_images[index], fit: BoxFit.cover),
                      ),
                    );
                    return Center(
                      child: index == 0
                          ? Hero(tag: widget.heroTag, child: image)
                          : image,
                    );
                  },
                ),
                const SizedBox(height: 14),
                Center(
                  child: _IndicatorDots(
                    active: _activeSlide,
                    count: _images.length,
                  ),
                ),
                const SizedBox(height: 26),
                Center(
                  child: Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    widget.price,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF4D06),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Delivery info',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Delivered between monday aug and\nthursday 20 from 8 pm to 91:32 pm',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B8B8B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Return policy',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'All our foods are double checked before\nleaving our stores so by any case you\nfind a broken food please contact our\nhotline immediately.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B8B8B),
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _added = !_added);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _added ? 'Added to cart' : 'Removed from cart',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D06),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        _added ? 'Added to cart' : 'Add to cart',
                        key: ValueKey(_added),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorDots extends StatelessWidget {
  const _IndicatorDots({required this.active, required this.count});

  final int active;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: CircleAvatar(
            radius: index == active ? 2.2 : 2,
            backgroundColor: index == active
                ? const Color(0xFFFF4D06)
                : const Color(0xFFC6C6C6),
          ),
        ),
      ),
    );
  }
}
