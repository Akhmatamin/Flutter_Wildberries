import 'package:flutter_test/flutter_test.dart';
import 'package:wb_shop/models/cart_item.dart';
import 'package:wb_shop/models/product.dart';

void main() {
  final productJson = {
    'id': 1,
    'images': [
      {'product_img': 'http://host/media/a.jpg'},
    ],
    'product_name': 'Кроссовки',
    'price': 2500,
    'original': true,
    'get_avg_rating': 4.5,
    'get_count_user': 3,
  };

  test('Product.fromJson parses list item', () {
    final p = Product.fromJson(productJson);
    expect(p.name, 'Кроссовки');
    expect(p.mainImage, 'http://host/media/a.jpg');
    expect(p.rating, 4.5);
  });

  test('Rating given as int 0 does not crash', () {
    final p = Product.fromJson({...productJson, 'get_avg_rating': 0});
    expect(p.rating, 0.0);
  });

  test('CartItem total price = price * quantity', () {
    final item = CartItem.fromJson({
      'id': 7,
      'product': productJson,
      'quantity': 3,
    });
    expect(item.totalPrice, 7500);
  });
}
