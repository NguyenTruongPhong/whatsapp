import 'package:cloud_firestore/cloud_firestore.dart';

class GroupContactModel {
  final String name;
  final String lastMessage;
  final List<String> memberIds;
  final String groupAvatarUrl;
  final String senderId;
  final String groupId;
  final String date;

  GroupContactModel({
    required this.name,
    required this.lastMessage,
    required this.memberIds,
    required this.groupAvatarUrl,
    required this.senderId,
    required this.groupId,
    required this.date,
  });

  Map<String, dynamic> toDocument() {
    return <String, dynamic>{
      'name': name,
      'lastMessage': lastMessage,
      'memberIds': memberIds,
      'groupAvatarUrl': groupAvatarUrl,
      'senderId': senderId,
      'groupId': groupId,
      'date': date,
    };
  }

  factory GroupContactModel.fromSnapshot(DocumentSnapshot snap) {
    return GroupContactModel(
      date: snap['date'] as String,
      name: snap['name'] as String,
      lastMessage: snap['lastMessage'] as String,
      memberIds: List<String>.from((snap['memberIds'] as List)),
      groupAvatarUrl: snap['groupAvatarUrl'] as String,
      senderId: snap['senderId'] as String,
      groupId: snap['groupId'] as String,
    );
  }

  GroupContactModel copyWith({
    String? name,
    String? lastMessage,
    List<String>? memberIds,
    String? groupAvatarUrl,
    String? senderId,
    String? groupId,
    String? date,
  }) {
    return GroupContactModel(
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      memberIds: memberIds ?? this.memberIds,
      groupAvatarUrl: groupAvatarUrl ?? this.groupAvatarUrl,
      senderId: senderId ?? this.senderId,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
    );
  }
}
