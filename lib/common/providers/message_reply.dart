import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/enums.dart';

class MessageReply {
  final bool isReplyToMe;
  final String message;
  final MessageTypeEnum messageType;
  final String title;
  final int replyMessageItemIndex;
  final int chatLengthsAtTimeSent;
  final String ownerMessageName;

  const MessageReply({
    required this.isReplyToMe,
    required this.message,
    required this.messageType,
    required this.title,
    required this.replyMessageItemIndex,
    required this.chatLengthsAtTimeSent,
    required this.ownerMessageName,
  });

  @override
  String toString() =>
      '{isReplyToMe: $isReplyToMe, message: $message, messageType: $messageType,title: $title,replyMessageItemIndex: $replyMessageItemIndex, currentChatLengths: $chatLengthsAtTimeSent, ownerMessageName: $ownerMessageName}';
}

final StateProvider<MessageReply?> messageReplyStateProvider =
    StateProvider<MessageReply?>((ref) {
  return null;
});
