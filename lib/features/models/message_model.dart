import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/enums/enums.dart';

class MessageModel {
  final String text;
  final String timeSent;
  final bool? isSeen;
  final String messageId;
  final String senderId;
  final String? receiverId;
  final MessageTypeEnum messageType;
  final String receiverName;
  final String senderName;
  final int? replyMessageItemIndex;
  final int? currentChatLengths;
  final String avatarUrl;
  final String? senderNameOfReplyMessage;
  final String? replyText;
  final String? replyTitle;
  final MessageTypeEnum? replyMessageType;
  final bool? isReplyToYourself;
  final List<String>? membersSeenMessageUId;

  const MessageModel({
    this.senderNameOfReplyMessage,
    required this.text,
    required this.timeSent,
    this.isSeen,
    required this.messageId,
    required this.senderId,
    this.receiverId,
    required this.messageType,
    required this.receiverName,
    required this.senderName,
    required this.replyMessageItemIndex,
    required this.avatarUrl,
    this.currentChatLengths,
    this.replyText,
    this.replyTitle,
    this.replyMessageType,
    this.isReplyToYourself,
    this.membersSeenMessageUId,
  });

  MessageModel copyWith({
    String? receiverName,
    String? senderName,
    String? text,
    String? timeSent,
    bool? isSeen,
    String? messageId,
    String? senderId,
    String? receiverId,
    MessageTypeEnum? messageType,
    int? replyMessageItemIndex,
    String? replyText,
    String? replyTitle,
    MessageTypeEnum? replyMessageType,
    bool? isReplyToYourself,
    int? currentChatLengths,
    String? avatarUrl,
    String? senderNameOfReplyMessage,
    List<String>? membersSeenMessageUId,
  }) {
    return MessageModel(
      membersSeenMessageUId:
          membersSeenMessageUId ?? this.membersSeenMessageUId,
      senderNameOfReplyMessage:
          senderNameOfReplyMessage ?? this.senderNameOfReplyMessage,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      text: text ?? this.text,
      timeSent: timeSent ?? this.timeSent,
      isSeen: isSeen ?? this.isSeen,
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      messageType: messageType ?? this.messageType,
      replyMessageItemIndex:
          replyMessageItemIndex ?? this.replyMessageItemIndex,
      replyText: replyText ?? this.replyText,
      replyTitle: replyTitle ?? this.replyTitle,
      replyMessageType: replyMessageType ?? this.replyMessageType,
      isReplyToYourself: isReplyToYourself ?? this.isReplyToYourself,
      currentChatLengths: currentChatLengths ?? this.currentChatLengths,
    );
  }

  Map<String, dynamic> toDocument() {
    return <String, dynamic>{
      'membersSeenMessageUId': membersSeenMessageUId,
      'senderNameOfReplyMessage': senderNameOfReplyMessage,
      'avatarUrl': avatarUrl,
      'text': text,
      'timeSent': timeSent,
      'isSeen': isSeen,
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'messageType': messageType.name,
      'replyMessageItemIndex': replyMessageItemIndex,
      'replyText': replyText,
      'replyTitle': replyTitle,
      'replyMessageType': replyMessageType?.name,
      'isReplyToYourself': isReplyToYourself,
      'receiverName': receiverName,
      'senderName': senderName,
      'currentChatLengths': currentChatLengths,
    };
  }

  factory MessageModel.fromSnapshot(DocumentSnapshot snap) {
    return MessageModel(
      avatarUrl: snap['avatarUrl'] as String,
      senderName: snap['senderName'] as String,
      receiverName: snap['receiverName'] as String,
      text: snap['text'] as String,
      timeSent: snap['timeSent'] as String,
      isSeen: (snap['isSeen'] as bool?) != null ? snap['isSeen'] as bool : null,
      messageId: snap['messageId'] as String,
      senderId: snap['senderId'] as String,
      receiverId: (snap['receiverId'] as String?) != null
          ? snap['receiverId'] as String
          : null,
      messageType:
          (snap['messageType'] as String).convertStringToMessageTypeEnum(),
      replyMessageItemIndex: (snap['replyMessageItemIndex'] as int?) != null
          ? snap['replyMessageItemIndex'] as int
          : null,
      replyText: (snap['replyText'] as String?) != null
          ? snap['replyText'] as String
          : null,
      replyTitle: (snap['replyTitle'] as String?) != null
          ? snap['replyTitle'] as String
          : null,
      replyMessageType: (snap['replyMessageType'] as String?) != null
          ? (snap['replyMessageType'] as String)
              .convertStringToMessageTypeEnum()
          : null,
      isReplyToYourself: (snap['isReplyToYourself'] as bool?) != null
          ? snap['isReplyToYourself'] as bool
          : null,
      currentChatLengths: (snap['currentChatLengths'] as int?) != null
          ? snap['currentChatLengths'] as int
          : null,
      senderNameOfReplyMessage:
          (snap['senderNameOfReplyMessage'] as String?) != null
              ? snap['senderNameOfReplyMessage'] as String
              : null,
      membersSeenMessageUId: (snap['membersSeenMessageUId']
                  as List<dynamic>?) !=
              null
          ? List<String>.from(snap['membersSeenMessageUId'] as List<dynamic>)
          : null,
    );
  }
}
