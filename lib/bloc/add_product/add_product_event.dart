part of 'add_product_bloc.dart';

@immutable
abstract class AddProductEvent {}

class DoAddProductEvent extends AddProductEvent {
  final ProductRequestModel model;
  DoAddProductEvent({
    required this.model,
  });
}

class DoUpdateProductEvent extends AddProductEvent {
  final ProductRequestModel model;
  DoUpdateProductEvent({
    required this.model,
  });
}
