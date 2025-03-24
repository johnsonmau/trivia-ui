import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Singleton instance
  static final AudioManager instance = AudioManager._();

  // Private constructor
  AudioManager._();

  // Single audio player instance
  final AudioPlayer player = AudioPlayer();
}
