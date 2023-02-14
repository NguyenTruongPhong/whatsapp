import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/screens/error_screen.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/group_contact_item.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';
import 'package:whatsapp_ui/features/models/chat_contact_model.dart';
import 'package:whatsapp_ui/features/models/group_contact_model.dart';

import 'chat_contact_item.dart';

class ContactsList extends ConsumerWidget {
  const ContactsList({
    Key? key,
    // required this.currentUserName,
  }) : super(key: key);
  // final String currentUserName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<GroupContactModel>>(
              stream: ref.watch(groupControllerProvider).getGroupContacts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Loader();
                }
                if (snapshot.hasData) {
                  final List<GroupContactModel>? groupContacts = snapshot.data;

                  if (groupContacts == null) {
                    return const SizedBox();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 0),
                    shrinkWrap: true,
                    itemCount: groupContacts.length,
                    itemBuilder: (context, index) {
                      return GroupContactItem(
                        // currentUserName: currentUserName,
                        groupContact: groupContacts[index],
                        groupId: groupContacts[index].groupId,
                      );
                    },
                  );
                } else {
                  return const ErrorScreen();
                }
              },
            ),
            StreamBuilder<List<ChatContactModel>?>(
              stream: ref.watch(chatControllerProvider).getChatContacts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Loader();
                }
                if (snapshot.hasData) {
                  final List<ChatContactModel>? contacts = snapshot.data;
                  if (contacts == null) {
                    return const Center(
                      child: Text('Start to have a new conversation.'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      return ChatContactItem(
                        contact: contacts[index],
                        // currentUserName: currentUserName,
                      );
                    },
                  );
                } else {
                  return const ErrorScreen();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
