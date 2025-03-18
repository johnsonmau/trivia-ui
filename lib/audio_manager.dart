import 'package:just_audio/just_audio.dart';

class AudioManager {
  // Private constructor
  AudioManager._internal();

  // Singleton instance
  static final AudioManager instance = AudioManager._internal();

  // The single audio player
  final AudioPlayer player = AudioPlayer();
}
