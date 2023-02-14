import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioMessageContent extends StatefulWidget {
  const AudioMessageContent({
    Key? key,
    required this.audioUrl,
  }) : super(key: key);

  final String audioUrl;

  @override
  State<AudioMessageContent> createState() => _AudioMessageContentState();
}

class _AudioMessageContentState extends State<AudioMessageContent> {
  // bool isPlay = false;
  // AudioPlayer audioPlayer = AudioPlayer();
  FlutterSoundPlayer? audioPlayer;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    openPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer!.closePlayer();
  }

  Future<void> openPlayer() async {
    audioPlayer = await FlutterSoundPlayer().openPlayer();
  }

  void togglePlayer() async {
    // print(
    //     'isPlaying: ${audioPlayer!.isPlaying}, isPaused: ${audioPlayer!.isPaused}');
    if (!isPlaying && !audioPlayer!.isPaused) {
      audioPlayer!
        ..setVolume(0.5)
        ..startPlayer(
          fromURI: widget.audioUrl,
          whenFinished: () {
            setState(() {
              isPlaying = !isPlaying;
            });
          },
        );
    } else if (audioPlayer!.isPaused) {
      await audioPlayer!.resumePlayer();
    } else {
      await audioPlayer!.pausePlayer();
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: IconButton(
        onPressed: togglePlayer,
        icon: isPlaying
            ? const Icon(Icons.stop_circle_rounded)
            : const Icon(Icons.play_circle_fill_rounded),
      ),
    );
  }
}
