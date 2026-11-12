import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/category_bloc.dart';
import '../blocs/product_list_bloc.dart';
import '../core/theme.dart';
import '../widgets/app_image.dart';
import '../widgets/product_grid.dart';
import 'category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.gradient),
          padding: EdgeInsets.fromLTRB(
            12,
            MediaQuery.of(context).padding.top + 8,
            12,
            12,
          ),
          child: TextField(
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Поиск по названию или артикулу',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),

            onChanged: (text) => context.read<ProductListBloc>().add(
              ProductsSearchChanged(text),
            ),
          ),
        ),
        const _CategoryStrip(),
        const FilterChips(),
        const Expanded(child: ProductGrid()),
      ],
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 96,
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state.status == LoadStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == LoadStatus.failure) {
            return Center(
              child: TextButton(
                onPressed: () =>
                    context.read<CategoryBloc>().add(CategoriesRequested()),
                child: const Text('Не удалось загрузить категории. Повторить'),
              ),
            );
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: state.categories.length,
            itemBuilder: (context, i) {
              final category = state.categories[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryScreen(category: category),
                  ),
                ),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: AppImage(category.imageUrl),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  static const _sortOptions = {
    null: 'По умолчанию',
    'price': 'Сначала дешевле',
    '-price': 'Сначала дороже',
    '-date_added': 'Сначала новые',
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      buildWhen: (a, b) =>
          a.ordering != b.ordering || a.originalOnly != b.originalOnly,
      builder: (context, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: [
              PopupMenuButton<String?>(
                onSelected: (value) => context.read<ProductListBloc>().add(
                  ProductsOrderingChanged(value),
                ),
                itemBuilder: (_) => [
                  for (final entry in _sortOptions.entries)
                    PopupMenuItem(value: entry.key, child: Text(entry.value)),
                ],
                child: Chip(
                  avatar: const Icon(Icons.sort, size: 18),
                  label: Text(_sortOptions[state.ordering] ?? 'Сортировка'),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Оригинал'),
                selected: state.originalOnly,
                onSelected: (_) => context.read<ProductListBloc>().add(
                  ProductsOriginalToggled(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
