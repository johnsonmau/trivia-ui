import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioNotifier extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _audioLoaded = false;

  AudioNotifier() {
    // Listen for player state changes
    _player.onPlayerStateChanged.listen((state) {
      notifyListeners();
    });
  }

  bool get isPlaying => _player.state == PlayerState.playing;

  Future<void> loadUrl(String url) async {
    if (!_audioLoaded) {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setSourceAsset('galactic_rap.mp3');
      _audioLoaded = true;
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Expose streams if needed:
  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<Duration?> get durationStream => _player.onDurationChanged;
}
