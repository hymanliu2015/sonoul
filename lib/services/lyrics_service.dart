import 'package:get/get.dart';

class LyricsService extends GetxService {
  Future<String> generateLyrics(String idea) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    return "Verse 1:\nIn the neon lights, we dance alone\nEchoes of the past, a silent tone\n\nChorus:\n$idea\nFlying high on wings of steel\nThis is the dream, this is real\n\nVerse 2:\nDigital hearts, beating fast\nMemories of a future past";
  }
}
