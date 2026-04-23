import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item.dart';
import 'customer_cart_event.dart';
import 'customer_cart_state.dart';

class CustomerCartBloc extends Bloc<CustomerCartEvent, CustomerCartState> {
  CustomerCartBloc() : super(const CustomerCartState()) {
    on<CustomerCartStarted>(_onStarted);
    on<CustomerCartItemUpdated>(_onItemUpdated);
    on<CustomerCartItemRemoved>(_onItemRemoved);
  }

  void _onStarted(CustomerCartStarted event, Emitter<CustomerCartState> emit) {
    emit(state.copyWith(status: CustomerCartStatus.loading));
    final dummyItems = [
      const CartItem(
        id: '1',
        name: 'Veggie tomato mix',
        price: '#1,900',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        quantity: 1,
      ),
      const CartItem(
        id: '2',
        name: 'Fishwith mix orange....',
        price: '#1,900',
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        quantity: 1,
      ),
    ];
    emit(state.copyWith(status: CustomerCartStatus.success, items: dummyItems));
  }

  void _onItemUpdated(CustomerCartItemUpdated event, Emitter<CustomerCartState> emit) {
    final updatedItems = state.items.map((item) {
      if (item.id == event.id) {
        return item.copyWith(quantity: event.quantity.clamp(1, 99));
      }
      return item;
    }).toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onItemRemoved(CustomerCartItemRemoved event, Emitter<CustomerCartState> emit) {
    final updatedItems = state.items.where((item) => item.id != event.id).toList();
    emit(state.copyWith(items: updatedItems));
  }
}
