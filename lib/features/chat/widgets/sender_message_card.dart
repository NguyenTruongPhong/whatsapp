import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/enums/enums.dart';

import '../../../common/providers/message_reply.dart';
import 'normal_message.dart';
import 'reply_message.dart';

class SenderMessageCard extends ConsumerWidget {
  final String message;
  final String date;
  final MessageTypeEnum messageType;
  final String receiverName;
  final String senderName;
  final int messageItemIndex;
  final int chatLengths;
  final String avatarUrl;
  final bool isGroupChat;
  final String currentUserName;
  final bool isLastedMessage;
  final List<String>? membersSeenMessageUId;

  final int? replyMessageItemIndex;
  final String? senderNameOfReplyMessage;
  final int? currentChatLengths;
  final String? replyText;
  final String? replyTitle;
  final MessageTypeEnum? replyMessageType;
  final bool? isReplyToYourself;

  const SenderMessageCard({
    this.replyText,
    this.replyTitle,
    this.replyMessageType,
    this.isReplyToYourself,
    this.currentChatLengths,
    this.senderNameOfReplyMessage,
    Key? key,
    this.isLastedMessage = false,
    this.membersSeenMessageUId,
    required this.currentUserName,
    required this.messageItemIndex,
    this.replyMessageItemIndex,
    required this.chatLengths,
    required this.message,
    required this.date,
    required this.messageType,
    required this.receiverName,
    required this.senderName,
    required this.isGroupChat,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipeTo(
      onRightSwipe: () {
        ref.read(messageReplyStateProvider.notifier).update(
              (state) => MessageReply(
                isReplyToMe: false,
                message: message,
                messageType: messageType,
                title: 'Replying to $senderName',
                replyMessageItemIndex: messageItemIndex,
                currentChatLengths: chatLengths,
                messageSenderName: senderName,
              ),
            );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: replyText == null
            ? NormalMessage(
                isSenderMessage: true,
                color: senderMessageColor,
                messageType: messageType,
                message: message,
                date: date,
                isGroupChat: isGroupChat,
                avatarUrl: avatarUrl,
                isLastedMessage: isLastedMessage,
                membersSeenMessageUId: membersSeenMessageUId,
              )
            : ReplyMessage(
                currentUserName: currentUserName,
                isSenderMessage: true,
                replyText: replyText!,
                date: date,
                message: message,
                messageType: messageType,
                color: senderMessageColor,
                replyMessageType: replyMessageType!,
                isReplyToYourself: isReplyToYourself!,
                receiverName: receiverName,
                senderName: senderName,
                presentChatLengths: chatLengths,
                currentChatLengths: currentChatLengths!,
                replyMessageItemIndex: replyMessageItemIndex!,
                isGroupChat: isGroupChat,
                avatarUrl: avatarUrl,
                senderNameOfReplyMessage: senderNameOfReplyMessage!,
                isLastedMessage: isLastedMessage,
                membersSeenMessageUId: membersSeenMessageUId,
              ),
      ),
    );
  }
}
