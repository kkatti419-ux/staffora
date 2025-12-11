import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staffora/presentation/users/controllers/user_controller.dart';

class GetAllUsersView extends StatelessWidget {
  GetAllUsersView({super.key});

  final controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // Error or empty state
        if (!controller.fetchSuccess.value && controller.users.isEmpty) {
          return const Center(child: Text("Failed to load users or no data."));
        }

        if (controller.users.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        return const Text("hh");
        // return ListView.builder(
        //   itemCount: controller.users.length,
        //   itemBuilder: (_, outerIndex) {
        //     final outerUser = controller.users[outerIndex];

        //     return ListView.builder(
        //       shrinkWrap: true,
        //       physics: const NeverScrollableScrollPhysics(),
        //       itemCount: outerUser.users?.length,
        //       itemBuilder: (_, innerIndex) {
        //         final innerUser = outerUser.users?[innerIndex];

        //         return ListTile(
        //           title: Text(
        //             innerUser?.address?.address ?? "No address",
        //           ),
        //         );
        //       },
        //     );
        //   },
        // );
      }),
    );
  }
}
