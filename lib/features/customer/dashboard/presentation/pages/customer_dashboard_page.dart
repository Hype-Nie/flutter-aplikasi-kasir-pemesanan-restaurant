import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:restaurant/config/constants/api_constants.dart';
import 'package:restaurant/core/utils/helpers.dart';
import 'package:restaurant/features/customer/search/presentation/pages/customer_search_page.dart';
import 'package:restaurant/features/customer/cart/presentation/providers/customer_cart_provider.dart';
import 'package:restaurant/features/customer/menu_detail/presentation/pages/customer_menu_detail_page.dart';
import 'package:restaurant/features/customer/cart/presentation/pages/customer_cart_page.dart';

import '../providers/customer_dashboard_provider.dart';
import '../widgets/dashboard_model.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/side_drawer.dart';

class CustomerDashboardPage extends ConsumerWidget {
  const CustomerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(customerDashboardProvider);
    return const _CustomerDashboardView();
  }
}

class _CustomerDashboardView extends StatelessWidget {
  const _CustomerDashboardView();

  @override
  Widget build(BuildContext context) => const _DashboardScreen();
}

class _DashboardScreen extends ConsumerStatefulWidget {
  const _DashboardScreen();

  @override
  ConsumerState<_DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<_DashboardScreen> {
  final _searchController = TextEditingController();

  List<String> _categories = const [];
  List<FoodItem> get _items {
    final state = ref.read(customerDashboardProvider);
    final cats = {for (final c in state.categories) c.id: c.name};
    return state.menus
        .map(
          (m) => FoodItem(
            id: m.id,
            name: m.name,
            price: m.price ?? '0',
            imageUrl: m.imageUrl != null && m.imageUrl!.isNotEmpty
                ? '${ApiConstants.baseUrl}/${m.imageUrl}'
                : '',
            category: cats[m.categoryId] ?? 'Other',
            description: m.description ?? '',
            isAvailable: m.isAvailable,
          ),
        )
        .toList();
  }

  int _selectedCategory = 0;
  int _selectedBottomNav = 0;
  int _activeMenuIndex = 0;
  String _query = '';
  bool _drawerOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerDashboardProvider.notifier).fetchDashboardData();
      ref.read(customerCartProvider.notifier).fetchCart();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(customerDashboardProvider.notifier).fetchDashboardData(),
      ref.read(customerCartProvider.notifier).fetchCart(),
    ]);
  }

  void _openSearchPage() {
    final q = _query.trim();
    if (q.isEmpty) {
      AppHelpers.showSnackBar(context, 'Type menu first to search', isError: true);
      return;
    }
    final payload = _items
        .map<Map<String, String>>(
          (e) => {
            'id': e.id.toString(),
            'name': e.name,
            'price': e.price,
            'imageUrl': e.imageUrl,
            'category': e.category,
            'description': e.description,
            'is_available': e.isAvailable.toString(),
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

    final dashboardState = ref.watch(customerDashboardProvider);
    if (dashboardState.categories.isNotEmpty && _categories.isEmpty) {
      _categories = dashboardState.categories
          .map((c) => c.name)
          .toList();
    }
    final selectedCategoryName = _categories.isNotEmpty
        ? _categories[_selectedCategory]
        : '';
    final showingItems = _items
        .where((item) => item.category == selectedCategoryName)
        .toList();
    final isLoading = dashboardState.status == CustomerDashboardStatus.loading;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: bg,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final shiftX = constraints.maxWidth * 0.36;
            return Stack(
              children: [
                SideDrawer(
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
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: DashboardHomeContent(
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
                        isLoading: isLoading,
                        cartCount: ref.watch(customerCartProvider).items.length,
                        cardWidth: cardWidth,
                        onMenuTap: () =>
                            setState(() => _drawerOpen = !_drawerOpen),
                        onCartTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CustomerCartPage(),
                          ),
                        ),
                        onSearchChanged: (value) =>
                            setState(() => _query = value),
                        onSearchSubmit: () => _openSearchPage(),
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
                                menuId: item.id,
                                name: item.name,
                                price: item.price,
                                imageUrl: item.imageUrl,
                                heroTag: 'menu-${item.id}',
                                description: item.description,
                                isAvailable: item.isAvailable,
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
