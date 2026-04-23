import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/menu_detail/presentation/pages/customer_menu_detail_page.dart';

class CustomerMenuResultsPage extends StatefulWidget {
  const CustomerMenuResultsPage({
    super.key,
    required this.initialQuery,
    required this.items,
  });
  final String initialQuery;
  final List<Map<String, String>> items;

  @override
  State<CustomerMenuResultsPage> createState() =>
      _CustomerMenuResultsPageState();
}

class _CustomerMenuResultsPageState extends State<CustomerMenuResultsPage> {
  late final TextEditingController _controller;
  late final List<_ResultItem> _all;
  String _query = '';
  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _controller = TextEditingController(text: _query);
    _all = List.generate(
      widget.items.length,
      (i) => _ResultItem.fromMap(widget.items[i], i),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_ResultItem> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final filtered = _all
        .where((e) => e.name.toLowerCase().contains(q))
        .toList(growable: false);
    return filtered.take(6).toList(growable: false);
  }

  void _openDetail(_ResultItem item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curve);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: CustomerMenuDetailPage(
                name: item.name,
                price: item.price,
                imageUrl: item.imageUrl,
                heroTag: item.heroTag,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = (size.width * 0.025).clamp(6.0, 10.0);
    final ratio = size.width < 370 ? 0.78 : 0.84;
    final items = _visible;

    return Scaffold(
      backgroundColor: const Color(0xFFE7E7E7),
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - value)),
              child: child,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Search menu',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      Text(
                        'Found ${items.length} results',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: items.isEmpty
                            ? Center(
                                child: Text(
                                  _query.trim().isEmpty
                                      ? 'Type to search menu'
                                      : 'No results found',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF8B8B8B),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: items.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                      childAspectRatio: ratio,
                                    ),
                                itemBuilder: (context, index) => _ResultCard(
                                  item: items[index],
                                  index: index,
                                  onTap: () => _openDetail(items[index]),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.item,
    required this.index,
    required this.onTap,
  });
  final _ResultItem item;
  final int index;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final delay = (index * 45).clamp(0, 240);
    final size = MediaQuery.sizeOf(context);
    final img = (size.width * 0.20).clamp(80.0, 92.0);
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 280 + delay),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: img * 0.30,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, img * 0.92, 10, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.price,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF4D06),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              child: Center(
                child: Hero(
                  tag: item.heroTag,
                  child: SizedBox(
                    width: img,
                    height: img,
                    child: ClipOval(
                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
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

class _ResultItem {
  const _ResultItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.heroTag,
  });
  final String name;
  final String price;
  final String imageUrl;
  final String heroTag;
  factory _ResultItem.fromMap(Map<String, String> map, int index) {
    final name = map['name'] ?? 'Unknown item';
    return _ResultItem(
      name: name,
      price: map['price'] ?? 'N0',
      imageUrl:
          map['imageUrl'] ??
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200',
      heroTag: 'menu-$index-$name',
    );
  }
}
