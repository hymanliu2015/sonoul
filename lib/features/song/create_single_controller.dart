import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sonoul/services/song_generation_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateSingleController extends GetxController {
  final SongGenerationService _songService = Get.put(SongGenerationService());
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final TextEditingController ideaController = TextEditingController();
  
  RxBool isRecording = false.obs;
  RxString recordedFilePath = ''.obs;
  RxBool isGenerating = false.obs;
  RxList<String> selectedTags = <String>[].obs;
  
  final List<String> availableTags = ['Pop', 'Rock', 'Ballad', 'Electronic', 'Jazz', 'R&B'];

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
      } else {
        Get.snackbar('Permission', 'Microphone permission required');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        recordedFilePath.value = path;
        isRecording.value = false;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> playRecording() async {
    if (recordedFilePath.value.isNotEmpty) {
      await _audioPlayer.play(DeviceFileSource(recordedFilePath.value));
    }
  }

  Future<void> generateSong() async {
    if (ideaController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a song idea');
      return;
    }
    if (recordedFilePath.value.isEmpty) {
      Get.snackbar('Error', 'Please record your voice');
      return;
    }

    try {
      isGenerating.value = true;
      final songData = await _songService.generateSong(
        idea: ideaController.text,
        audioPath: recordedFilePath.value,
        tags: selectedTags,
      );
      
      // Navigate to result or album page (Mock)
      Get.snackbar('Success', 'Song generated: ${songData['title']}', backgroundColor: Colors.green, colorText: Colors.white);
      // In real app, save to DB and navigate
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate song');
    } finally {
      isGenerating.value = false;
    }
  }
}
