import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/product_list_bloc.dart';
import '../core/api_client.dart';
import '../models/category.dart';
import '../repositories/catalog_repository.dart';
import '../widgets/error_view.dart';
import '../widgets/product_grid.dart';
import 'home_screen.dart' show FilterChips;

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<SubCategory>> _subCategories;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _subCategories = context.read<CatalogRepository>().getSubCategories(
      widget.category.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: FutureBuilder<List<SubCategory>>(
        future: _subCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return ErrorView(
              message: error is ApiException ? error.message : 'Ошибка',
              onRetry: () => setState(_load),
            );
          }
          final subs = snapshot.data!;
          if (subs.isEmpty) {
            return const EmptyView(
              icon: Icons.category_outlined,
              text: 'В категории нет подкатегорий',
            );
          }
          _selectedId ??= subs.first.id;

          return BlocProvider(
            create: (context) => ProductListBloc(
              context.read<CatalogRepository>(),
              subCategoryId: _selectedId,
            )..add(ProductsRequested()),
            child: Builder(
              builder: (context) {
                return Column(
                  children: [
                    Container(
                      color: Colors.white,
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          for (final sub in subs)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                label: Text(sub.name),
                                selected: _selectedId == sub.id,
                                onSelected: (_) {
                                  setState(() => _selectedId = sub.id);
                                  context.read<ProductListBloc>().add(
                                    ProductsSubCategoryChanged(sub.id),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const FilterChips(),
                    const Expanded(child: ProductGrid()),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
