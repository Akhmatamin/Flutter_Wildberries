import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/category_bloc.dart' show LoadStatus;
import '../blocs/product_list_bloc.dart';
import 'error_view.dart';
import 'product_card.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      context.read<ProductListBloc>().add(ProductsNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      builder: (context, state) {
        if (state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == LoadStatus.failure) {
          return ErrorView(
            message: state.error ?? 'Ошибка',
            onRetry: () =>
                context.read<ProductListBloc>().add(ProductsRequested()),
          );
        }
        if (state.products.isEmpty) {
          return const EmptyView(
            icon: Icons.search_off,
            text: 'Ничего не найдено',
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              context.read<ProductListBloc>().add(ProductsRequested()),
          child: CustomScrollView(
            controller: _scroll,

            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: state.products.length,
                  itemBuilder: (_, i) =>
                      ProductCard(product: state.products[i]),
                ),
              ),
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
