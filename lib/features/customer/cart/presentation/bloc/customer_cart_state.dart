import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

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
