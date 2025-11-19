import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/aoo_colors.dart';
import 'package:sonoul/features/singer/singer_controller.dart';

class SingerCreationPage extends StatelessWidget {
  final SingerController controller = Get.put(SingerController());
  final TextEditingController nameController = TextEditingController();

  SingerCreationPage({super.key});

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
                          image: NetworkImage(controller.avatarPath.value), // In real app, use FileImage for local pick
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
              decoration: InputDecoration(
                labelText: 'Singer Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 40),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        controller.createSinger(nameController.text.trim());
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create Singer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
