import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/song/create_single_controller.dart';
import 'package:sonoul/common/helper/loading_helper.dart';

class CreateSinglePage extends StatelessWidget {
  final CreateSingleController controller = Get.put(CreateSingleController());

  CreateSinglePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Single'),
        centerTitle: true,
        bottom: TabBar(
          controller: controller.tabController,
          tabs: const [
            Tab(text: 'Basic Mode'),
            Tab(text: 'Emotional Mode'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildBasicMode(),
          _buildEmotionalMode(),
        ],
      ),
    );
  }

  Widget _buildBasicMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your song about?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller.ideaController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g., A summer love story on the beach...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Select Style',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Obx(() => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: controller.availableTags.map((tag) {
              final isSelected = controller.selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (_) => controller.toggleTag(tag),
                selectedColor: AppColors.accent.withValues(alpha: 0.2),
                checkmarkColor: AppColors.accent,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.accent : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: 30),
          Obx(() => SwitchListTile(
            title: const Text('Instrumental', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            value: controller.isInstrumental.value,
            onChanged: (val) => controller.isInstrumental.value = val,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          )),
          const SizedBox(height: 40),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildEmotionalMode() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Record your emotion',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Hum a melody or express your feelings (min 5s)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 60),
          Obx(() => GestureDetector(
            onTap: () {
              if (controller.isRecording.value) {
                controller.stopRecording();
              } else {
                controller.startRecording();
              }
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: controller.isRecording.value ? Colors.red : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (controller.isRecording.value ? Colors.red : AppColors.primary).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Icon(
                controller.isRecording.value ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 60,
              ),
            ),
          )),
          const SizedBox(height: 20),
          Obx(() => Text(
            controller.isRecording.value ? 'Recording...' : 'Tap to Record',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: controller.isRecording.value ? Colors.red : Colors.grey,
            ),
          )),
          const SizedBox(height: 40),
          Obx(() {
            if (controller.recordedFilePath.value.isNotEmpty && !controller.isRecording.value) {
              return Column(
                children: [
                  TextButton.icon(
                    onPressed: controller.playRecording,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play Recording'),
                  ),
                  const SizedBox(height: 20),
                  _buildGenerateButton(),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isGenerating.value
            ? null
            : controller.generateSong,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isGenerating.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  LoadingHelper(size: 24, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Composing...', style: TextStyle(color: Colors.white)),
                ],
              )
            : const Text(
                'Generate Single',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    ));
  }
}
