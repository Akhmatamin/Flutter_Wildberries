import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/api_client.dart';
import '../models/product.dart';
import '../repositories/catalog_repository.dart';
import 'category_bloc.dart' show LoadStatus;

sealed class ProductListEvent {}

class ProductsRequested extends ProductListEvent {}

class ProductsNextPageRequested extends ProductListEvent {}

class ProductsSearchChanged extends ProductListEvent {
  final String query;
  ProductsSearchChanged(this.query);
}

class ProductsOrderingChanged extends ProductListEvent {
  final String? ordering;
  ProductsOrderingChanged(this.ordering);
}

class ProductsOriginalToggled extends ProductListEvent {}

class ProductsSubCategoryChanged extends ProductListEvent {
  final int? subCategoryId;
  ProductsSubCategoryChanged(this.subCategoryId);
}

class ProductListState extends Equatable {
  final LoadStatus status;
  final List<Product> products;
  final bool hasMore;
  final bool isLoadingMore;
  final String query;
  final String? ordering;
  final bool originalOnly;
  final int? subCategoryId;
  final String? error;

  const ProductListState({
    this.status = LoadStatus.loading,
    this.products = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.query = '',
    this.ordering,
    this.originalOnly = false,
    this.subCategoryId,
    this.error,
  });

  ProductListState copyWith({
    LoadStatus? status,
    List<Product>? products,
    bool? hasMore,
    bool? isLoadingMore,
    String? query,
    String? ordering,
    bool clearOrdering = false,
    bool? originalOnly,
    int? subCategoryId,
    String? error,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
      ordering: clearOrdering ? null : (ordering ?? this.ordering),
      originalOnly: originalOnly ?? this.originalOnly,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    hasMore,
    isLoadingMore,
    query,
    ordering,
    originalOnly,
    subCategoryId,
    error,
  ];
}

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final CatalogRepository repository;

  ProductListBloc(this.repository, {int? subCategoryId})
    : super(ProductListState(subCategoryId: subCategoryId)) {
    on<ProductsRequested>(_onRefresh, transformer: restartable());
    on<ProductsSearchChanged>(_onSearch, transformer: restartable());
    on<ProductsOrderingChanged>(_onOrdering, transformer: restartable());
    on<ProductsOriginalToggled>(_onOriginal, transformer: restartable());
    on<ProductsSubCategoryChanged>(_onSubCategory, transformer: restartable());

    on<ProductsNextPageRequested>(_onNextPage, transformer: droppable());
  }

  Future<void> _loadFirstPage(
    ProductListState filters,
    Emitter<ProductListState> emit,
  ) async {
    emit(
      filters.copyWith(
        status: LoadStatus.loading,
        products: [],
        hasMore: false,
      ),
    );
    try {
      final page = await repository.getProducts(
        subCategoryId: filters.subCategoryId,
        search: filters.query,
        ordering: filters.ordering,
        originalOnly: filters.originalOnly,
      );
      emit(
        filters.copyWith(
          status: LoadStatus.success,
          products: page.items,
          hasMore: page.hasMore,
        ),
      );
    } on ApiException catch (e) {
      emit(filters.copyWith(status: LoadStatus.failure, error: e.message));
    }
  }

  Future<void> _onRefresh(
    ProductsRequested event,
    Emitter<ProductListState> emit,
  ) => _loadFirstPage(state, emit);

  Future<void> _onSearch(
    ProductsSearchChanged event,
    Emitter<ProductListState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _loadFirstPage(state.copyWith(query: event.query.trim()), emit);
  }

  Future<void> _onOrdering(
    ProductsOrderingChanged event,
    Emitter<ProductListState> emit,
  ) {
    return _loadFirstPage(
      event.ordering == null
          ? state.copyWith(clearOrdering: true)
          : state.copyWith(ordering: event.ordering),
      emit,
    );
  }

  Future<void> _onOriginal(
    ProductsOriginalToggled event,
    Emitter<ProductListState> emit,
  ) {
    return _loadFirstPage(
      state.copyWith(originalOnly: !state.originalOnly),
      emit,
    );
  }

  Future<void> _onSubCategory(
    ProductsSubCategoryChanged event,
    Emitter<ProductListState> emit,
  ) {
    return _loadFirstPage(
      state.copyWith(subCategoryId: event.subCategoryId),
      emit,
    );
  }

  Future<void> _onNextPage(
    ProductsNextPageRequested event,
    Emitter<ProductListState> emit,
  ) async {
    if (!state.hasMore || state.status != LoadStatus.success) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final page = await repository.getProducts(
        offset: state.products.length,
        subCategoryId: state.subCategoryId,
        search: state.query,
        ordering: state.ordering,
        originalOnly: state.originalOnly,
      );
      emit(
        state.copyWith(
          products: [...state.products, ...page.items],
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on ApiException {
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
