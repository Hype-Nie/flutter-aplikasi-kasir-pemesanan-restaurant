import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/config/constants/api_constants.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/core/utils/token_storage.dart';
import 'package:restaurant/features/customer/domain/entities/addon.dart';
import '../../domain/entities/cart_item.dart';

enum CustomerCartStatus { initial, loading, success, failure }

class CustomerCartState extends Equatable {
  final CustomerCartStatus status;
  final List<CartItem> items;
  final String message;

  const CustomerCartState({
    this.status = CustomerCartStatus.initial,
    this.items = const [],
    this.message = '',
  });

  String get totalAmount {
    double total = 0;
    for (final item in items) {
      total += double.tryParse(item.totalWithAddons) ?? 0;
    }
    return total.toStringAsFixed(2);
  }

  CustomerCartState copyWith({
    CustomerCartStatus? status,
    List<CartItem>? items,
    String? message,
  }) => CustomerCartState(
    status: status ?? this.status,
    items: items ?? this.items,
    message: message ?? this.message,
  );

  @override
  List<Object?> get props => [status, items, message];
}

class CustomerCartNotifier extends Notifier<CustomerCartState> {
  @override
  CustomerCartState build() => const CustomerCartState();

  Future<void> fetchCart() async {
    state = state.copyWith(status: CustomerCartStatus.loading, message: '');
    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) {
        state = state.copyWith(
          status: CustomerCartStatus.failure,
          message: 'User not found.',
        );
        return;
      }

      final results = await Future.wait([
        DioClient.instance.get('/api/carts'),
        DioClient.instance.get('/api/cart-addons'),
        DioClient.instance.get('/api/addons'),
        DioClient.instance.get('/api/menus'),
      ]);

      final addonMap = <int, Addon>{};
      for (final json in results[2].data as List<dynamic>) {
        final a = Addon.fromJson(json as Map<String, dynamic>);
        addonMap[a.id] = a;
      }

      final menuMap = <int, Map<String, dynamic>>{};
      for (final json in results[3].data as List<dynamic>) {
        final m = json as Map<String, dynamic>;
        menuMap[m['id'] as int] = m;
      }

      final cartAddons = <int, List<CartAddon>>{};
      for (final json in results[1].data as List<dynamic>) {
        final a = CartAddon.fromJson(json as Map<String, dynamic>);
        cartAddons.putIfAbsent(a.cartId, () => []).add(a);
      }

      final cartItems = (results[0].data as List<dynamic>).map((json) {
        final m = json as Map<String, dynamic>;
        final cartId = m['id'] as int;
        final menuId = int.tryParse(m['menu_id'].toString()) ?? 0;
        final menuInfo = menuMap[menuId];
        final addonList = cartAddons[cartId] ?? [];
        return CartItem(
          id: cartId,
          menuId: menuId,
          menuName: menuInfo?['name'] as String? ?? 'Unknown',
          unitPrice: m['unit_price'] as String? ?? '0',
          menuImageUrl: menuInfo?['image'] != null && (menuInfo?['image'] as String).isNotEmpty
              ? '${ApiConstants.baseUrl}/${menuInfo?['image']}'
              : '',
          quantity: int.tryParse(m['quantity'].toString()) ?? 1,
          subtotal: m['subtotal'] as String? ?? '0',
          addons: addonList.map((a) {
            final addonInfo = addonMap[a.addonId];
            return CartAddon(
              id: a.id,
              cartId: a.cartId,
              addonId: a.addonId,
              addonName: addonInfo?.name ?? 'Addon #${a.addonId}',
              addonPrice: a.addonPrice,
            );
          }).toList(),
        );
      }).toList();

      state = state.copyWith(
        status: CustomerCartStatus.success,
        items: cartItems,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Failed to load cart.';
      if (data is Map && data['message'] is String) msg = data['message'];
      state = state.copyWith(status: CustomerCartStatus.failure, message: msg);
    } catch (_) {
      state = state.copyWith(
        status: CustomerCartStatus.failure,
        message: 'Something went wrong.',
      );
    }
  }

  Future<void> addToCart({
    required int menuId,
    required String menuName,
    required String unitPrice,
    required String menuImageUrl,
    required List<int> addonIds,
    required List<String> addonNames,
    int quantity = 1,
  }) async {
    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) return;

      // subtotal = menu unit price × quantity only (addons posted separately)
      final menuPrice = double.tryParse(unitPrice) ?? 0;
      final subtotal = menuPrice * quantity;

      final cartData = {
        'user_id': userId.toString(),
        'menu_id': menuId.toString(),
        'quantity': quantity.toString(),
        'unit_price': unitPrice,
        'subtotal': subtotal.toStringAsFixed(2),
      };

      final cartResponse = await DioClient.instance.post(
        '/api/carts',
        data: cartData,
      );
      final cartJson = cartResponse.data as Map<String, dynamic>;
      final cartId = cartJson['id'] as int;

      for (var i = 0; i < addonIds.length; i++) {
        await DioClient.instance.post(
          '/api/cart-addons',
          data: {
            'cart_id': cartId.toString(),
            'addon_id': addonIds[i].toString(),
            'addon_price': addonNames.length > i ? addonNames[i] : '0',
          },
        );
      }

      await fetchCart();
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Failed to add to cart.';
      if (data is Map && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        msg = (errors.values.first as List).first.toString();
      } else if (data is Map && data['message'] is String) {
        msg = data['message'];
      }
      state = state.copyWith(status: CustomerCartStatus.failure, message: msg);
    } catch (_) {
      state = state.copyWith(
        status: CustomerCartStatus.failure,
        message: 'Something went wrong.',
      );
    }
  }

  Future<void> removeFromCart(int cartId) async {
    try {
      await DioClient.instance.delete('/api/carts/$cartId');
      await fetchCart();
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Failed to remove.';
      if (data is Map && data['message'] is String) msg = data['message'];
      state = state.copyWith(status: CustomerCartStatus.failure, message: msg);
    } catch (_) {
      state = state.copyWith(
        status: CustomerCartStatus.failure,
        message: 'Something went wrong.',
      );
    }
  }

  Future<void> clearCart() async {
    final ids = state.items.map((i) => i.id).toList();
    // Clear local state immediately for instant UI feedback
    state = const CustomerCartState();
    // Delete all items from the server in parallel
    if (ids.isNotEmpty) {
      await Future.wait(
        ids.map((id) async {
          try {
            await DioClient.instance.delete('/api/carts/$id');
          } catch (_) {}
        }),
      );
    }
  }
}

final customerCartProvider =
    NotifierProvider<CustomerCartNotifier, CustomerCartState>(
      CustomerCartNotifier.new,
    );
