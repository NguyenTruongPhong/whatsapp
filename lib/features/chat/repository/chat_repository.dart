import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/enums/enums.dart';
import 'package:whatsapp_ui/common/providers/message_reply.dart';
import 'package:whatsapp_ui/common/repositories/common_firestore_repository.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';

import 'package:whatsapp_ui/features/auth/repository/auth_repository.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';
import 'package:whatsapp_ui/features/models/chat_contact_model.dart';
import 'package:whatsapp_ui/features/models/group_contact_model.dart';
import 'package:whatsapp_ui/features/models/message_model.dart';
import 'package:whatsapp_ui/features/models/user_model.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
  );
});

class ChatRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  const ChatRepository({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  

  Future<ChatContactModel> getSingleChatContact(String receiverId) async {
    return await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser?.uid)
        .collection('chatContacts')
        .doc(receiverId)
        .get()
        .then((snap) => ChatContactModel.fromSnapshot(snap));
  }

  Stream<List<ChatContactModel>?> getChatContacts() {
    return firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser?.uid)
        .collection('chatContacts')
        .snapshots()
        .map((documents) {
      return documents.docs
          .map((snap) => ChatContactModel.fromSnapshot(snap))
          .toList();
    });
  }

  Stream<List<MessageModel>?> getMessagesByUIdStream(String receiverId) {
    return firebaseFirestore
        .collection('users')
        .doc(receiverId)
        .collection('chatContacts')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('messages')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .map((documents) {
      return documents.docs
          .map((snap) => MessageModel.fromSnapshot(snap))
          .toList();
    });
  }

  Future<void> _saveContactDataToChatSubCollection({
    required String text,
    required String timeSent,
    required UserModel receiverData,
    required UserModel senderData,
  }) async {
    final ChatContactModel senderContact = ChatContactModel(
      name: senderData.name,
      lastMessage: text,
      timeSent: timeSent,
      id: senderData.uid,
      profilePicUrl: senderData.profilePicUrl,
      isHavingUnreadMessages: true,
    );

    final ChatContactModel receiverContact = ChatContactModel(
      name: receiverData.name,
      lastMessage: text,
      timeSent: timeSent,
      id: receiverData.uid,
      profilePicUrl: receiverData.profilePicUrl,
      isHavingUnreadMessages: true,
    );

    firebaseFirestore
      ..collection('users')
          .doc(receiverData.uid)
          .collection('chatContacts')
          .doc(senderContact.id)
          .set(senderContact.toDocument())
      ..collection('users')
          .doc(senderData.uid)
          .collection('chatContacts')
          .doc(receiverContact.id)
          .set(receiverContact.toDocument())
          .then((value) {
        print('Saved contact data to subCollection');
        return;
      });
  }

  Future<void> _saveGroupContactDataToChatGroupSubCollection({
    required String name,
    required String lastMessage,
    required List<String> memberIds,
    required String groupAvatarUrl,
    required String senderId,
    required String groupId,
    required String date,
    // required UserModel senderData,
  }) async {
    final groupContactData = GroupContactModel(
      name: name,
      lastMessage: lastMessage,
      memberIds: memberIds,
      groupAvatarUrl: groupAvatarUrl,
      senderId: senderId,
      groupId: groupId,
      date: date,
    );
    return firebaseFirestore
        .collection('groups')
        .doc(groupContactData.groupId)
        .set(groupContactData.toDocument())
        .then((value) =>
            print('Save group contact data to subCollection succeeded.'));
  }

  Future<void> _saveMessageDataToChatSubCollection({
    required UserModel receiverData,
    required UserModel senderData,
    required String timeSent,
    required String text,
    required MessageTypeEnum messageType,
    required String messageId,
    required String receiverName,
    required int? replyMessageItemIndex,
    required int? currentChatLengths,
    required String? replyText,
    required String? replyTitle,
    required MessageTypeEnum? replyMessageType,
    required bool? isReplyToYourself,
    required String? senderNameOfReplyMessage,
    required ProviderRef ref,
  }) async {
    final MessageModel message = MessageModel(
      avatarUrl: senderData.profilePicUrl,
      senderName: senderData.name,
      receiverName: receiverName,
      text: text,
      timeSent: timeSent,
      isSeen: false,
      messageId: messageId,
      senderId: senderData.uid,
      receiverId: receiverData.uid,
      messageType: messageType,
      replyMessageItemIndex: replyMessageItemIndex,
      replyMessageType: replyMessageType,
      replyText: replyText,
      replyTitle: replyTitle,
      isReplyToYourself: isReplyToYourself,
      currentChatLengths: currentChatLengths,
      senderNameOfReplyMessage: senderNameOfReplyMessage,
    );
    //save message to receiver fist and then to the sender
    firebaseFirestore
      ..collection('users')
          .doc(receiverData.uid)
          .collection('chatContacts')
          .doc(senderData.uid)
          .collection('messages')
          .doc(messageId)
          .set(message.toDocument())
      ..collection('users')
          .doc(senderData.uid)
          .collection('chatContacts')
          .doc(receiverData.uid)
          .collection('messages')
          .doc(messageId)
          .set(message.toDocument())
          .then((value) {
        print('Saved message data to subCollection');
      });

    ref.watch(messageReplyStateProvider.notifier).update((state) => null);
    return;
  }

  Future<void> _saveGroupMessageDataToChatGroupSubCollection({
    required String groupId,
    // required UserModel receiverData,
    required UserModel senderData,
    required String timeSent,
    required String text,
    required MessageTypeEnum messageType,
    required String messageId,
    required String receiverName,
    required int? replyMessageItemIndex,
    required int? currentChatLengths,
    required String? replyText,
    required String? replyTitle,
    required MessageTypeEnum? replyMessageType,
    required bool? isReplyToYourself,
    required String? senderNameOfReplyMessage,
    required ProviderRef ref,
    required List<String> membersSeenMessageUId,
  }) async {
    // print('_saveMessageDataToSubCollection');
    final MessageModel message = MessageModel(
      avatarUrl: senderData.profilePicUrl,
      senderName: senderData.name,
      receiverName: receiverName,
      text: text,
      timeSent: timeSent,
      // isSeen: false,
      messageId: messageId,
      senderId: senderData.uid,
      // receiverId: receiverData.uid,
      messageType: messageType,
      replyMessageItemIndex: replyMessageItemIndex,
      replyMessageType: replyMessageType,
      replyText: replyText,
      replyTitle: replyTitle,
      isReplyToYourself: isReplyToYourself,
      currentChatLengths: currentChatLengths,
      senderNameOfReplyMessage: senderNameOfReplyMessage,
      membersSeenMessageUId: membersSeenMessageUId,
    );
    await firebaseFirestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .set(message.toDocument())
        .then((value) {
      ref.watch(messageReplyStateProvider.notifier).update((state) => null);
      print('Saved group message data to subCollection succeeded.');
    });
  }

  Future<void> sentTextOrEmojiMessage({
    required BuildContext context,
    required String text,
    required String receiverId,
    required ProviderRef ref,
    required String receiverName,
    required bool isGroupChat,
  }) async {
    final timeSent = DateTime.now().toIso8601String();
    final String messageId = const Uuid().v1();
    final messageReplyData = ref.read(messageReplyStateProvider);
    try {
      final UserModel? receiverData = await ref
          .watch(authRepositoryProvider)
          .getCurrentUserDataOrByUId(receiverId);

      final UserModel? senderData = await ref
          .watch(authRepositoryProvider)
          .getCurrentUserDataOrByUId(firebaseAuth.currentUser!.uid);

      GroupContactModel? groupContactData;
      if (isGroupChat) {
        groupContactData = await ref
            .read(groupControllerProvider)
            .getGroupContactData(receiverId);
      }

      isGroupChat
          ? _saveGroupContactDataToChatGroupSubCollection(
              name: groupContactData!.name,
              lastMessage: text,
              memberIds: groupContactData.memberIds,
              groupAvatarUrl: groupContactData.groupAvatarUrl,
              senderId: senderData!.uid,
              groupId: groupContactData.groupId,
              date: timeSent,
            )
          : _saveContactDataToChatSubCollection(
              text: text,
              timeSent: timeSent,
              receiverData: receiverData!,
              senderData: senderData!,
            );

      isGroupChat
          ? _saveGroupMessageDataToChatGroupSubCollection(
              membersSeenMessageUId: [],
              groupId: receiverId,
              // receiverData: receiverData!,
              senderData: senderData,
              timeSent: timeSent,
              text: text,
              messageType: MessageTypeEnum.text,
              messageId: messageId,
              receiverName: receiverName,
              senderNameOfReplyMessage: messageReplyData?.messageSenderName,
              replyMessageItemIndex: messageReplyData?.replyMessageItemIndex,
              currentChatLengths: messageReplyData?.replyMessageItemIndex,
              replyText: messageReplyData?.message,
              replyTitle: messageReplyData?.message,
              replyMessageType: messageReplyData?.messageType,
              isReplyToYourself: messageReplyData?.isReplyToMe,
              ref: ref,
            )
          : _saveMessageDataToChatSubCollection(
              receiverName: receiverName,
              receiverData: receiverData!,
              senderData: senderData,
              timeSent: timeSent,
              text: text,
              messageType: MessageTypeEnum.text,
              messageId: messageId,
              replyMessageItemIndex: messageReplyData?.replyMessageItemIndex,
              replyMessageType: messageReplyData?.messageType,
              replyText: messageReplyData?.message,
              replyTitle: messageReplyData?.title,
              isReplyToYourself: messageReplyData?.isReplyToMe,
              currentChatLengths: messageReplyData?.replyMessageItemIndex,
              senderNameOfReplyMessage: messageReplyData?.messageSenderName,
              ref: ref,
            );
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar(context, 'Something went wrong. Please try again.');
      rethrow;
    }
  }

  Future<void> sentFileMessage({
    required BuildContext context,
    required String receiverId,
    required File file,
    required MessageTypeEnum messageType,
    required ProviderRef ref,
    required String receiverName,
    required bool isGroupChat,
  }) async {
    final String timeSent = DateTime.now().toIso8601String();
    final String messageId = const Uuid().v1();
    final String lastMessageContent;
    final messageReplyData = ref.read(messageReplyStateProvider);

    switch (messageType) {
      case MessageTypeEnum.audio:
        lastMessageContent = 'audio';
        break;
      case MessageTypeEnum.file:
        lastMessageContent = 'file';
        break;
      case MessageTypeEnum.gif:
        lastMessageContent = 'gif';
        break;
      case MessageTypeEnum.icon:
        lastMessageContent = 'icon';
        break;
      case MessageTypeEnum.image:
        lastMessageContent = 'image';
        break;
      case MessageTypeEnum.video:
        lastMessageContent = 'video';
        break;
      default:
        lastMessageContent = 'file';
    }

    try {
      final UserModel? receiverData = await ref
          .read(authRepositoryProvider)
          .getCurrentUserDataOrByUId(receiverId);

      final UserModel? senderData = await ref
          .watch(authRepositoryProvider)
          .getCurrentUserDataOrByUId(firebaseAuth.currentUser!.uid);

      GroupContactModel? groupContactData;
      if (isGroupChat) {
        groupContactData = await ref
            .read(groupControllerProvider)
            .getGroupContactData(receiverId);
      }

      final String? fileUrl = await ref
          .read(commonFirestoreRepositoryProvider)
          .storeFileToFirestore(
            file: file,
            ref: isGroupChat
                ? 'groups/${groupContactData!.groupId}/${groupContactData.lastMessage}/${groupContactData.senderId}/$messageId'
                : 'chats/$lastMessageContent/${senderData!.uid}/${receiverData!.uid}/$messageId',
          );

      isGroupChat
          ? _saveGroupContactDataToChatGroupSubCollection(
              name: groupContactData!.name,
              lastMessage: lastMessageContent,
              memberIds: groupContactData.memberIds,
              groupAvatarUrl: groupContactData.groupAvatarUrl,
              senderId: senderData!.uid,
              groupId: groupContactData.groupId,
              date: timeSent,
            )
          : _saveContactDataToChatSubCollection(
              text: lastMessageContent,
              timeSent: timeSent,
              receiverData: receiverData!,
              senderData: senderData!,
            );

      isGroupChat
          ? _saveGroupMessageDataToChatGroupSubCollection(
              membersSeenMessageUId: [],
              groupId: receiverId,
              // receiverData: receiverData,
              senderData: senderData,
              timeSent: timeSent,
              text: fileUrl!,
              messageType: messageType,
              messageId: messageId,
              receiverName: receiverName,
              senderNameOfReplyMessage: messageReplyData?.messageSenderName,
              replyMessageItemIndex: messageReplyData?.replyMessageItemIndex,
              currentChatLengths: messageReplyData?.replyMessageItemIndex,
              replyText: messageReplyData?.message,
              replyTitle: messageReplyData?.message,
              replyMessageType: messageReplyData?.messageType,
              isReplyToYourself: messageReplyData?.isReplyToMe,
              ref: ref,
            )
          : _saveMessageDataToChatSubCollection(
              receiverName: receiverName,
              receiverData: receiverData!,
              senderData: senderData,
              timeSent: timeSent,
              text: fileUrl!,
              messageType: messageType,
              messageId: messageId,
              replyMessageItemIndex: messageReplyData?.replyMessageItemIndex,
              replyMessageType: messageReplyData?.messageType,
              replyText: messageReplyData?.message,
              replyTitle: messageReplyData?.title,
              isReplyToYourself: messageReplyData?.isReplyToMe,
              currentChatLengths: messageReplyData?.replyMessageItemIndex,
              senderNameOfReplyMessage: messageReplyData?.messageSenderName,
              ref: ref,
            );
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar(context, 'Something went wrong. Please try again.');
      rethrow;
    }
  }

  Future<void> sentGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String receiverId,
    required ProviderRef ref,
    required String receiverName,
    required bool isGroupChat,
  }) async {
    final timeSent = DateTime.now().toIso8601String();
    final String messageId = const Uuid().v1();
    final messageReplyData = ref.read(messageReplyStateProvider);

    final int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    final String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    final String displayGifUrl =
        'https://i.giphy.com/media/$gifUrlPart/200.gif';

    try {
      final UserModel? receiverData = await ref
          .watch(authRepositoryProvider)
          .getCurrentUserDataOrByUId(receiverId);

      final UserModel? senderData = await ref
          .watch(authRepositoryProvider)
          .getCurrentUserDataOrByUId(firebaseAuth.currentUser!.uid);

      GroupContactModel? groupContactData;
      if (isGroupChat) {
        groupContactData = await ref
            .read(groupControllerProvider)
            .getGroupContactData(receiverId);
      }

      isGroupChat
          ? _saveGroupContactDataToChatGroupSubCollection(
              name: groupContactData!.name,
              lastMessage: 'GIF',
              memberIds: groupContactData.memberIds,
              groupAvatarUrl: groupContactData.groupAvatarUrl,
              senderId: senderData!.uid,
              groupId: groupContactData.groupId,
              date: timeSent,
            )
          : _saveContactDataToChatSubCollection(
              text: 'GIF',
              timeSent: timeSent,
              receiverData: receiverData!,
              senderData: senderData!,
            );

      isGroupChat
          ? _saveGroupMessageDataToChatGroupSubCollection(
              membersSeenMessageUId: [],
              groupId: receiverId,
              // receiverData: receiverData!,
              senderData: senderData,
              timeSent: timeSent,
              text: displayGifUrl,
              messageType: MessageTypeEnum.gif,
              messageId: messageId,
              receiverName: receiverName,
              senderNameOfReplyMessage: messageReplyData?.messageSenderName,
              replyMessageItemIndex: messageReplyData?.replyMessageItemIndex,
              currentChatLengths: messageReplyData?.replyMessageItemIndex,
              replyText: messageReplyData?.message,
              replyTitle: messageReplyData?.message,
              replyMessageType: messageReplyData?.messageType,
              isReplyToYourself: messageReplyData?.isReplyToMe,
              ref: ref,
            )
          : _saveMessageDataToChatSubCollection(
              receiverName: receiverName,
              receiverData: receiverData!,
              senderData: senderData,
              timeSent: timeSent,
              text: displayGifUrl,
              messageType: MessageTypeEnum.gif,
              messageId: messageId,
              replyMessageItemIndex: messageReplyData?.replyMessageItemIndex,
              replyMessageType: messageReplyData?.messageType,
              replyText: messageReplyData?.message,
              replyTitle: messageReplyData?.title,
              isReplyToYourself: messageReplyData?.isReplyToMe,
              currentChatLengths: messageReplyData?.replyMessageItemIndex,
              senderNameOfReplyMessage: messageReplyData?.messageSenderName,
              ref: ref,
            );
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar(context, 'Something went wrong. Please try again.');
    }
  }

  void setMessageSeenStatus({
    required BuildContext context,
    required String receiverId,
    required String messageId,
  }) {
    try {
      firebaseFirestore
        ..collection('users')
            .doc(receiverId)
            .collection('chatContacts')
            .doc(firebaseAuth.currentUser!.uid)
            .collection('messages')
            .doc(messageId)
            .update({'isSeen': true})
        ..collection('users')
            .doc(firebaseAuth.currentUser!.uid)
            .collection('chatContacts')
            .doc(receiverId)
            .collection('messages')
            .doc(messageId)
            .update({'isSeen': true}).then((value) {
          print('Set message seen status succeed');
        });
    } catch (e) {
      print(e);
      showSnackbar(context, e.toString());
    }
  }

  Future<void> updateUnreadMessagesState({
    required bool isHavingUnreadMessages,
    required String receiverId,
  }) async {
    await firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('chatContacts')
        .doc(receiverId)
        .update({'isHavingUnreadMessages': isHavingUnreadMessages}).then(
      (value) => print('updated unread messages state.'),
    );
  }
}
