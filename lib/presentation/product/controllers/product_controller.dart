import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/core/utils/snackbar_service.dart';
import 'package:staffora/data/models/api_models/product/posts_model.dart';
import 'package:staffora/domain/usecases/create_product_usecase.dart';
import '../../../data/models/api_models/product/product_model.dart';
import '../../../data/repositories/product_repository.dart';

class ProductController extends GetxController {
  // final repo = ProductRepository();
  final CreateProductUseCase createProductUseCase;

  ProductController(this.createProductUseCase);
  var isLoading = false.obs;
  var posts = <PostsModel>[].obs;
  var fetchSuccess = false.obs; // NEW FLAG

  Future<void> createProduct(
      {required String name,
      required String price,
      required String description,
      required BuildContext context}) async {
    try {
      isLoading.value = true;

      final product = ProductModel(
        name: name,
        price: double.parse(price),
        description: description,
      );

      final result = await createProductUseCase.execute(product);

      if (result.isSuccess) {
        SnackbarService.showSuccess(context, "Product created successfully");
        // ignore: use_build_context_synchronously
        if (context.mounted) {
          // After successful product creation, navigate to Users screen
          context.go("/users/allusers");
        }
      } else {
        SnackbarService.showError(context, "Unable to create product");
      }
    } catch (e) {
      AppLogger.error(e.toString());
      SnackbarService.showError(context, "Error: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Future<bool> getProducts({required BuildContext context}) async {
  //   try {
  //     isLoading.value = true;
  //     final results =
  //         await createProductUseCase.getPosts(); // raw JSON List<dynamic>
  //     if (results.isNotEmpty) {
  //       // Store posts locally; leave navigation decisions to the UI layer
  //       posts.assignAll(results);
  //       fetchSuccess.value = true;
  //       return true; // indicate success to caller
  //     } else {
  //       fetchSuccess.value = false;
  //     }
  //   } catch (e) {
  //     fetchSuccess.value = false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  //   return false;
  // }
}
