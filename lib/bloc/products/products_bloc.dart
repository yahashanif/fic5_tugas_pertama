import 'package:bloc/bloc.dart';
import 'package:flutter_ecatalog/data/models/request/get_product_request_model.dart';
import 'package:meta/meta.dart';

import 'package:flutter_ecatalog/data/datasources/product_datasource.dart';
import 'package:flutter_ecatalog/data/models/response/product_response_model.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductDataSource dataSource;
  ProductsBloc(
    this.dataSource,
  ) : super(ProductsInitial()) {
    on<GetProductsEvent>((event, emit) async {
      if (state is ProductsLoading) return;
      final currentState = state;
      var oldList = <ProductResponseModel>[];
      if (currentState is ProductsLoaded) {
        oldList = event.offset == 0 ? [] : currentState.data;
      }
      emit(ProductsLoading(data: oldList));

      final result = await dataSource.getAllProduct(
          offset: event.offset!, limit: event.limit!);
      List<ProductResponseModel> listData = [];
      listData = oldList;
      result.fold((error) => emit(ProductsError(message: error)), (result) {
        listData.addAll(result);
        return emit(ProductsLoaded(data: listData));
      });
    });
  }
}
