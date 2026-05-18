import 'package:flutter/material.dart';
import 'package:restaurant/config/constants/api_constants.dart';
import 'package:restaurant/features/customer/menu_detail/presentation/pages/customer_menu_detail_page.dart';
import 'package:restaurant/features/customer/dashboard/presentation/widgets/menu_results_widgets.dart';

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
  late final List<MenuResultItem> _all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _controller = TextEditingController(text: _query);
    _all = widget.items.map((m) {
      final map = Map<String, String>.from(m);
      if (map['imageUrl'] != null &&
          map['imageUrl']!.isNotEmpty &&
          !map['imageUrl']!.startsWith('http')) {
        map['imageUrl'] = '${ApiConstants.baseUrl}/${map['imageUrl']}';
      }
      return MenuResultItem.fromMap(map);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<MenuResultItem> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _all.where((e) => e.name.toLowerCase().contains(q)).take(6).toList();
  }

  void _openDetail(MenuResultItem item) {
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
                menuId: item.id,
                name: item.name,
                price: item.price,
                imageUrl: item.imageUrl,
                heroTag: item.heroTag,
                description: item.description,
                isAvailable: item.isAvailable,
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
              _buildSearchBar(),
              Expanded(child: _buildResults(items, spacing, ratio)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  Widget _buildResults(
    List<MenuResultItem> items,
    double spacing,
    double ratio,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Text(
            'Found ${items.length} results',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: ratio,
                    ),
                    itemBuilder: (context, index) => MenuResultCard(
                      id: items[index].id,
                      name: items[index].name,
                      price: items[index].price,
                      imageUrl: items[index].imageUrl,
                      heroTag: items[index].heroTag,
                      description: items[index].description,
                      isAvailable: items[index].isAvailable,
                      index: index,
                      onTap: () => _openDetail(items[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
