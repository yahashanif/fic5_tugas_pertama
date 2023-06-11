// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'products_bloc.dart';

@immutable
abstract class ProductsEvent {}

class GetProductsEvent extends ProductsEvent {
  int? offset;
  int? limit;
  GetProductsEvent({
    this.offset = 0,
    this.limit = 10,
  });
}
