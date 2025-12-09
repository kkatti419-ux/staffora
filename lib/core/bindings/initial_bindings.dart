import 'package:get/get.dart';
import 'package:staffora/data/repositories/product_repository.dart';
import 'package:staffora/domain/repositories/i_product_repository.dart';
import 'package:staffora/domain/usecases/create_product_usecase.dart';
import 'package:staffora/presentation/product/controllers/product_controller.dart';
import '../theme/theme_controller.dart';
import '../../presentation/auth/controllers/auth_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // 1️⃣ Register Repository
    Get.lazyPut<IProductRepository>(() => ProductRepository());

    // 2️⃣ Register Use Case
    Get.lazyPut(() => CreateProductUseCase(Get.find<IProductRepository>()));

    // 3️⃣ Register Controller
    Get.put(ProductController(Get.find<CreateProductUseCase>()),
        permanent: true);

    // Other global controllers
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}
