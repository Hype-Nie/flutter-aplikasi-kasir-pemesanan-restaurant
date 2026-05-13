import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cart_item.dart';

final customerCartProvider =
    StateNotifierProvider.autoDispose<CustomerCartNotifier, CustomerCartState>(
      (ref) => CustomerCartNotifier(),
    );

enum CustomerCartStatus { initial, loading, success, failure }

class CustomerCartState extends Equatable {
  const CustomerCartState({
    this.status = CustomerCartStatus.initial,
    this.items = const [],
    this.message = '',
  });

  final CustomerCartStatus status;
  final List<CartItem> items;
  final String message;

  CustomerCartState copyWith({
    CustomerCartStatus? status,
    List<CartItem>? items,
    String? message,
  }) {
    return CustomerCartState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}

class CustomerCartNotifier extends StateNotifier<CustomerCartState> {
  CustomerCartNotifier() : super(const CustomerCartState()) {
    initialize();
  }

  void initialize() {
    state = state.copyWith(status: CustomerCartStatus.loading);
    final dummyItems = [
      const CartItem(
        id: '1',
        name: 'Veggie tomato mix',
        price: '#1,900',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        quantity: 1,
      ),
      const CartItem(
        id: '2',
        name: 'Fishwith mix orange....',
        price: '#1,900',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        quantity: 1,
      ),
    ];
    state = state.copyWith(
      status: CustomerCartStatus.success,
      items: dummyItems,
    );
  }

  void updateItem(String id, int quantity) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(quantity: quantity.clamp(1, 99));
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void removeItem(String id) {
    final updatedItems = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: updatedItems);
  }
}
