import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/components/custom_appbar.dart';
import 'package:sonoul/components/custom_text.dart';
import 'package:sonoul/features/song/create_song_controller.dart';
import 'package:sonoul/common/helper/loading_helper.dart';

class CreateSongPage extends StatelessWidget {
  final CreateSongController controller = Get.put(CreateSongController());

  CreateSongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppbar(
        title: CustomText(
          text: "create_song_title".tr,
          textColor: AppColors.textOnDark,
        ),
        backColor: AppColors.textOnDark,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.greenDeep,
              Color(0xFF0A1F1B),
              Color(0xFF051512),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // 1. Audio Recorder Card
                _buildAudioRecorderCard(),
                const SizedBox(height: 24),
                
                // 2. Song Idea Card
                _buildIdeaCard(),
                const SizedBox(height: 24),
                
                // 3. Style Selection Card
                _buildStyleCard(),
                const SizedBox(height: 24),
                
                // 4. Options Card
                _buildOptionsCard(),
                const SizedBox(height: 32),
                
                // 5. Generate Button
                _buildGenerateButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAudioRecorderCard() {
    return _buildGlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.greenPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mic, color: AppColors.greenLight, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'voice_input_title'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'voice_input_optional'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greenLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'voice_input_desc'.tr,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: controller.isRecording.value ? 90 : 80,
            height: controller.isRecording.value ? 90 : 80,
            child: GestureDetector(
              onTap: () {
                if (controller.isRecording.value) {
                  controller.stopRecording();
                } else {
                  controller.startRecording();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: controller.isRecording.value
                        ? [Colors.red.shade400, Colors.red.shade700]
                        : [AppColors.greenLight, AppColors.greenPrimary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (controller.isRecording.value 
                          ? Colors.red 
                          : AppColors.greenPrimary).withValues(alpha: 0.5),
                      blurRadius: controller.isRecording.value ? 30 : 20,
                      spreadRadius: controller.isRecording.value ? 5 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  controller.isRecording.value ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          )),
          const SizedBox(height: 16),
          Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              controller.isRecording.value ? 'voice_recording'.tr : 'voice_tap_to_speak'.tr,
              key: ValueKey(controller.isRecording.value),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: controller.isRecording.value 
                    ? Colors.red.shade300 
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          )),
          Obx(() {
            if (controller.recordedFilePath.value.isNotEmpty && !controller.isRecording.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: controller.playRecording,
                  icon: const Icon(Icons.play_circle_outline, color: AppColors.greenLight),
                  label: Text('voice_play_recording'.tr, style: const TextStyle(color: AppColors.greenLight)),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.greenPrimary.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildIdeaCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.happy.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lightbulb_outline, color: AppColors.happy, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'song_idea_title'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'song_idea_required'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.ideaController,
            minLines: 5,
            maxLines: 10,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'song_idea_hint'.tr,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 14),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.greenPrimary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.relax.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.music_note, color: AppColors.relax, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'music_style_title'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableTags.map((tag) {
              final isSelected = controller.selectedTags.contains(tag);
              return GestureDetector(
                onTap: () => controller.toggleTag(tag),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.greenLight, AppColors.greenPrimary],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent 
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    return _buildGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sad.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.piano, color: AppColors.sad, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'instrumental_only'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Switch(
            value: controller.isInstrumental.value,
            onChanged: (val) => controller.isInstrumental.value = val,
            activeThumbColor: AppColors.greenPrimary,
            activeTrackColor: AppColors.greenPrimary.withValues(alpha: 0.4),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      )),
    );
  }

  Widget _buildGenerateButton() {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.isGenerating.value ? null : controller.generateSong,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: controller.isGenerating.value
                ? LinearGradient(
                    colors: [Colors.grey.shade600, Colors.grey.shade700],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.greenLight, AppColors.greenPrimary, AppColors.greenDark],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: controller.isGenerating.value
                ? null
                : [
                    BoxShadow(
                      color: AppColors.greenPrimary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: controller.isGenerating.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LoadingHelper(size: 22, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        'btn_composing'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'btn_generate_song'.tr,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ));
  }
}
