import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/cart_bloc.dart';
import '../blocs/category_bloc.dart' show LoadStatus;
import '../blocs/product_detail_bloc.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../repositories/catalog_repository.dart';
import '../widgets/app_image.dart';
import '../widgets/error_view.dart';
import '../widgets/rating_row.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductDetailBloc(context.read<CatalogRepository>(), productId)
            ..add(ProductDetailRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Товар')),
        body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            switch (state.status) {
              case LoadStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case LoadStatus.failure:
                return ErrorView(
                  message: state.error ?? 'Ошибка',
                  onRetry: () => context.read<ProductDetailBloc>().add(
                    ProductDetailRequested(),
                  ),
                );
              case LoadStatus.success:
                return _Content(product: state.product!);
            }
          },
        ),
        bottomNavigationBar: _BottomBar(productId: productId),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ProductDetail product;

  const _Content({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _ImageCarousel(images: product.images),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatPrice(product.price),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(product.name, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Row(
                children: [
                  RatingRow(
                    rating: product.rating,
                    count: product.reviews.length,
                  ),
                  const Spacer(),
                  if (product.original)
                    const Chip(
                      label: Text('Оригинал'),
                      avatar: Icon(
                        Icons.verified,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Артикул: ${product.articleNum}',
                style: const TextStyle(color: AppColors.grey),
              ),
              Text(
                'Категория: ${product.subCategory}',
                style: const TextStyle(color: AppColors.grey),
              ),
              Text(
                'Добавлен: ${product.dateAdded}',
                style: const TextStyle(color: AppColors.grey),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 8),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Описание',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(product.description),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Отзывы (${product.reviews.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (product.reviews.isEmpty)
                const Text(
                  'Пока нет отзывов',
                  style: TextStyle(color: AppColors.grey),
                ),
              for (final review in product.reviews) _ReviewTile(review: review),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> images;

  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox(height: 320, child: AppImage(null));
    }
    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) =>
                AppImage(widget.images[i], fit: BoxFit.contain),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.images.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page
                          ? AppColors.primary
                          : Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.author,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                review.date,
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ],
          ),

          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: AppColors.star,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(review.comment),
          const Divider(),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int productId;

  const _BottomBar({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final quantity = state.quantityOf(productId);
          if (quantity == 0) {
            return FilledButton(
              onPressed: () =>
                  context.read<CartBloc>().add(CartProductAdded(productId)),
              child: const Text('Добавить в корзину'),
            );
          }
          final item = state.items.firstWhere((i) => i.product.id == productId);
          return Row(
            children: [
              IconButton.outlined(
                onPressed: () => quantity > 1
                    ? context.read<CartBloc>().add(
                        CartQuantityChanged(item, quantity - 1),
                      )
                    : context.read<CartBloc>().add(CartItemRemoved(item)),
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton.outlined(
                onPressed: () => context.read<CartBloc>().add(
                  CartQuantityChanged(item, quantity + 1),
                ),
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'В корзине',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
