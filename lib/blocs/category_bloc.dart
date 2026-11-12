import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/api_client.dart';
import '../models/category.dart';
import '../repositories/catalog_repository.dart';

sealed class CategoryEvent {}

class CategoriesRequested extends CategoryEvent {}

enum LoadStatus { loading, success, failure }

class CategoryState extends Equatable {
  final LoadStatus status;
  final List<Category> categories;
  final String? error;

  const CategoryState({
    this.status = LoadStatus.loading,
    this.categories = const [],
    this.error,
  });

  @override
  List<Object?> get props => [status, categories, error];
}

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CatalogRepository repository;

  CategoryBloc(this.repository) : super(const CategoryState()) {
    on<CategoriesRequested>((event, emit) async {
      emit(const CategoryState(status: LoadStatus.loading));
      try {
        final list = await repository.getCategories();
        emit(CategoryState(status: LoadStatus.success, categories: list));
      } on ApiException catch (e) {
        emit(CategoryState(status: LoadStatus.failure, error: e.message));
      }
    });
  }
}
