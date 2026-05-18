import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void addItem(CartItem item) {
    debugPrint('addItem: ${item.name}, imageUrl: ${item.imageUrl}');
    final existing = state.items.indexWhere((i) => i.id == item.id);
    if (existing != -1) {
      final updated = state.items.toList();
      updated[existing] = updated[existing].copyWith(
        quantity: updated[existing].quantity + item.quantity,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  void updateItem(int id, int quantity) {
    final updated = state.items.map((item) {
      if (item.id == id) return item.copyWith(quantity: quantity.clamp(1, 99));
      return item;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void removeItem(int id) {
    debugPrint('removeItem: id=$id');
    final updated = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: updated);
  }
}

final customerCartProvider =
    NotifierProvider<CustomerCartNotifier, CustomerCartState>(
      CustomerCartNotifier.new,
    );
