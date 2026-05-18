import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

import '../../../checkout/presentation/pages/customer_checkout_page.dart';
import '../providers/customer_cart_provider.dart';
import '../widgets/cart_widgets.dart';

class CustomerCartPage extends ConsumerStatefulWidget {
  const CustomerCartPage({super.key});

  @override
  ConsumerState<CustomerCartPage> createState() => _CustomerCartPageState();
}

class _CustomerCartPageState extends ConsumerState<CustomerCartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerCartProvider.notifier).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    final size = MediaQuery.sizeOf(context);
    final state = ref.watch(customerCartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: switch (state.status) {
        CustomerCartStatus.loading => const ShimmerCartItem(),
        _ when state.items.isEmpty => EmptyCartView(
          accent: accent,
          onStartOrdering: () => Navigator.pop(context),
        ),
        _ => _CartContent(state: state, size: size, accent: accent),
      },
    );
  }
}

class _CartContent extends ConsumerWidget {
  final CustomerCartState state;
  final Size size;
  final Color accent;

  const _CartContent({
    required this.state,
    required this.size,
    required this.accent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_circle_left_outlined,
                size: 20,
                color: Colors.black54,
              ),
              SizedBox(width: 8),
              Text(
                'swipe on an item to delete',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return CartItemTile(
                item: item,
                accent: accent,
                onRemove: () => ref
                    .read(customerCartProvider.notifier)
                    .removeFromCart(item.id),
                onDec: () => ref
                    .read(customerCartProvider.notifier)
                    .updateCartQuantity(item.id, item.quantity - 1),
                onInc: () => ref
                    .read(customerCartProvider.notifier)
                    .updateCartQuantity(item.id, item.quantity + 1),
              );
            },
          ),
        ),
        _CartFooter(accent: accent),
      ],
    );
  }
}

class _CartFooter extends StatelessWidget {
  final Color accent;

  const _CartFooter({required this.accent});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, size.height * 0.04),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerCheckoutPage()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Complete order',
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
