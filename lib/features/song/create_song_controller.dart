import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sonoul/routes/app_routes.dart';
import 'package:sonoul/services/song_generation_service.dart';
import 'package:sonoul/features/dash/dash_controller.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateSongController extends GetxController {
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
    'Pop',
    'Rock',
    'Ballad',
    'Electronic',
    'Jazz',
    'R&B',
    'Hip Hop',
    'Classical',
    'Country',
    'Blues',
    'Soul',
    'Reggae',
    'Metal',
    'Folk',
    'Disco',
    'House',
    'Techno',
    'Ambient',
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
        final path =
            '${directory.path}/my_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

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
        if (duration.inSeconds < 3) { // Lowered min duration for testing
          ToastUtils.shotToast('Recording too short');
          isRecording.value = false;
          return;
        }

        recordedFilePath.value = path;
        isRecording.value = false;
        
        // Auto-transcribe
        await transcribeAudio(path);
      }
    } catch (e) {
      debugPrint(e.toString());
      isRecording.value = false;
    }
  }

  Future<void> transcribeAudio(String path) async {
    try {
      ToastUtils.shotToast('Transcribing audio...');
      
      final file = File(path);
      final bytes = await file.readAsBytes();
      final audioBase64 = base64Encode(bytes);
      final fileName = path.split('/').last;

      final res = await Supabase.instance.client.functions.invoke(
        'transcribe-audio',
        body: {
          'audioBase64': audioBase64,
          'fileName': fileName,
        },
      );

      final data = res.data;
      if (data != null && data['text'] != null) {
        ideaController.text = data['text'];
        ToastUtils.shotToast('Transcription complete!');
      } else {
        ToastUtils.shotToast('No text found in audio');
      }

    } catch (e) {
      debugPrint('Error transcribing: $e');
      ToastUtils.shotToast('Error transcribing audio');
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

      final songData = await _songService.generateSong(
        idea: ideaController.text,
        audioPath: null,
        tags: selectedTags.isNotEmpty ? selectedTags.toList() : [],
        singerId: singerId,
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
    ToastUtils.shotToast(
      'Song generation started! It will appear in your album shortly.',
    );

    // Get singer info for album page
    String? singerId;
    String? singerName;
    if (Get.isRegistered<DashController>()) {
      final dashController = Get.find<DashController>();
      singerId = dashController.currentSinger?.id;
      singerName = dashController.currentSinger?.name;
    }

    // Use Get.offNamed to replace current page with album page
    // Pass arguments and force refresh
    Get.offNamed(
      AppRoutes.album,
      arguments: {
        'singerId': singerId,
        'singerName': singerName,
        'refresh': true,
      },
    );
  }

  void _handleError(dynamic e) {
    ToastUtils.shotToast('Error: $e');
  }
}
