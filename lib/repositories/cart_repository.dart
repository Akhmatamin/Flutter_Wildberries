import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/cart_item.dart';

class CartRepository {
  final ApiClient api;

  CartRepository(this.api);

  Future<List<CartItem>> getItems() {
    return api.run(() async {
      final response = await api.dio.get(
        'cart_items/',
        queryParameters: {'limit': AppConfig.bigLimit},
      );
      return resultsOf(response.data).map((e) => CartItem.fromJson(e)).toList();
    });
  }

  Future<void> add(int productId, {int quantity = 1}) {
    return api.run(() async {
      await api.dio.post(
        'cart_items/',
        data: {'product_id': productId, 'quantity': quantity},
      );
    });
  }

  Future<void> updateQuantity(CartItem item, int quantity) {
    return api.run(() async {
      await api.dio.put(
        'Cart_items/${item.id}/',
        data: {'product_id': item.product.id, 'quantity': quantity},
      );
    });
  }

  Future<void> remove(int itemId) {
    return api.run(() async {
      await api.dio.delete('Cart_items/$itemId/');
    });
  }
}
