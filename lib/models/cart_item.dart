import 'package:equatable/equatable.dart';

import 'product.dart';

class CartItem extends Equatable {
  final int id;
  final Product product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  int get totalPrice => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    product: Product.fromJson(json['product']),
    quantity: json['quantity'] ?? 1,
  );

  @override
  List<Object?> get props => [id, product, quantity];
}
