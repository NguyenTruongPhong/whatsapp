import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String profilePicUrl;
  final bool isOnline;
  final List groupsId;

  UserModel({
    required this.name,
    required this.phoneNumber,
    required this.profilePicUrl,
    required this.isOnline,
    required this.groupsId,
    required this.uid,
  });

  Map<String, dynamic> toDocument() {
    return <String, dynamic>{
      'name': name,
      'phoneNumber': phoneNumber,
      'profilePicUrl': profilePicUrl,
      'isOnline': isOnline,
      'groupsId': groupsId,
      'uid': uid,
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    return UserModel(
      uid: snap['uid'] as String,
      name: snap['name'] as String,
      phoneNumber: snap['phoneNumber'] as String,
      profilePicUrl: snap['profilePicUrl'] as String,
      isOnline: snap['isOnline'] as bool,
      groupsId: List.from(
        (snap['groupsId'] as List),
      ),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phoneNumber,
    String? profilePicUrl,
    bool? isOnline,
    List? groupsId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isOnline: isOnline ?? this.isOnline,
      groupsId: groupsId ?? this.groupsId,
    );
  }
}
