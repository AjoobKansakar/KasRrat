// For Text-To-Speech 
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  // Guard to prevent overlapping voices
  bool _isSpeaking = false; 

  TTSService() {
    _initTts();
  }

  void _initTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
    // speaking speed
    _flutterTts.setSpeechRate(0.5); 
    
    // Listen for when the app finishes speaking
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });
  }

  Future<void> speak(String text) async {
    // Only speak if it's not currently busy talking
    if (!_isSpeaking) {
      _isSpeaking = true;
      await _flutterTts.speak(text);
    }
  }

  void stop() {
    _flutterTts.stop();
  }
}