import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductPage {
  final List<Product> items;
  final bool hasMore;
  ProductPage(this.items, this.hasMore);
}

class CatalogRepository {
  final ApiClient api;

  CatalogRepository(this.api);

  Future<List<Category>> getCategories() {
    return api.run(() async {
      final response = await api.dio.get(
        'category/',
        queryParameters: {'limit': AppConfig.bigLimit},
      );
      return resultsOf(response.data).map((e) => Category.fromJson(e)).toList();
    });
  }

  Future<List<SubCategory>> getSubCategories(int categoryId) {
    return api.run(() async {
      final detail = await api.dio.get('category/$categoryId/');
      final names = ((detail.data['sub_categories'] ?? []) as List)
          .map((e) => e['sub_category_name'] as String)
          .toSet();

      final all = await api.dio.get(
        'sub_category/',
        queryParameters: {'limit': AppConfig.bigLimit},
      );
      return resultsOf(all.data)
          .map((e) => SubCategory.fromJson(e))
          .where((s) => names.contains(s.name))
          .toList();
    });
  }

  Future<ProductPage> getProducts({
    int offset = 0,
    int? subCategoryId,
    String search = '',
    String? ordering,
    bool originalOnly = false,
  }) {
    return api.run(() async {
      final response = await api.dio.get(
        'product/',
        queryParameters: {
          'limit': AppConfig.pageSize,
          'offset': offset,
          if (subCategoryId != null) 'sub_category': subCategoryId,
          if (search.isNotEmpty) 'search': search,
          if (ordering != null) 'ordering': ordering,
          if (originalOnly) 'original': true,
        },
      );
      final items = resultsOf(response.data)
          .map((e) => Product.fromJson(e))
          .toList();

      final hasMore = response.data is Map && response.data['next'] != null;
      return ProductPage(items, hasMore);
    });
  }

  Future<ProductDetail> getProduct(int id) {
    return api.run(() async {
      final response = await api.dio.get('product/$id/');
      return ProductDetail.fromJson(response.data);
    });
  }
}
