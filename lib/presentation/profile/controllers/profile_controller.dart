// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:staffora/core/utils/logger.dart';
// import 'package:staffora/core/utils/snackbar_service.dart';
// import 'package:staffora/data/models/api_models/product/posts_model.dart';
// import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';
// import 'package:staffora/domain/usecases/profile_usecase.dart';

// class ProfileController extends GetxController {
//   final ProfileUsecase profileUsecase;

//   ProfileController(this.profileUsecase);
//   var isLoading = false.obs;
//   var posts = <PostsModel>[].obs;
//   var fetchSuccess = false.obs; // NEW FLAG

//   Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
//   @override
//   void onInit() {
//     super.onInit();
//     loadProfile(); // fetch automatically
//   }

//   Future<void> fetchProfileDetails({required BuildContext context}) async {
//     try {
//       isLoading.value = true;

//       final result = await profileUsecase.getprofileDetails();

//       if (result.isSuccess) {
//         SnackbarService.showSuccess(context, "Product created successfully");
//         // ignore: use_build_context_synchronously
//         if (context.mounted) {
//           // After successful product creation, navigate to Users screen
//           context.go("/users/allusers");
//         }
//       } else {
//         SnackbarService.showError(context, "Unable to create product");
//       }
//     } catch (e) {
//       AppLogger.error(e.toString());
//       SnackbarService.showError(context, "Error: ${e.toString()}");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> loadProfile() async {
//     try {
//       isLoading.value = true;

//       final result = await profileUsecase.getprofileDetails();

//       if (result.isSuccess) {
//         userProfile.value = result.data;
//       }

//       isLoading.value = false;
//     } catch (e) {
//       print("Error loading profile: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<bool> updateUserProfile({
//     required UserProfile profile,
//     required BuildContext context,
//   }) async {
//     try {
//       isLoading.value = true;

//       final result = await profileUsecase.updateProfile(profile);

//       if (result.isSuccess) {
//         // Update the local profile data
//         userProfile.value = profile;
//         SnackbarService.showSuccess(context, "Profile updated successfully!");
//         return true;
//       } else {
//         SnackbarService.showError(context, result.error ?? "Failed to update profile");
//         return false;
//       }
//     } catch (e) {
//       AppLogger.error("Error updating profile: $e");
//       SnackbarService.showError(context, "Error: ${e.toString()}");
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }


//   // Future<bool> getProducts({required BuildContext context}) async {
//   //   try {
//   //     isLoading.value = true;
//   //     final results =
//   //         await createProductUseCase.getPosts(); // raw JSON List<dynamic>
//   //     if (results.isNotEmpty) {
//   //       // Store posts locally; leave navigation decisions to the UI layer
//   //       posts.assignAll(results);
//   //       fetchSuccess.value = true;
//   //       return true; // indicate success to caller
//   //     } else {
//   //       fetchSuccess.value = false;
//   //     }
//   //   } catch (e) {
//   //     fetchSuccess.value = false;
//   //   } finally {
//   //     isLoading.value = false;
//   //   }
//   //   return false;
//   // }
// // }
