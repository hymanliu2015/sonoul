import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/song_generation_service.dart';
import 'package:sonoul/features/dash/dash_controller.dart';
import 'package:sonoul/utils/toast_util.dart';

class CreateSingleController extends GetxController {
  final SongGenerationService _songService = Get.put(SongGenerationService());
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final TextEditingController ideaController = TextEditingController();
  
  RxBool isRecording = false.obs;
  RxString recordedFilePath = ''.obs;
  RxBool isGenerating = false.obs;
  RxList<String> selectedTags = <String>[].obs;
  RxBool isInstrumental = false.obs;
  
  final List<String> availableTags = [
    'Pop', 'Rock', 'Ballad', 'Electronic', 'Jazz', 'R&B', 
    'Hip Hop', 'Classical', 'Country', 'Blues', 'Soul', 'Reggae', 
    'Metal', 'Folk', 'Disco', 'House', 'Techno', 'Ambient'
  ];

  DateTime? _recordingStartTime;

  @override
  void onClose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    ideaController.dispose();
    super.onClose();
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.clear(); // Enforce single selection
      selectedTags.add(tag);
    }
  }

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/my_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        isRecording.value = true;
        _recordingStartTime = DateTime.now();
      } else {
        ToastUtils.shotToast('Microphone permission required');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);
        if (duration.inSeconds < 5) {
          ToastUtils.shotToast('Recording must be at least 5 seconds');
          isRecording.value = false;
          return;
        }
        
        // Logic to trim to 10s would ideally happen here or on backend
        // For now, we just accept the file if it's > 5s
        
        recordedFilePath.value = path;
        isRecording.value = false;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> playRecording() async {
    if (recordedFilePath.value.isNotEmpty) {
      await _audioPlayer.play(DeviceFileSource(recordedFilePath.value));
    }
  }

  Future<void> generateSong() async {
    if (ideaController.text.trim().isEmpty) {
      ToastUtils.shotToast('Please describe your song idea');
      return;
    }

    try {
      isGenerating.value = true;
      String singerId = _getSingerId();
      if (singerId.isEmpty) return;

      // Call service with all data
      final songData = await _songService.generateSongFromEmotion(
        audioPath: recordedFilePath.value,
        singerId: singerId,
        idea: ideaController.text.isNotEmpty ? ideaController.text : null,
        tags: selectedTags.isNotEmpty ? selectedTags.toList() : null,
        isInstrumental: isInstrumental.value,
      );
      
      _handleSuccess(songData);
    } catch (e) {
      _handleError(e);
    } finally {
      isGenerating.value = false;
    }
  }

  String _getSingerId() {
    if (Get.isRegistered<DashController>()) {
      final dashController = Get.find<DashController>();
      if (dashController.currentSinger != null) {
        return dashController.currentSinger!.id;
      }
    }
    ToastUtils.shotToast('No singer selected');
    return '';
  }

  void _handleSuccess(dynamic songData) {
    ToastUtils.shotToast('Song generation started! It will appear in your album shortly.');
    // Small delay to allow DB propagation if needed? No, user can pull to refresh.
    Get.back(); // Go back to create page or album?
    // User flow: Create -> Album. The original code did Get.offNamed('/album'). This is fine.
    Get.offNamed(AppRoutes.album); 
  }

  void _handleError(dynamic e) {
    ToastUtils.shotToast('Error: $e');
  }
}
