import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/api_client.dart';
import '../models/cart_item.dart';
import '../repositories/cart_repository.dart';
import 'category_bloc.dart' show LoadStatus;

sealed class CartEvent {}

class CartRequested extends CartEvent {}

class CartProductAdded extends CartEvent {
  final int productId;
  CartProductAdded(this.productId);
}

class CartQuantityChanged extends CartEvent {
  final CartItem item;
  final int quantity;
  CartQuantityChanged(this.item, this.quantity);
}

class CartItemRemoved extends CartEvent {
  final CartItem item;
  CartItemRemoved(this.item);
}

class CartState extends Equatable {
  final LoadStatus status;
  final List<CartItem> items;
  final String? error;

  final String? message;
  final int messageId;

  const CartState({
    this.status = LoadStatus.loading,
    this.items = const [],
    this.error,
    this.message,
    this.messageId = 0,
  });

  int get totalPrice => items.fold(0, (sum, i) => sum + i.totalPrice);

  int get totalCount => items.fold(0, (sum, i) => sum + i.quantity);

  int quantityOf(int productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  @override
  List<Object?> get props => [status, items, error, message, messageId];
}

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc(this.repository) : super(const CartState()) {
    on<CartRequested>(_onRequested);
    on<CartProductAdded>(_onAdded);
    on<CartQuantityChanged>(_onQuantityChanged);
    on<CartItemRemoved>(_onRemoved);
  }

  Future<void> _onRequested(
    CartRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartState(status: LoadStatus.loading));
    try {
      final items = await repository.getItems();
      emit(CartState(status: LoadStatus.success, items: items));
    } on ApiException catch (e) {
      emit(CartState(status: LoadStatus.failure, error: e.message));
    }
  }

  Future<void> _onAdded(CartProductAdded event, Emitter<CartState> emit) async {
    await _change(emit, 'Товар добавлен в корзину', () async {
      final existing = state.items.where(
        (i) => i.product.id == event.productId,
      );
      if (existing.isNotEmpty) {
        await repository.updateQuantity(
          existing.first,
          existing.first.quantity + 1,
        );
      } else {
        await repository.add(event.productId);
      }
    });
  }

  Future<void> _onQuantityChanged(
    CartQuantityChanged event,
    Emitter<CartState> emit,
  ) async {
    if (event.quantity < 1) return;
    await _change(
      emit,
      null,
      () => repository.updateQuantity(event.item, event.quantity),
    );
  }

  Future<void> _onRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    emit(
      CartState(
        status: LoadStatus.success,
        items: state.items.where((i) => i.id != event.item.id).toList(),
        messageId: state.messageId,
      ),
    );
    await _change(emit, null, () => repository.remove(event.item.id));
  }

  Future<void> _change(
    Emitter<CartState> emit,
    String? successMessage,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      final items = await repository.getItems();
      emit(
        CartState(
          status: LoadStatus.success,
          items: items,
          message: successMessage,
          messageId: state.messageId + 1,
        ),
      );
    } on ApiException catch (e) {
      var items = state.items;
      try {
        items = await repository.getItems();
      } on ApiException {
        items = state.items;
      }
      emit(
        CartState(
          status: LoadStatus.success,
          items: items,
          message: e.message,
          messageId: state.messageId + 1,
        ),
      );
    }
  }
}
