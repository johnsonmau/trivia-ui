import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioNotifier extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _audioLoaded = false;

  AudioNotifier() {
    // Whenever the player state changes (playing/paused/completed), notifyListeners().
    _player.playerStateStream.listen((state) {
      notifyListeners();
    });
  }

  bool get isPlaying => _player.playerState.playing;

  Future<void> loadUrl(String url) async {
    if (!_audioLoaded) {
      await _player.setLoopMode(LoopMode.one);

      await _player.setUrl(url);
      // optional: await _player.setLoopMode(LoopMode.one);
      _audioLoaded = true;
    }
   // await _player.play();
    // Don’t call play() here if you don’t want it to start automatically every time.
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    // The stream listener calls notifyListeners() for us.
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Expose streams if needed:
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
}
