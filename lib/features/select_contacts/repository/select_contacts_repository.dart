import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:riverpod/riverpod.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/features/chat/screens/mobile_chat_screen.dart';

final selectContactsRepositoryProvider =
    Provider<SelectContactsRepository>((ref) {
  return SelectContactsRepository(
    firebaseFirestore: FirebaseFirestore.instance,
    ref: ref,
  );
});

class SelectContactsRepository {
  final FirebaseFirestore firebaseFirestore;
  final ProviderRef ref;

  const SelectContactsRepository({
    required this.firebaseFirestore,
    required this.ref,
  });

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: true,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  Future<void> selectContact({
    required Contact contact,
    required BuildContext context,
  }) async {
    return await firebaseFirestore.collection('users').get().then(
      (users) async {
        final user = users.docs.firstWhere(
          (user) =>
              user.get('phoneNumber') ==
              contact.phones[0].number.replaceAll(' ', ''),
        );
        if (user.exists) {
          Navigator.pushReplacementNamed(
            context,
            MobileChatScreen.routeName,
            arguments: {
              // 'currentUserName': currentUserData!.name,
              'receiverName': user.get('name') as String,
              'receiverId': user.id,
              'isGroup': false,
            },
          );
        } else {
          showSnackbar(context, 'There is no account for this phone number.');
        }
        return;
      },
    );
  }
}
