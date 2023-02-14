import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';

class VideoMessageContent extends StatefulWidget {
  const VideoMessageContent({
    Key? key,
    required this.videoUrl,
    this.isForMessageReplyContent = false,
  }) : super(key: key);

  final String videoUrl;
  final bool isForMessageReplyContent;

  @override
  State<VideoMessageContent> createState() => _VideoMessageContentState();
}

class _VideoMessageContentState extends State<VideoMessageContent> {
  late final CachedVideoPlayerController videoPlayerController;
  bool isPlay = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController = CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        videoPlayerController.pause();
        videoPlayerController.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          CachedVideoPlayer(videoPlayerController),
          widget.isForMessageReplyContent
              ? const SizedBox()
              : Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () async {
                      if (isPlay) {
                        videoPlayerController.pause();
                      } else {
                        videoPlayerController.play();
                      }
                      setState(() {
                        isPlay = !isPlay;
                      });
                    },
                    icon: Icon(
                      isPlay ? Icons.pause_circle : Icons.play_circle,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
