import 'dart:io';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import 'package:whatsapp_ui/features/group/repository/group_repository.dart';

import '../../models/group_contact_model.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';

final groupControllerProvider = Provider((ref) {
  final groupRepository = ref.read(groupRepositoryProvider);
  return GroupController(groupRepository: groupRepository, ref: ref);
});

class GroupController {
  final GroupRepository groupRepository;
  final ProviderRef ref;

  GroupController({
    required this.groupRepository,
    required this.ref,
  });

  Stream<List<MessageModel>> getGroupMessagesStream(String groupId) {
    return groupRepository.getGroupMessagesStream(groupId);
  }

  Stream<List<GroupContactModel>> getGroupContacts() {
    return groupRepository.getGroupContacts();
  }

  Stream<bool> getGroupOnlineStatus(String groupId) {
    return groupRepository.getGroupOnlineStatus(groupId);
  }

  Future<void> createGroup({
    required String groupName,
    required File groupAvatar,
    required BuildContext context,
  }) async {
    return await groupRepository.createGroup(
      groupName: groupName,
      groupAvatar: groupAvatar,
      context: context,
      ref: ref,
    );
  }

  Stream<GroupContactModel> getGroupContactDataStream(String groupId) {
    return groupRepository.getGroupContactDataStream(groupId);
  }

  Future<GroupContactModel> getGroupContactData(String groupId) async {
    return await groupRepository.getGroupContactData(groupId);
  }

  Future<void> updateGroupMembersSeenMessageUId({
    required String groupId,
    required MessageModel message,
  }) async {
    await groupRepository.updateGroupMembersSeenMessageUId(
        groupId: groupId, message: message);
  }

  Stream<List<UserModel>> getGroupMembersSeenMessageDataStream(
    List<String> memberUIds,
  ) {
    return groupRepository.getGroupMembersSeenMessageDataStream(memberUIds);
  }

  Future<List<UserModel>> getGroupMembersData({
    required BuildContext context,
    required String groupId,
  }) async {
    return groupRepository.getGroupMembersData(
      context: context,
      groupId: groupId,
    );
  }
}
