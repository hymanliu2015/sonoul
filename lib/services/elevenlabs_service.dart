import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonoul/common/config/config.dart';

class ElevenLabsService extends GetxService {
  final Dio _dio = Dio();

  Future<File?> generateSpeech({
    required String text,
    String voiceId = AppConfig.defaultVoiceId,
    String modelId = AppConfig.defaultModelId,
  }) async {
    try {
      final url = '${AppConfig.elevenLabsApiUrl}/text-to-speech/$voiceId';
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'xi-api-key': AppConfig.elevenLabsApiKey,
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          responseType: ResponseType.bytes,
        ),
        data: {
          'text': text,
          'model_id': modelId,
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.5,
          }
        },
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${directory.path}/generated_song_$timestamp.mp3');
        await file.writeAsBytes(response.data);
        return file;
      } else {
        debugPrint('ElevenLabs API Error: ${response.statusCode} - ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('Error generating speech: $e');
      return null;
    }
  }
}
