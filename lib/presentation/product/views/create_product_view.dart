import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';

class CreateProductView extends StatefulWidget {
  const CreateProductView({super.key});

  @override
  State<CreateProductView> createState() => _CreateProductViewState();
}

class _CreateProductViewState extends State<CreateProductView> {
  late final ProductController controller1;
  late final ThemeController themeController;

  @override
  void initState() {
    super.initState();
    controller1 = Get.find<ProductController>(); // ✔ correct
    themeController = Get.find<ThemeController>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Product", style: theme.textTheme.titleMedium),
        backgroundColor: AppColors.primary,
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  themeController.themeMode.value == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: themeController.toggleTheme,
              )),
        ],
      ),
      body: Obx(() {
        return Stack(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  "getProducts",
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
            // Centered loading indicator overlay
            if (controller1.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
    );
  }
}
