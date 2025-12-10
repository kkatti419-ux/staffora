// import 'package:staffora/core/utils/result.dart';
// import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';
// import 'package:staffora/domain/repositories/i_profile_repository.dart';

// class ProfileUsecase {
//   final IProfileRepository repository;

//   ProfileUsecase({required this.repository});

//   Future<Result<bool>> updateProfile(UserProfile userProfile) async {
//     try {
//       // Business logic validation
//       // if (product.name.isEmpty) {
//       //   return Result.error("Product name cannot be empty");
//       // }

//       // if (product.price <= 0) {
//       //   return Result.error("Price must be greater than 0");
//       // }

//       // if (product.description.isEmpty) {
//       //   return Result.error("Product description cannot be empty");
//       // }

//       // Delegate to repository
//       final result = await repository.updateProfile(userProfile);

//       if (result) {
//         return Result.success(result);
//       } else {
//         return Result.error("Failed to create product");
//       }
//     } catch (e) {
//       return Result.error("An error occurred: ${e.toString()}");
//     }
//   }

//   Future<Result<UserProfile>> getprofileDetails() async {
//     try {
//       // Delegate to repository
//       final result = await repository.getProfileDetails();

//       if (result != null) {
//         return Result.success(result);
//       } else {
//         return Result.error("Failed to create product");
//       }
//     } catch (e) {
//       return Result.error("An error occurred: ${e.toString()}");
//     }
//   }
// }
