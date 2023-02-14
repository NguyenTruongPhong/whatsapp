import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_ui/common/repositories/common_firestore_repository.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/auth/repository/auth_repository.dart';
import 'package:whatsapp_ui/features/models/status_model.dart';
import 'package:whatsapp_ui/features/models/user_model.dart';
import 'package:whatsapp_ui/features/select_contacts/repository/select_contacts_repository.dart';

final statusContactsRepositoryProvider = Provider((ref) {
  return StatusRepository(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
  );
});

class StatusRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  StatusRepository({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  Future<void> addStatus({
    required File statusPhoto,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    final date = DateTime.now().toIso8601String();
    final String statusId = const Uuid().v1();
    List<String> photoUrls = [];
    List<String> whoCanSeeUIds = [];

    try {
      final UserModel? ownerData = await ref
          .read(authRepositoryProvider)
          .getCurrentUserDataOrByUId(firebaseAuth.currentUser!.uid);

      final String? photoUrl = await ref
          .read(commonFirestoreRepositoryProvider)
          .storeFileToFirestore(
            file: statusPhoto,
            ref: 'status/${ownerData!.uid}/$statusId',
          );

      await firebaseFirestore
          .collection('status')
          .where('ownerId', isEqualTo: ownerData.uid)
          .orderBy('date', descending: true)
          .get()
          .then((statuses) {
        if (statuses.docs.isNotEmpty) {
          StatusModel latestStatus = StatusModel.fromSnapshot(statuses.docs[0]);
          photoUrls = latestStatus.photoUrls..add(photoUrl!);
        } else {
          photoUrls = [photoUrl!];
        }
      });

      List<Contact> contacts =
          await ref.read(selectContactsRepositoryProvider).getContacts();
      for (var contact in contacts) {
        if (contact.phones.isNotEmpty) {
          await firebaseFirestore
              .collection('users')
              .where(
                'phoneNumber',
                isEqualTo: contact.phones[0].number.replaceAll(' ', ''),
              )
              .get()
              .then((users) {
            if (users.docs.isNotEmpty) {
              final UserModel currentUser =
                  UserModel.fromSnapshot(users.docs[0]);
              whoCanSeeUIds.add(currentUser.uid);
            }
          });
        }
      }

      final newStatus = StatusModel(
        date: date,
        statusId: statusId,
        ownerId: ownerData.uid,
        ownerName: ownerData.name,
        ownerPhoneNumber: ownerData.phoneNumber,
        ownerProfilePic: ownerData.profilePicUrl,
        whoCanSee: whoCanSeeUIds,
        photoUrls: photoUrls,
      );
      await firebaseFirestore
          .collection('status')
          .doc(statusId)
          .set(newStatus.toDocument())
          .then((value) {
        print('Add new status succeed.');
      });
    } catch (e) {
      print(e);
      showSnackbar(context, e.toString());
    }
  }

  Stream<List<StatusModel>?> getStatuses() {
    return firebaseFirestore
        .collection('status')
        .orderBy('date', descending: true)
        // .where('whoCanSee', arrayContains: firebaseAuth.currentUser!.uid)
        .snapshots()
        .map((statuses) {
      return statuses.docs
          .map((snap) => StatusModel.fromSnapshot(snap))
          .where(
            (status) => status.whoCanSee.contains(
              firebaseAuth.currentUser!.uid,
            ),
          )
          .toList();
    });
  }
}
