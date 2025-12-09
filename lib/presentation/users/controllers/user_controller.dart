import 'package:get/get.dart';
import 'package:staffora/data/models/api_models/product/posts_model.dart';
import '../../../data/repositories/product_repository.dart';

class UserController extends GetxController {
  final repo = ProductRepository();
  var isLoading = false.obs;
  var users = <PostsModel>[].obs; // store fetched users
  var fetchSuccess = false.obs; // NEW FLAG

  @override
  void onInit() {
    super.onInit();
    getAllUsers(); // no context here
  }

  Future<void> getAllUsers() async {
    try {
      isLoading.value = true;
      final results = await repo.getAllUsers();

      if (results.isNotEmpty) {
        users.assignAll(results);
        fetchSuccess.value = true; // notify UI
      } else {
        fetchSuccess.value = false;
      }
    } catch (e) {
      fetchSuccess.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
