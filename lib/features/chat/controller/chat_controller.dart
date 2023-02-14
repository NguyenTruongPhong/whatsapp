import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:whatsapp_ui/features/chat/repository/chat_repository.dart';
import 'package:whatsapp_ui/features/models/chat_contact_model.dart';
import 'package:whatsapp_ui/features/models/message_model.dart';

import '../../../common/enums/enums.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  const ChatController({
    required this.chatRepository,
    required this.ref,
  });

  Future<void> sentTextOrEmojiMessage({
    required String receiverId,
    required String text,
    required BuildContext context,
    required String receiverName,
    required bool isGroupChat,
  }) async {
    return chatRepository.sentTextOrEmojiMessage(
      receiverName: receiverName,
      context: context,
      text: text,
      receiverId: receiverId,
      ref: ref,
      isGroupChat: isGroupChat,
    );
  }

  Future<void> sentFileMessage({
    required BuildContext context,
    required String receiverId,
    required File file,
    required MessageTypeEnum messageType,
    required String receiverName,
    required bool isGroupChat,
  }) async {
    await chatRepository.sentFileMessage(
      receiverName: receiverName,
      context: context,
      receiverId: receiverId,
      file: file,
      messageType: messageType,
      ref: ref,
      isGroupChat: isGroupChat,
    );
  }

  Future<void> sentGIFMessage({
    required String receiverId,
    required String gifUrl,
    required BuildContext context,
    required String receiverName,
    required bool isGroupChat,
  }) async {
    return chatRepository.sentGIFMessage(
      receiverName: receiverName,
      context: context,
      gifUrl: gifUrl,
      receiverId: receiverId,
      ref: ref,
      isGroupChat: isGroupChat,
    );
  }

  Future<ChatContactModel> getSingleChatContact(String receiverId) async {
    return await chatRepository.getSingleChatContact(receiverId);
  }

  Stream<List<ChatContactModel>?> getChatContacts() {
    return chatRepository.getChatContacts();
  }

  Stream<List<MessageModel>?> getMessagesByUIdStream(String receiverId) {
    return chatRepository.getMessagesByUIdStream(receiverId);
  }

  void setMessageSeenStatus({
    required BuildContext context,
    required String receiverId,
    required String messageId,
  }) {
    chatRepository.setMessageSeenStatus(
      context: context,
      receiverId: receiverId,
      messageId: messageId,
    );
  }

  Future<void> updateUnreadMessagesState({
    required bool isHavingUnreadMessages,
    required String receiverId,
  }) {
    return chatRepository.updateUnreadMessagesState(
      isHavingUnreadMessages: isHavingUnreadMessages,
      receiverId: receiverId,
    );
  }
}
