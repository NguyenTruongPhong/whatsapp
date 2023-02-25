// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/features/models/call_model.dart';
import 'package:whatsapp_ui/features/models/user_model.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';


final callRepositoryProvider = Provider((ref) {
  return CallRepository(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
  );
});

class CallRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  CallRepository({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  Stream<CallModel?> getCallDataStream() {
    return firebaseFirestore
        .collection('call')
        .doc(firebaseAuth.currentUser!.uid)
        .snapshots()
        .map((snap) => CallModel.fromSnapshot(snap));
  }

  Future<void> updateHasDialled(String receiverId) {
    return firebaseFirestore
        .collection('call')
        .doc(receiverId)
        .update({'hasDialled': true});
  }

  Stream<CallModel?> getReceiverCallDataStream(String receiverId) {
    return firebaseFirestore
        .collection('call')
        .doc(receiverId)
        .snapshots()
        .map((snap) => CallModel.fromSnapshot(snap));
  }

  Future<ZegoSendCallInvitationButton> makeAudioCall({
    required BuildContext context,
    required ProviderRef ref,
    required String receiverId,
    required bool isGroupChat,
  }) async {
    // final String callId = const Uuid().v1();
    // late final UserModel? callerData;
    late final UserModel? receiverData;
    // late final CallModel caller;
    // late final CallModel receiver;

    try {
      // await ref.read(authControllerProvider).getCurrentUserDataOrByUId().then(
      //       (caller) => callerData = caller,
      //     );
      await ref
          .read(authControllerProvider)
          .getCurrentUserDataOrByUId(receiverId)
          .then(
            (receiver) => receiverData = receiver,
          );

      return ZegoSendCallInvitationButton(
        icon: ButtonIcon(icon: const Icon(Icons.call)),
        resourceID: "zegouikit_call",
        invitees: [
          ZegoUIKitUser(
            id: receiverData!.uid,
            name: receiverData!.name,
          ),
        ],
        isVideoCall: false,
        customData: isGroupChat ? 'isGroup: true' : 'isGroup: false',
      );

      // caller = CallModel(
      //   callerId: callerData!.uid,
      //   callerName: callerData!.name,
      //   callerPicUrl: callerData!.profilePicUrl,
      //   receiverId: receiverId,
      //   receiverName: receiverData!.name,
      //   receiverPicUrl: receiverData!.profilePicUrl,
      //   callId: callId,
      //   hasDialled: true,
      // );
      // receiver = CallModel(
      //   callerId: callerData!.uid,
      //   callerName: callerData!.name,
      //   callerPicUrl: callerData!.profilePicUrl,
      //   receiverId: receiverId,
      //   receiverName: receiverData!.name,
      //   receiverPicUrl: receiverData!.profilePicUrl,
      //   callId: callId,
      //   hasDialled: false,
      // );

      // await firebaseFirestore
      //     .collection('call')
      //     .doc(caller.callerId)
      //     .set(caller.toDocument());

      // return await firebaseFirestore
      //     .collection('call')
      //     .doc(receiver.receiverId)
      //     .set(receiver.toDocument())
      //     .then((value) {
      //   Navigator.of(context).pushNamed(CallingScreen.routeName, arguments: {
      //     'call': caller,
      //     'isGroup': false,
      //     'chanelId': callId,
      //   });
      // });
    } catch (e) {
      debugPrint(e.toString());
      showSnackbar(context, e.toString());
      rethrow;
    }
  }

  Future<void> endCall({
    required BuildContext context,
    required ProviderRef ref,
    required String receiverId,
    required String callerId,
  }) async {
    await firebaseFirestore.collection('call').doc(callerId).delete();
    return await firebaseFirestore.collection('call').doc(receiverId).delete();
  }
}
