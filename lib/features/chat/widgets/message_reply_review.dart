import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/enums/enums.dart';
import 'package:whatsapp_ui/common/providers/message_reply.dart';

import 'message_reply_review_content.dart';

class MessageReplyReview extends ConsumerWidget {
  const MessageReplyReview({
    Key? key,
    required this.receiverName,
  }) : super(key: key);

  final String receiverName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReplyData = ref.read(messageReplyStateProvider);
    switch (messageReplyData!.messageType) {
      case MessageTypeEnum.text:
      case MessageTypeEnum.icon:
        return MessageReplyReviewContent(
          title: messageReplyData.title,
          message: messageReplyData.message,
          onCancel: () => ref
              .watch(messageReplyStateProvider.notifier)
              .update((state) => null),
        );
      case MessageTypeEnum.image:
        return MessageReplyReviewContent(
          title: messageReplyData.title,
          message: messageReplyData.message,
          onCancel: () => ref
              .watch(messageReplyStateProvider.notifier)
              .update((state) => null),
          isImage: true,
        );
      case MessageTypeEnum.gif:
        return MessageReplyReviewContent(
          title: messageReplyData.title,
          message: messageReplyData.message,
          onCancel: () => ref
              .watch(messageReplyStateProvider.notifier)
              .update((state) => null),
          isGif: true,
        );
      case MessageTypeEnum.audio:
        return MessageReplyReviewContent(
          title: messageReplyData.title,
          message: 'Audio',
          onCancel: () => ref
              .watch(messageReplyStateProvider.notifier)
              .update((state) => null),
        );
      case MessageTypeEnum.video:
        return MessageReplyReviewContent(
          title: messageReplyData.title,
          message: 'Video',
          onCancel: () => ref
              .watch(messageReplyStateProvider.notifier)
              .update((state) => null),
        );
      default:
        return MessageReplyReviewContent(
          title: messageReplyData.title,
          message: 'File',
          onCancel: () => ref
              .watch(messageReplyStateProvider.notifier)
              .update((state) => null),
        );
    }
  }
}
