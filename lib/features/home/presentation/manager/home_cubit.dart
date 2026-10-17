import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import '../../domain/use_cases/get_products_use_case.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeStates> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsUseCase getProductsUseCase;
  final int limit = 10;
  int offset = 0;

  bool loadingMore = false;
  bool hasMore = true;
  int? selectedCategory;
  final List<ProductEntity> _products = [];

  HomeCubit({required this.getProductsUseCase, required this.getCategoriesUseCase})
    : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(CategoriesLoading());

    final categoriesResult = await getCategoriesUseCase.invoke();

    final categories = categoriesResult.fold(
      (failure) {
        emit(CategoriesError(failure.failureMessage));
        return null;
      },
      (categories) {
        emit(CategoriesSuccess(categories));
        return categories;
      },
    );

    if (categories == null || categories.isEmpty) return;

    await getProductsByCategoryId(categories.first.id);
  }

  Future<void> getProductsByCategoryId(int id) async {
    emit(ProductsLoading());
    hasMore = true;
    _products.clear();

    final result = await getProductsUseCase.invoke(id, limit: limit, offset: offset);

    result.fold(
      (failure) {
        emit(ProductsError(failure.failureMessage));
      },
      (products) {
        _products.addAll(products);
        offset = products.length;
        if (products.length < limit) {
          hasMore = false;
        }
        selectedCategory = id;
        emit(ProductsSuccess(List.from(_products)));
      },
    );
  }

  Future<void> loadMoreProduts() async {
    if (loadingMore || !hasMore) return;
    loadingMore = true;
    emit(ProductsLoadingMore());
    final result = await getProductsUseCase.invoke(
      selectedCategory,
      limit: limit,
      offset: offset,
    );

    result.fold(
      (failure) {
        emit(ProductsErrorMore(failure.failureMessage));
      },
      (newProducts) {
        _products.addAll(newProducts);
        offset += newProducts.length;
        if (newProducts.length < limit) {
          hasMore = false;
        }
        emit(ProductsSuccess(_products));
      },
    );
  }
}
