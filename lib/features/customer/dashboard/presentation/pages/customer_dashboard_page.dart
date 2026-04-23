import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'package:restaurant/features/customer/search/presentation/pages/customer_search_page.dart';
import 'package:restaurant/features/customer/menu_detail/presentation/pages/customer_menu_detail_page.dart';
import 'package:restaurant/features/customer/cart/presentation/pages/customer_cart_page.dart';
import 'package:restaurant/features/customer/profile/presentation/pages/customer_profile_page.dart';
import 'package:restaurant/features/customer/order_history/presentation/pages/customer_order_history_page.dart';
import 'package:restaurant/shared/pages/no_internet_page.dart';
import 'customer_offers_page.dart';

import '../bloc/customer_dashboard_bloc.dart';
import '../bloc/customer_dashboard_event.dart';

class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CustomerDashboardBloc()..add(const CustomerDashboardStarted()),
      child: const _CustomerDashboardView(),
    );
  }
}

class _CustomerDashboardView extends StatelessWidget {
  const _CustomerDashboardView();

  @override
  Widget build(BuildContext context) {
    return const _DashboardScreen();
  }
}

class _DashboardScreen extends StatefulWidget {
  const _DashboardScreen();

  @override
  State<_DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardScreen> {
  final _searchController = TextEditingController();

  final _categories = const ['Foods', 'Drinks', 'Snacks', 'Sauce'];
  final _items = const <_FoodItem>[
    _FoodItem(
      name: 'Veggie tomato mix',
      price: 'N1,900',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200',
      category: 'Foods',
    ),
    _FoodItem(
      name: 'Chicken salad mix',
      price: 'N2,100',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200',
      category: 'Foods',
    ),
    _FoodItem(
      name: 'Avocado veggie bowl',
      price: 'N2,800',
      imageUrl:
          'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=1200',
      category: 'Foods',
    ),
    _FoodItem(
      name: 'Berry smoothie',
      price: 'N1,500',
      imageUrl:
          'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=1200',
      category: 'Drinks',
    ),
    _FoodItem(
      name: 'Lemon iced tea',
      price: 'N1,300',
      imageUrl:
          'https://images.unsplash.com/photo-1497534446932-c925b458314e?w=1200',
      category: 'Drinks',
    ),
    _FoodItem(
      name: 'Orange juice',
      price: 'N1,200',
      imageUrl:
          'https://images.unsplash.com/photo-1622597467836-f3285f2131b8?w=1200',
      category: 'Drinks',
    ),
    _FoodItem(
      name: 'Crunchy chips',
      price: 'N1,100',
      imageUrl:
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=1200',
      category: 'Snacks',
    ),
    _FoodItem(
      name: 'Pretzel snack',
      price: 'N900',
      imageUrl:
          'https://images.unsplash.com/photo-1512852939750-1305098529bf?w=1200',
      category: 'Snacks',
    ),
    _FoodItem(
      name: 'Choco cookies',
      price: 'N1,400',
      imageUrl:
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=1200',
      category: 'Snacks',
    ),
    _FoodItem(
      name: 'Spicy fish sauce',
      price: 'N2,300',
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=1200',
      category: 'Sauce',
    ),
    _FoodItem(
      name: 'Roasted tomato sauce',
      price: 'N2,000',
      imageUrl:
          'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=1200',
      category: 'Sauce',
    ),
    _FoodItem(
      name: 'Cheese dip sauce',
      price: 'N1,700',
      imageUrl:
          'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=1200',
      category: 'Sauce',
    ),
  ];

  int _selectedCategory = 0;
  int _selectedBottomNav = 0;
  int _activeMenuIndex = 0;
  String _query = '';
  bool _drawerOpen = false;

  void _openSearchPage(BuildContext context) {
    final q = _query.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type menu first to search')),
      );
      return;
    }

