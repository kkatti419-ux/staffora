import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staffora/data/firebase_services/firebase_storage_service.dart';
import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';
import 'package:staffora/presentation/auth/controllers/auth_controller.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/presentation/profile/controllers/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final AuthController _authController = Get.find<AuthController>();
  late final ProfileController _profileController;

  File? profileImage;
  String? existingImageUrl;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load profile data when the page initializes
    _profileController = Get.find<ProfileController>();
    _loadProfileData();
  }

  void _loadProfileData() {
    // First, check if profile data is already loaded and prefill immediately
    final currentProfile = _profileController.userProfile.value;
    if (currentProfile != null) {
      _populateFields(currentProfile);
    }

    // Also listen to profile changes for reactive updates
    _profileController.userProfile.listen((profile) {
      if (profile != null && mounted) {
        _populateFields(profile);
      }
    });
  }

  void _populateFields(UserProfile profile) {
    if (mounted) {
      setState(() {
        firstNameController.text = profile.firstname ?? "";
        lastNameController.text = profile.lastname ?? "";
        emailController.text = profile.email ?? "";
        addressController.text = profile.address ?? "";
        existingImageUrl = profile.profileImageUrl;
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  // Future<void> saveProfile() async {
  //   final userId = _authController.userId;

  //   if (userId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("User not logged in")),
  //     );
  //     return;
  //   }

  //   // Validate required fields
  //   if (firstNameController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("First name is required")),
  //     );
  //     return;
  //   }

  //   if (emailController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Email is required")),
  //     );
  //     return;
  //   }

  //   try {
  //     String? imageUrl = existingImageUrl;

  //     // Upload new image if selected
  //     if (profileImage != null) {
  //       imageUrl =
  //           await _storageService.uploadProfileImage(userId, profileImage!);
  //       AppLogger.debug("Uploaded Image URL: $imageUrl");
  //     }

  //     UserProfile profile = UserProfile(
  //       userId: userId,
  //       firstname: firstNameController.text.trim(),
  //       lastname: lastNameController.text.trim(),
  //       email: emailController.text.trim(),
  //       address: addressController.text.trim(),
  //       profileImageUrl: imageUrl,
  //       joinDate:
  //           _profileController.userProfile.value?.joinDate ?? DateTime.now(),
  //     );

  //     // Use the controller's update method
  //     final success = await _profileController.updateUserProfile(
  //       profile: profile,
  //       context: context,
  //     );

  //     if (success && mounted) {
  //       // Clear the local image after successful upload
  //       setState(() {
  //         profileImage = null;
  //         existingImageUrl = imageUrl;
  //       });

  //       // Reload profile to ensure we have the latest data from server
  //       await _profileController.loadProfile();
  //     }
  //   } catch (e, stackTrace) {
  //     AppLogger.error("Failed to update profile",
  //         error: e, stackTrace: stackTrace);
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error: ${e.toString()}")),
  //       );
  //     }
  //   }
  // }

  Widget buildTextField(String label, TextEditingController controller,
      {bool obscure = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.blue, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        final isLoading = _profileController.isLoading.value;
        final profile = _profileController.userProfile.value;

        if (isLoading && profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Photo Section
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: profileImage != null
                                  ? FileImage(profileImage!)
                                  : (existingImageUrl != null
                                      ? CachedNetworkImageProvider(
                                          existingImageUrl!)
                                      : null) as ImageProvider?,
                              child: profileImage == null &&
                                      existingImageUrl == null
                                  ? const Icon(Icons.person,
                                      size: 60, color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      buildTextField("First Name", firstNameController),
                      buildTextField("Last Name", lastNameController),
                      buildTextField("Email", emailController),
                      buildTextField("Address", addressController, maxLines: 2),
                    ],
                  ),
                ),
              ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  // isLoading ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
