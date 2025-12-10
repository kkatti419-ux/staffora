import 'package:get/get.dart';
import 'package:staffora/data/firebase_services/firebase_auth_service.dart';
import 'package:staffora/data/firebase_services/firebase_profile_services.dart';
import 'package:staffora/data/repositories/auth_repository.dart';
import 'package:staffora/data/repositories/product_repository.dart';
import 'package:staffora/data/repositories/profile_repository.dart';
import 'package:staffora/domain/repositories/i_auth_repository.dart';
import 'package:staffora/domain/repositories/i_product_repository.dart';
import 'package:staffora/domain/repositories/i_profile_repository.dart';
import 'package:staffora/domain/usecases/auth_usecase.dart';
import 'package:staffora/domain/usecases/create_product_usecase.dart';
import 'package:staffora/domain/usecases/profile_usecase.dart';
import 'package:staffora/presentation/product/controllers/product_controller.dart';
import 'package:staffora/presentation/profile/controllers/profile_controller.dart';
import '../theme/theme_controller.dart';
import '../../presentation/auth/controllers/auth_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // ========== PRODUCT DEPENDENCIES ==========
    // 1️⃣ Register Product Repository
    Get.lazyPut<IProductRepository>(() => ProductRepository());

    // 2️⃣ Register Product Use Case
    Get.lazyPut(() => CreateProductUseCase(Get.find<IProductRepository>()));

    // 3️⃣ Register Product Controller
    Get.put(ProductController(Get.find<CreateProductUseCase>()),
        permanent: true);

    // ========== PROFILE DEPENDENCIES ==========
    // 1️⃣ Register Firebase Profile Services
    Get.lazyPut(() => FirebaseProfileServices());

    // 2️⃣ Register Profile Repository
    Get.lazyPut<IProfileRepository>(
        () => ProfileRepository(Get.find<FirebaseProfileServices>()));

    // 3️⃣ Register Profile Use Case
    Get.lazyPut(
        () => ProfileUsecase(repository: Get.find<IProfileRepository>()));

    // 4️⃣ Register Profile Controller
    Get.put(ProfileController(Get.find<ProfileUsecase>()), permanent: true);

    // ========== OTHER GLOBAL CONTROLLERS ==========
    Get.put(ThemeController(), permanent: true);
    // Get.put(AuthController(), permanent: true);

    // 0--------
    // 1️⃣ Firebase Auth Service
    Get.lazyPut(() => FirebaseAuthService());

// 2️⃣ Auth Repository
    Get.lazyPut<IAuthRepository>(
      () => AuthRepository(service: Get.find<FirebaseAuthService>()),
    );

// 3️⃣ Auth Usecase
    Get.lazyPut(() => AuthUsecase(repository: Get.find<IAuthRepository>()));

// 4️⃣ Auth Controller
    Get.put(AuthController(usecase: Get.find<AuthUsecase>()), permanent: true);
  }
}
