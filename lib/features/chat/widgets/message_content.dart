import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:whatsapp_ui/common/enums/enums.dart';
import 'package:whatsapp_ui/features/chat/widgets/audio_message_content.dart';
import 'package:whatsapp_ui/features/chat/widgets/video_message_content.dart';

class MessageContent extends StatelessWidget {
  const MessageContent({
    Key? key,
    required this.message,
    required this.messageType,
  }) : super(key: key);

  final String message;
  final MessageTypeEnum messageType;

  @override
  Widget build(BuildContext context) {
    switch (messageType) {
      case MessageTypeEnum.text:
        return Text(
          message,
          style: const TextStyle(fontSize: 16),
          softWrap: true,
        );
      case MessageTypeEnum.image:
        return CachedNetworkImage(
          imageUrl: message,
          fit: BoxFit.cover,
          width: 150,
          height: 150,
        );
      case MessageTypeEnum.video:
        return VideoMessageContent(videoUrl: message);
      case MessageTypeEnum.gif:
        return CachedNetworkImage(
          imageUrl: message,
          fit: BoxFit.cover,
        );
      case MessageTypeEnum.audio:
        return AudioMessageContent(audioUrl: message);
      default:
        return Text(
          message,
          style: const TextStyle(fontSize: 16),
          softWrap: true,
        );
    }
  }
}
