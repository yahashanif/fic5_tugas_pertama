// To parse this JSON data, do
//
//     final productRequestModel = productRequestModelFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class ProductRequestModel {
  int? id;
  final String title;
  final int price;
  final String description;
  final int categoryId;
  final List<String> images;
  int? offset;
  int? limit;

  ProductRequestModel(
      {required this.title,
      required this.price,
      required this.description,
      this.categoryId = 1,
      this.id,
      this.images = const ['https://placeimg.com/640/480/any'],
      this.offset = 0,
      this.limit = 10});

  factory ProductRequestModel.fromJson(String str) =>
      ProductRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductRequestModel.fromMap(Map<String, dynamic> json) =>
      ProductRequestModel(
        id: json["id"],
        title: json["title"],
        price: json["price"],
        description: json["description"],
        categoryId: json["categoryId"],
        images: List<String>.from(json["images"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "price": price,
        "description": description,
        "categoryId": categoryId,
        "images": List<dynamic>.from(images.map((x) => x)),
      };
}
