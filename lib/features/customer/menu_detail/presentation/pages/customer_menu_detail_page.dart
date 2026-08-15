import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/config/constants/api_constants.dart';
import 'package:restaurant/core/utils/currency_formatter.dart';
import 'package:restaurant/core/utils/helpers.dart';
import 'package:restaurant/features/customer/cart/presentation/providers/customer_cart_provider.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

import '../providers/customer_menu_detail_provider.dart';
import '../widgets/menu_detail_widgets.dart';

class CustomerMenuDetailPage extends ConsumerStatefulWidget {
  final int menuId;
  final String name;
  final String price;
  final String imageUrl;
  final String heroTag;
  final String description;
  final bool isAvailable;
  final String category;

  const CustomerMenuDetailPage({
    super.key,
    required this.menuId,
    this.name = 'Veggie tomato mix',
    this.price = 'N1,900',
    this.imageUrl =
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200',
    this.heroTag = 'menu-detail',
    this.description = '',
    this.isAvailable = true,
    this.category = '',
  });

  @override
  ConsumerState<CustomerMenuDetailPage> createState() =>
      _CustomerMenuDetailPageState();
}

class _CustomerMenuDetailPageState
    extends ConsumerState<CustomerMenuDetailPage> {
  final List<int> _selectedAddonIds = [];
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(customerMenuDetailProvider.notifier)
          .fetchMenuAddons(widget.menuId);
    });
  }

  Future<void> _onRefresh() async {
    await ref
        .read(customerMenuDetailProvider.notifier)
        .fetchMenuAddons(widget.menuId);
  }

  void _toggleAddon(int addonId) {
    setState(() {
      (_selectedAddonIds.contains(addonId)
          ? _selectedAddonIds.remove
          : _selectedAddonIds.add)(addonId);
    });
  }

  Future<void> _onAddToCart() async {
    final notifier = ref.read(customerCartProvider.notifier);
    final menuDetailState = ref.read(customerMenuDetailProvider);

    final selectedAddons = menuDetailState.addons
        .where((a) => _selectedAddonIds.contains(a.addonId))
        .toList();

    await notifier.addToCart(
      menuId: widget.menuId,
      menuName: widget.name,
      unitPrice: widget.price,
      menuImageUrl: widget.imageUrl.isNotEmpty
          ? '${ApiConstants.baseUrl}/${widget.imageUrl}'
          : '',
      addonIds: selectedAddons.map((a) => a.addonId).toList(),
      addonNames: selectedAddons.map((a) => a.price).toList(),
      quantity: _quantity,
    );
    setState(() => _quantity = 1);

    if (!mounted) return;
    AppHelpers.showSnackBar(context, 'Added to cart');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerMenuDetailProvider);

    const accent = Color(0xFFFF460A);
    final width = MediaQuery.sizeOf(context).width;
    final imageSize = (width * 0.48).clamp(150.0, 210.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F8),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: accent,
                  backgroundColor: Colors.white,
                  edgeOffset: 20,
                  displacement: 40,
                  strokeWidth: 3,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: MenuDetailImageSection(
                          imageUrl: widget.imageUrl,
                          heroTag: widget.heroTag,
                          imageSize: imageSize,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Center(
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          formatCurrency(widget.price),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildDescription(),
                      const SizedBox(height: 24),
                      if (widget.category.toLowerCase().contains('food') ||
                          widget.category.toLowerCase().contains('makanan')) ...[
                        MenuDetailAddonsSection(
                          state: state,
                          selectedAddonIds: _selectedAddonIds,
                          accent: accent,
                          onToggleAddon: _toggleAddon,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          _QuantitySelector(
                            quantity: _quantity,
                            onDec: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            onInc: () => setState(() => _quantity++),
                            accent: accent,
                          ),
                        ],
                      ),
                    ),
                    _AddToCartButton(
                      accent: accent,
                      isAvailable: widget.isAvailable,
                      onTap: _onAddToCart,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
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
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (widget.description.isNotEmpty)
          Text(
            widget.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          )
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
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDec;
  final VoidCallback onInc;
  final Color accent;

  const _QuantitySelector({
    required this.quantity,
    required this.onDec,
    required this.onInc,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove,
            onTap: onDec,
            color: onDec != null ? Colors.black87 : Colors.grey[300]!,
            backgroundColor: const Color(0xFFF5F5F8),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 32,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                '$quantity',
                key: ValueKey<int>(quantity),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          _QuantityButton(
            icon: Icons.add,
            onTap: onInc,
            color: Colors.white,
            backgroundColor: accent,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color backgroundColor;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final Color accent;
  final bool isAvailable;
  final VoidCallback onTap;

  const _AddToCartButton({
    required this.accent,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: isAvailable ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isAvailable ? accent : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Add to cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
