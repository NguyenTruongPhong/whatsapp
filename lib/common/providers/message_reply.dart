import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/enums.dart';

class MessageReply {
  final bool isReplyToMe;
  final String message;
  final MessageTypeEnum messageType;
  final String title;
  final int replyMessageItemIndex;
  final int currentChatLengths;
  final String messageSenderName;

  const MessageReply({
    required this.isReplyToMe,
    required this.message,
    required this.messageType,
    required this.title,
    required this.replyMessageItemIndex,
    required this.currentChatLengths,
    required this.messageSenderName,
  });
}

final StateProvider<MessageReply?> messageReplyStateProvider =
    StateProvider<MessageReply?>((ref) {
  return null;
});
