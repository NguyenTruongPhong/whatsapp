import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/enums/enums.dart';
import 'package:whatsapp_ui/common/providers/message_reply.dart';

import 'normal_message.dart';
import 'reply_message.dart';

class MyMessageCard extends ConsumerWidget {
  final String message;
  final String date;
  final bool isSeen;
  final MessageTypeEnum messageType;
  final String receiverName;
  final String senderName;
  final int currentMessageItemIndex;
  final int chatLengths;
  final String currentUserName;
  final bool isLastedMessage;
  final List<String>? membersSeenMessageUId;

  final String? senderNameOfReplyMessage;
  final int? replyMessageItemIndex;
  final int? currentChatLengths;
  final String? replyText;
  final String? replyTitle;
  final MessageTypeEnum? replyMessageType;
  final bool? isReplyToYourself;
  final bool isGroupChat;

  const MyMessageCard({
    this.replyText,
    this.replyTitle,
    this.replyMessageType,
    this.isReplyToYourself,
    this.currentChatLengths,
    Key? key,
    this.isLastedMessage = false,
    this.membersSeenMessageUId,
    this.senderNameOfReplyMessage,
    required this.currentUserName,
    required this.currentMessageItemIndex,
    this.replyMessageItemIndex,
    required this.chatLengths,
    required this.receiverName,
    required this.senderName,
    required this.message,
    required this.date,
    required this.isSeen,
    required this.messageType,
    required this.isGroupChat,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print('index: $currentMessageItemIndex');
    return SwipeTo(
      onLeftSwipe: () {
        ref.read(messageReplyStateProvider.notifier).update(
              (state) => MessageReply(
                isReplyToMe: true,
                message: message,
                messageType: messageType,
                title: 'Replying to yourself',
                replyMessageItemIndex: currentMessageItemIndex,
                chatLengthsAtTimeSent: chatLengths,
                ownerMessageName: senderName,
              ),
            );
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: replyText == null
            ? NormalMessage(
                isSenderMessage: false,
                isLastedMessage: isLastedMessage,
                membersSeenMessageUId: membersSeenMessageUId,
                color: messageColor,
                messageType: messageType,
                message: message,
                date: date,
                isSeen: isSeen,
                isGroupChat: isGroupChat,
              )
            : ReplyMessage(
                currentUserName: currentUserName,
                isSenderMessage: false,
                color: messageColor,
                replyText: replyText!,
                date: date,
                isSeen: isSeen,
                message: message,
                messageType: messageType,
                replyMessageType: replyMessageType!,
                isReplyToYourself: isReplyToYourself!,
                receiverName: receiverName,
                senderName: senderName,
                replyMessageItemIndex: replyMessageItemIndex!,
                currentChatLengths: currentChatLengths!,
                presentChatLengths: chatLengths,
                isGroupChat: isGroupChat,
                senderNameOfReplyMessage: senderNameOfReplyMessage!,
                isLastedMessage: isLastedMessage,
                membersSeenMessageUId: membersSeenMessageUId,
              ),
      ),
    );
  }
}
