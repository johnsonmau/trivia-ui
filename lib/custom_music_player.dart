import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audio_notifier.dart';

class SimpleAudioPlayer extends StatefulWidget {
  const SimpleAudioPlayer({Key? key}) : super(key: key);

  @override
  State<SimpleAudioPlayer> createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<SimpleAudioPlayer> {
  @override
  Widget build(BuildContext context) {
    // Access the AudioNotifier and its audio player state.
    final audioNotifier = Provider.of<AudioNotifier>(context);

    // We'll show play/pause based on `isPlaying`.
    final isPlaying = audioNotifier.isPlaying;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -- PLAY/PAUSE BUTTON --
        IconButton(
          iconSize: 30,
          icon: Icon(
            isPlaying ? Icons.volume_up : Icons.volume_off,
            color: Colors.white,
          ),
          onPressed: audioNotifier.togglePlayPause,
        ),

        // -- POSITION & DURATION / SEEK SLIDER --
        // We'll build two StreamBuilders: one for the total duration, one for the current position.
        // Alternatively, you can combine them into one if you prefer, but let's keep it simple and clear.
      ],
    );
  }

  /// Helper to format a Duration into mm:ss or hh:mm:ss.
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}
