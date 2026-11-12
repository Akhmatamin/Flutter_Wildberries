class Category {
  final int id;
  final String name;
  final String imageUrl;

  Category({required this.id, required this.name, required this.imageUrl});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['category_name'] ?? '',
    imageUrl: json['category_img'] ?? '',
  );
}

class SubCategory {
  final int id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) =>
      SubCategory(id: json['id'], name: json['sub_category_name'] ?? '');
}
