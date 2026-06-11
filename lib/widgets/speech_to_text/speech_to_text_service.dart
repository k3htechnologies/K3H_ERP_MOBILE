import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  static final SpeechToText _speech = SpeechToText();

  static Future<bool> initialize() async {
    return await _speech.initialize();
  }

  static Future<void> startListening({
    required Function(String text) onResult,
  }) async {
    final available = await initialize();

    if (!available) return;

    _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }

  static bool get isListening => _speech.isListening;
}
