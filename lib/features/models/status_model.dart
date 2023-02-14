import 'package:cloud_firestore/cloud_firestore.dart';
class StatusModel {
  final String date;
  final String statusId;
  final String ownerId;
  final String ownerName;
  final String ownerPhoneNumber;
  final String ownerProfilePic;
  final List<String> whoCanSee;
  final List<String> photoUrls;

  StatusModel({
    required this.date,
    required this.statusId,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhoneNumber,
    required this.ownerProfilePic,
    required this.whoCanSee,
    required this.photoUrls,
  });

  Map<String, dynamic> toDocument() {
    return <String, dynamic>{
      'date': date,
      'statusId': statusId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhoneNumber': ownerPhoneNumber,
      'ownerProfilePic': ownerProfilePic,
      'whoCanSee': whoCanSee,
      'photoUrls': photoUrls,
    };
  }

  factory StatusModel.fromSnapshot(DocumentSnapshot snap) {
    return StatusModel(
      date: snap['date'] as String,
      statusId: snap['statusId'] as String,
      ownerId: snap['ownerId'] as String,
      ownerName: snap['ownerName'] as String,
      ownerPhoneNumber: snap['ownerPhoneNumber'] as String,
      ownerProfilePic: snap['ownerProfilePic'] as String,
      whoCanSee: List<String>.from((snap['whoCanSee'] as List<dynamic>)),
      photoUrls: List<String>.from((snap['photoUrls'] as List<dynamic>)),
    );
  }
}
