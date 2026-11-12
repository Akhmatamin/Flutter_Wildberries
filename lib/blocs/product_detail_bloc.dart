import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/api_client.dart';
import '../models/product.dart';
import '../repositories/catalog_repository.dart';
import 'category_bloc.dart' show LoadStatus;

sealed class ProductDetailEvent {}

class ProductDetailRequested extends ProductDetailEvent {}

class ProductDetailState extends Equatable {
  final LoadStatus status;
  final ProductDetail? product;
  final String? error;

  const ProductDetailState({
    this.status = LoadStatus.loading,
    this.product,
    this.error,
  });

  @override
  List<Object?> get props => [status, product, error];
}

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final CatalogRepository repository;
  final int productId;

  ProductDetailBloc(this.repository, this.productId)
    : super(const ProductDetailState()) {
    on<ProductDetailRequested>((event, emit) async {
      emit(const ProductDetailState(status: LoadStatus.loading));
      try {
        final product = await repository.getProduct(productId);
        emit(ProductDetailState(status: LoadStatus.success, product: product));
      } on ApiException catch (e) {
        emit(ProductDetailState(status: LoadStatus.failure, error: e.message));
      }
    });
  }
}
