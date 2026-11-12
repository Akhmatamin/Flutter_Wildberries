import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final int price;
  final bool original;
  final List<String> images;
  final double rating;
  final int reviewsCount;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.original,
    required this.images,
    required this.rating,
    required this.reviewsCount,
  });

  String? get mainImage => images.isEmpty ? null : images.first;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['product_name'] ?? '',
    price: json['price'] ?? 0,
    original: json['original'] ?? false,

    images: ((json['images'] ?? []) as List)
        .map((e) => e['product_img'] as String)
        .toList(),

    rating: (json['get_avg_rating'] as num? ?? 0).toDouble(),
    reviewsCount: json['get_count_user'] ?? 0,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    original,
    images,
    rating,
    reviewsCount,
  ];
}

class Review {
  final String author;
  final int rating;
  final String comment;
  final String date;

  Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final fullName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
        .trim();
    return Review(
      author: fullName.isEmpty ? 'Покупатель' : fullName,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      date: json['date_added'] ?? '',
    );
  }
}

class ProductDetail {
  final int id;
  final String name;
  final int price;
  final bool original;
  final List<String> images;
  final String subCategory;
  final String description;
  final int articleNum;
  final String dateAdded;
  final List<Review> reviews;

  ProductDetail({
    required this.id,
    required this.name,
    required this.price,
    required this.original,
    required this.images,
    required this.subCategory,
    required this.description,
    required this.articleNum,
    required this.dateAdded,
    required this.reviews,
  });

  double get rating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (s, r) => s + r.rating);
    return sum / reviews.length;
  }

  factory ProductDetail.fromJson(Map<String, dynamic> json) => ProductDetail(
    id: json['id'],
    name: json['product_name'] ?? '',
    price: json['price'] ?? 0,
    original: json['original'] ?? false,
    images: ((json['images'] ?? []) as List)
        .map((e) => e['product_img'] as String)
        .toList(),
    subCategory: (json['sub_category'] ?? {})['sub_category_name'] ?? '',
    description: json['description'] ?? '',
    articleNum: json['article_num'] ?? 0,
    dateAdded: json['date_added'] ?? '',
    reviews: ((json['all_reviews'] ?? []) as List)
        .map((e) => Review.fromJson(e))
        .toList(),
  );
}
