import 'dart:async';

import 'package:staffora/data/models/api_models/product/posts_model.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_routes.dart';
import '../models/api_models/product/product_model.dart';

class ProductRepository {
  final ApiClient _client = ApiClient();

  Future<bool> createProduct(ProductModel product) async {
    final result = await _client.post(ApiRoutes.createProduct, product.toJson(),
        useToken: false);
    return result["success"] == true;
  }

  Future<List<PostsModel>> getPosts() async {
    final result = await _client.get(
      "https://jsonplaceholder.typicode.com/posts",
      useToken: false,
    );

    // Convert List<dynamic> → List<PostsModel>
    return (result as List).map((json) => PostsModel.fromJson(json)).toList();
  }

  Future<List<PostsModel>> getAllUsers() async {
    print(ApiRoutes.allusers);
    final result = await _client.get(
      // ApiRoutes.allusers,
      "https://jsonplaceholder.typicode.com/posts",
      useToken: false,
    );
    // Prevent infinite hanging / spinner
    // .timeout(const Duration(seconds: 10));

    // Convert List<dynamic> → List<PostsModel>
    return (result as List).map((json) => PostsModel.fromJson(json)).toList();
  }
}
