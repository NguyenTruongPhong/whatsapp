// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatsapp_ui/features/call/repository/call_repository.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../models/call_model.dart';

final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(callRepository: callRepository, ref: ref);
});

class CallController {
  final CallRepository callRepository;
  final ProviderRef ref;

  CallController({
    required this.callRepository,
    required this.ref,
  });

  Stream<CallModel?> getCallDataStream() {
    return callRepository.getCallDataStream();
  }

  Future<ZegoSendCallInvitationButton> makeAudioCall({
    required BuildContext context,
    required String receiverId,
    required bool isGroupChat,
  }) async {
    return callRepository.makeAudioCall(
      context: context,
      ref: ref,
      receiverId: receiverId,
      isGroupChat: isGroupChat,
    );
  }

  Stream<CallModel?> getReceiverCallDataStream(String receiverId) {
    return callRepository.getReceiverCallDataStream(receiverId);
  }

  Future<void> updateHasDialled(String receiverId) {
    return callRepository.updateHasDialled(receiverId);
  }

  Future<void> endCall({
    required BuildContext context,
    required String receiverId,
    required String callerId,
  }) async {
    await callRepository.endCall(
      context: context,
      ref: ref,
      receiverId: receiverId,
      callerId: callerId,
    );
  }
}
