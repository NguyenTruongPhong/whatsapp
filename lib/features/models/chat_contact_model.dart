import 'package:cloud_firestore/cloud_firestore.dart';

class ChatContactModel {
  final String name;
  final String lastMessage;
  final String timeSent;
  final String id;
  final String profilePicUrl;
  final bool isHavingUnreadMessages;

  const ChatContactModel({
    required this.name,
    required this.lastMessage,
    required this.timeSent,
    required this.id,
    required this.profilePicUrl,
    required this.isHavingUnreadMessages,
  });

  ChatContactModel copyWith({
    String? name,
    String? lastMessage,
    String? timeSent,
    String? id,
    String? profilePicUrl,
    bool? isHavingUnreadMessages,
  }) {
    return ChatContactModel(
      isHavingUnreadMessages:
          isHavingUnreadMessages ?? this.isHavingUnreadMessages,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      timeSent: timeSent ?? this.timeSent,
      id: id ?? this.id,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
    );
  }

  Map<String, dynamic> toDocument() {
    return <String, dynamic>{
      'name': name,
      'lastMessage': lastMessage,
      'timeSent': timeSent,
      'id': id,
      'profilePicUrl': profilePicUrl,
      'isHavingUnreadMessages': isHavingUnreadMessages,
    };
  }

  factory ChatContactModel.fromSnapshot(DocumentSnapshot snap) {
    return ChatContactModel(
      name: snap['name'] as String,
      lastMessage: snap['lastMessage'] as String,
      timeSent: snap['timeSent'] as String,
      id: snap['id'] as String,
      profilePicUrl: snap['profilePicUrl'] as String,
      isHavingUnreadMessages: snap['isHavingUnreadMessages'] as bool,
    );
  }
}