    final payload = _items
        .map<Map<String, String>>(
          (e) => {
            'name': e.name,
            'price': e.price,
            'imageUrl': e.imageUrl,
            'category': e.category,
          },
        )
        .toList(growable: false);

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) {
          final slide =
              Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: CustomerSearchPage(initialQuery: q, items: payload),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFE7E7E7);
    const accent = Color(0xFFFF4D06);
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final titleSize = (width * 0.13).clamp(42.0, 50.0);
    final cardWidth = (width * 0.56).clamp(216.0, 286.0);
    final iconSize = (width * 0.076).clamp(24.0, 30.0);

    final selectedCategoryName = _categories[_selectedCategory];
    final showingItems = _items
        .where((item) {
          final categoryMatch = item.category == selectedCategoryName;
          return categoryMatch;
        })
        .toList(growable: false);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final shiftX = constraints.maxWidth * 0.36;
            return Stack(
              children: [
                _SideDrawer(
                  open: _drawerOpen,
                  onClose: () => setState(() => _drawerOpen = false),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  top: _drawerOpen ? 42 : 0,
                  bottom: _drawerOpen ? 42 : 0,
                  left: _drawerOpen ? shiftX : 0,
                  right: _drawerOpen ? -shiftX : 0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    scale: _drawerOpen ? 0.86 : 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_drawerOpen ? 30 : 0),
                      child: _DashboardHomeContent(
                        bg: bg,
                        accent: accent,
                        iconSize: iconSize,
                        titleSize: titleSize,
                        isDrawerOpen: _drawerOpen,
                        searchController: _searchController,
                        selectedCategoryName: selectedCategoryName,
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        selectedBottomNav: _selectedBottomNav,
                        showingItems: showingItems,
                        cardWidth: cardWidth,
                        onMenuTap: () =>
                            setState(() => _drawerOpen = !_drawerOpen),
                        onCartTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CustomerCartPage(),
                            ),
                          );
                        },
                        onSearchChanged: (value) =>
                            setState(() => _query = value),
                        onSearchSubmit: () => _openSearchPage(context),
                        onSelectCategory: (index) => setState(() {
                          _selectedCategory = index;
                          _activeMenuIndex = 0;
                        }),
                        onSelectBottomNav: (index) =>
                            setState(() => _selectedBottomNav = index),
                        onSeeMoreTap: () {
                          if (showingItems.isEmpty) return;
                          final safeIndex = _activeMenuIndex.clamp(
                            0,
                            showingItems.length - 1,
                          );
                          final item = showingItems[safeIndex];
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CustomerMenuDetailPage(
                                name: item.name,
                                price: item.price,
                                imageUrl: item.imageUrl,
                                heroTag: item.name,
                              ),
                            ),
                          );
                        },
                        onVisibleMenuChanged: (index) =>
                            setState(() => _activeMenuIndex = index),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _DashboardHomeContent extends StatelessWidget {
  const _DashboardHomeContent({
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
  final List<_FoodItem> showingItems;
  final double cardWidth;
  final VoidCallback onMenuTap;
  final VoidCallback onCartTap;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmit;
  final ValueChanged<int> onSelectCategory;
  final ValueChanged<int> onSelectBottomNav;
  final VoidCallback onSeeMoreTap;
  final ValueChanged<int> onVisibleMenuChanged;

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
                  child: _DashboardHeader(
                    iconSize: iconSize,
                    titleSize: titleSize,
                    isDrawerOpen: isDrawerOpen,
                    searchController: searchController,
                    onMenuTap: onMenuTap,
                    onCartTap: onCartTap,
                    onSearchChanged: onSearchChanged,
                    onSearchSubmit: onSearchSubmit,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _CategoryTabs(
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
                SliverToBoxAdapter(
                  child: _ProductCarousel(
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
              child: _BottomNavBar(
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.iconSize,
    required this.titleSize,
    required this.isDrawerOpen,
    required this.searchController,
    required this.onMenuTap,
    required this.onCartTap,
    required this.onSearchChanged,
    required this.onSearchSubmit,
  });

  final double iconSize;
  final double titleSize;
  final bool isDrawerOpen;
  final TextEditingController searchController;
  final VoidCallback onMenuTap;
  final VoidCallback onCartTap;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmit;

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
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  size: iconSize - 2,
                  color: const Color(0xFFA4A4A4),
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

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF4D06);
    const muted = Color(0xFFA4A4A4);
    final width = MediaQuery.sizeOf(context).width;
    final tabFont = (width * 0.047).clamp(15.0, 18.0);
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

class _ProductCarousel extends StatelessWidget {
  const _ProductCarousel({
    required this.items,
    required this.cardWidth,
    required this.onVisibleIndexChanged,
  });

  final List<_FoodItem> items;
  final double cardWidth;
  final ValueChanged<int> onVisibleIndexChanged;

  @override
  Widget build(BuildContext context) {
    final metrics = _MenuCardMetrics.fromWidth(cardWidth);
    final topInset = (cardWidth * 0.06).clamp(10.0, 18.0);
    final renderItems = items.isEmpty
        ? const [
            _FoodItem(
              name: 'No item found',
              price: '-',
              imageUrl:
                  'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200',
              category: 'Foods',
            ),
          ]
        : items;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: SizedBox(
        key: ValueKey(
          renderItems.first.category + renderItems.length.toString(),
        ),
        height: metrics.totalHeight + topInset,
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: CarouselSlider.builder(
            itemCount: renderItems.length,
            options: CarouselOptions(
              height: metrics.totalHeight,
              viewportFraction: 0.6,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                onVisibleIndexChanged(index);
              },
            ),
            itemBuilder: (_, index, __) =>
                _FoodCard(item: renderItems[index], width: cardWidth),
          ),
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({required this.item, required this.width});

  final _FoodItem item;
  final double width;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF4D06);
    final metrics = _MenuCardMetrics.fromWidth(width);
    final imageLeft = (width - metrics.imageSize) / 2;
    return SizedBox(
      width: width,
      height: metrics.totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: metrics.bodyTop,
            left: 0,
            right: 0,
            child: Container(
              height: metrics.bodyHeight,
              padding: EdgeInsets.fromLTRB(
                16,
                metrics.contentTopPadding,
                16,
                18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 18,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: metrics.nameFont,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    item.price,
                    style: TextStyle(
                      fontSize: metrics.priceFont,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: imageLeft,
            child: Hero(
              tag: item.name,
              child: Container(
                width: metrics.imageSize,
                height: metrics.imageSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return const ColoredBox(
                        color: Color(0xFFF0F0F0),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFF0F0F0),
                      child: Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 0),
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavIcon(
              icon: Icons.home_rounded,
              active: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            _BottomNavIcon(
              icon: Icons.person_outline_rounded,
              active: selectedIndex == 1,
              onTap: () async {
                onSelect(1);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerProfilePage()),
                );
                onSelect(0);
              },
            ),
            _BottomNavIcon(
              icon: Icons.history_rounded,
              active: selectedIndex == 2,
              onTap: () async {
                onSelect(2);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerOrderHistoryPage(),
                  ),
                );
                onSelect(0);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x44FF4D06),
                    blurRadius: 16,
                    spreadRadius: 0.0,
                    offset: Offset(0, 4),
                    blurStyle: BlurStyle.normal,
                  ),
                ]
              : const [],
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFFFF4D06) : const Color(0xFFA8A8A8),
          size: 26,
        ),
      ),
    );
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer({required this.open, required this.onClose});

  final bool open;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: open ? 1 : 0,
      child: IgnorePointer(
        ignoring: !open,
        child: Container(
          color: const Color(0xFFFF4D06),
          padding: EdgeInsets.fromLTRB(20, topInset + 42, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _DrawerAction(
                title: 'Profile',
                icon: Icons.person_outline_rounded,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerProfilePage())),
              ),
              _DrawerAction(
                title: 'orders', 
                icon: Icons.sync_alt_rounded,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerOrderHistoryPage())),
              ),
              _DrawerAction(
                title: 'offer and promo',
                icon: Icons.local_offer_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerOffersPage())),
              ),
              _DrawerAction(
                title: 'Privacy policy',
                icon: Icons.chat_bubble_outline_rounded,
              ),
              _DrawerAction(
                title: 'Security', 
                icon: Icons.shield_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoInternetPage())),
              ),
              const Spacer(),
              InkWell(
                onTap: onClose,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        'Sign-out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
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

class _DrawerAction extends StatelessWidget {
  const _DrawerAction({required this.title, required this.icon, this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$title tapped'))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.28)),
          ],
        ),
      ),
    );
  }
}

class _FoodItem {
  const _FoodItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  final String name;
  final String price;
  final String imageUrl;
  final String category;
}

class _MenuCardMetrics {
  const _MenuCardMetrics({
    required this.imageSize,
    required this.bodyTop,
    required this.bodyHeight,
    required this.contentTopPadding,
    required this.totalHeight,
    required this.nameFont,
    required this.priceFont,
  });

  final double imageSize;
  final double bodyTop;
  final double bodyHeight;
  final double contentTopPadding;
  final double totalHeight;
  final double nameFont;
  final double priceFont;

  factory _MenuCardMetrics.fromWidth(double width) {
    final imageSize = (width * 0.56).clamp(108.0, 156.0);
    final bodyTop = imageSize * 0.44;
    final bodyHeight = (width * 0.86).clamp(188.0, 236.0);
    final totalHeight = bodyTop + bodyHeight + 8;
    return _MenuCardMetrics(
      imageSize: imageSize,
      bodyTop: bodyTop,
      bodyHeight: bodyHeight,
      contentTopPadding: imageSize * 0.60,
      totalHeight: totalHeight,
      nameFont: (width * 0.072).clamp(14.0, 18.0),
      priceFont: (width * 0.12).clamp(24.0, 32.0),
    );
  }
}
