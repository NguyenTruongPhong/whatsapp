import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String callerId;
  final String callerName;
  final String callerPicUrl;
  final String receiverId;
  final String receiverName;
  final String receiverPicUrl;
  final String callId;
  final bool hasDialled;

  CallModel({
    required this.callerId,
    required this.callerName,
    required this.callerPicUrl,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPicUrl,
    required this.callId,
    required this.hasDialled,
  });

  Map<String, dynamic> toDocument() {
    return <String, dynamic>{
      'callerId': callerId,
      'callerName': callerName,
      'callerPicUrl': callerPicUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPicUrl': receiverPicUrl,
      'callId': callId,
      'hasDialled': hasDialled,
    };
  }

  factory CallModel.fromSnapshot(DocumentSnapshot snap) {
    return CallModel(
      callerId: snap['callerId'] as String,
      callerName: snap['callerName'] as String,
      callerPicUrl: snap['callerPicUrl'] as String,
      receiverId: snap['receiverId'] as String,
      receiverName: snap['receiverName'] as String,
      receiverPicUrl: snap['receiverPicUrl'] as String,
      callId: snap['callId'] as String,
      hasDialled: snap['hasDialled'] as bool,
    );
  }
}
