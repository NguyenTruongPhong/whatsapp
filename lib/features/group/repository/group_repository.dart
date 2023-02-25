import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/repositories/common_firestore_repository.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_ui/features/models/group_contact_model.dart';
import 'package:whatsapp_ui/features/models/user_model.dart';

import '../../models/message_model.dart';

final groupRepositoryProvider = Provider((ref) {
  return GroupRepository(
    firebaseFirestore: FirebaseFirestore.instance,
    firebaseStorage: FirebaseStorage.instance,
    firebaseAuth: FirebaseAuth.instance,
  );
});

class GroupRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  final FirebaseAuth firebaseAuth;

  GroupRepository({
    required this.firebaseFirestore,
    required this.firebaseStorage,
    required this.firebaseAuth,
  });

  Stream<List<MessageModel>> getGroupMessagesStream(String groupId) {
    return firebaseFirestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .map((documents) {
      final List<MessageModel> groupMessages = documents.docs
          .map((snap) => MessageModel.fromSnapshot(snap))
          .toList();
      return groupMessages;
    });
  }

  Stream<List<GroupContactModel>> getGroupContacts() {
    return firebaseFirestore
        .collection('groups')
        .where('memberIds', arrayContains: firebaseAuth.currentUser!.uid)
        .snapshots()
        .map(
          (documents) => documents.docs
              .map((snap) => GroupContactModel.fromSnapshot(snap))
              .toList(),
        );
  }

  Stream<bool> getGroupOnlineStatus(String groupId) {
    try {
      return firebaseFirestore
          .collection('users')
          .where('groupsId', arrayContains: groupId)
          .snapshots()
          .map(
        (documents) {
          final fistOnlineMember = documents.docs.firstWhere((document) {
            return (document.data()['isOnline'] as bool) == true;
          });
          return fistOnlineMember.exists;
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> createGroup({
    required String groupName,
    required File groupAvatar,
    required BuildContext context,
    required ProviderRef ref,
  }) async {
    final List<Contact> groupMemberContacts =
        ref.read(selectedGroupMemberContactsProvider);
    final String groupId = const Uuid().v1();
    final List<String> registeredMembers = [];
    final GroupContactModel newGroupContact;
    try {
      final String? groupAvatarUrl = await ref
          .read(commonFirestoreRepositoryProvider)
          .storeFileToFirestore(
            file: groupAvatar,
            ref: 'groups/groupAvatars/$groupId',
          );

      for (var contact in groupMemberContacts) {
        if (contact.phones.isNotEmpty) {
          await firebaseFirestore
              .collection('users')
              .where(
                'phoneNumber',
                isEqualTo: contact.phones[0].number.replaceAll(' ', ''),
              )
              .get()
              .then((users) {
            if (users.docs[0].exists) {
              // final a = users;
              // final b = users.docs;
              // final c = users.docs[0];
              // final d = users.docs[0].data();
              registeredMembers.add(users.docs[0].data()['uid']);
            } else {
              showSnackbar(
                context,
                'There is no account for the contact: ${contact.displayName}',
              );
            }
          });
        }
      }

      newGroupContact = GroupContactModel(
        name: groupName,
        lastMessage: '',
        memberIds: [firebaseAuth.currentUser!.uid, ...registeredMembers],
        groupAvatarUrl: groupAvatarUrl!,
        senderId: firebaseAuth.currentUser!.uid,
        groupId: groupId,
        date: DateTime.now().toIso8601String(),
      );

      await firebaseFirestore
          .collection('groups')
          .doc(groupId)
          .set(newGroupContact.toDocument())
          .then((value) => print('Create group succeed.'));

      //update groupsId in user data
      for (var registerMemberUId in [
        firebaseAuth.currentUser!.uid,
        ...registeredMembers
      ]) {
        late final UserModel userData;
        await firebaseFirestore
            .collection('users')
            .doc(registerMemberUId)
            .get()
            .then((DocumentSnapshot snap) {
          userData = UserModel.fromSnapshot(snap);
        });
        await firebaseFirestore
            .collection('users')
            .doc(registerMemberUId)
            .update({
          'groupsId': [groupId, ...userData.groupsId]
        });
      }
      return;
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar(context, e.toString());
      return;
    }
  }

  Stream<GroupContactModel> getGroupContactDataStream(String groupId) {
    return firebaseFirestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((snap) => GroupContactModel.fromSnapshot(snap));
  }

  Future<GroupContactModel> getGroupContactData(String groupId) async {
    return await firebaseFirestore
        .collection('groups')
        .doc(groupId)
        .get()
        .then((snap) => GroupContactModel.fromSnapshot(snap));
  }

  Future<void> updateGroupMembersSeenMessageUId({
    required String groupId,
    required MessageModel message,
  }) async {
    final currentUserUId = firebaseAuth.currentUser!.uid;
    try {
      await firebaseFirestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(message.messageId)
          .update({
        'membersSeenMessageUId': [
          currentUserUId,
          ...message.membersSeenMessageUId!
        ]
      }).then(
        (value) => print('update group members seen for message succeeded.'),
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Stream<List<UserModel>> getGroupMembersSeenMessageDataStream(
    List<String> memberUIds,
  ) {
    return firebaseFirestore
        .collection('users')
        .where('uid', whereIn: memberUIds)
        .snapshots()
        .map(
          (documents) => documents.docs
              .map((snap) => UserModel.fromSnapshot(snap))
              .toList(),
        );
  }

  Future<List<UserModel>> getGroupMembersData({
    required BuildContext context,
    required String groupId,
  }) async {
    late final List<String> groupMemberUIds;
    try {
      await firebaseFirestore.collection('groups').doc(groupId).get().then(
            (doc) => groupMemberUIds =
                List<String>.from(doc.data()!['memberIds'] as List<dynamic>),
          );
      final a = await firebaseFirestore
          .collection('users')
          .where('uid', whereIn: groupMemberUIds)
          .get()
          .then((documents) {
        return documents.docs.map(
          (snap) {
            return UserModel.fromSnapshot(snap);
          },
        ).toList();
      });

      return a;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
