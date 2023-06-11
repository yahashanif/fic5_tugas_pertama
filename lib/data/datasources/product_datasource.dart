import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_ecatalog/data/models/request/product_request_model.dart';
import 'package:flutter_ecatalog/data/models/response/product_response_model.dart';
import 'package:http/http.dart' as http;

class ProductDataSource {
  Future<Either<String, List<ProductResponseModel>>> getAllProduct(
      {required int offset, required int limit}) async {
    Uri url = Uri.parse(
        'https://api.escuelajs.co/api/v1/products?offset=$offset&limit=$limit');
    final response = await http.get(url);
    print(url);
    if (response.statusCode == 200) {
      return Right(List<ProductResponseModel>.from(jsonDecode(response.body)
          .map((x) => ProductResponseModel.fromMap(x))));
    } else {
      return const Left('get product error');
    }
  }

  Future<Either<String, ProductResponseModel>> createProduct(
      ProductRequestModel model) async {
    final response = await http.post(
        Uri.parse('https://api.escuelajs.co/api/v1/products/'),
        body: model.toJson(),
        headers: {'Content-Type': 'application/json'});
    print(response);
    if (response.statusCode == 201) {
      return Right(ProductResponseModel.fromJson(response.body));
    } else {
      return const Left('error add product');
    }
  }

  Future<Either<String, ProductResponseModel>> updateProduct(
      ProductRequestModel model) async {
    final response = await http.put(
        Uri.parse('https://api.escuelajs.co/api/v1/products/${model.id!}'),
        body: model.toJson(),
        headers: {'Content-Type': 'application/json'});
    print(response.body);
    if (response.statusCode == 200) {
      return Right(ProductResponseModel.fromJson(response.body));
    } else {
      return const Left('error add product');
    }
  }
}
