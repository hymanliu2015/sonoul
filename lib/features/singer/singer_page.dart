import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/singer/singer_controller.dart';
import 'package:sonoul/common/helper/loading_helper.dart';

class SingerPage extends StatelessWidget {
  final SingerController controller = Get.put(SingerController());
  final TextEditingController nameController = TextEditingController();

  SingerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Singer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: controller.pickImage,
              child: Obx(() => Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  image: controller.avatarPath.value.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(controller.avatarPath.value),
                          fit: BoxFit.cover,
                        )
                      : null,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: controller.avatarPath.value.isEmpty
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                    : null,
              )),
            ),
            const SizedBox(height: 10),
            const Text('Tap to upload avatar', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(
              controller: nameController,
              onChanged: controller.onNameChanged,
              decoration: InputDecoration(
                labelText: 'Singer Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 40),
            Obx(() {
              final isButtonEnabled = controller.name.value.isNotEmpty && !controller.isLoading.value;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          controller.createSinger();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const LoadingHelper(size: 24, color: Colors.white)
                      : const Text(
                          'Create Singer',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
