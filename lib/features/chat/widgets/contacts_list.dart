import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/providers/searching.dart';
import 'package:whatsapp_ui/common/screens/error_screen.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/group_contact_item.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';
import 'package:whatsapp_ui/features/models/chat_contact_model.dart';
import 'package:whatsapp_ui/features/models/group_contact_model.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';

import 'chat_contact_item.dart';

class ContactsList extends ConsumerStatefulWidget {
  const ContactsList({
    Key? key,
  }) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContactListState();
}

class _ContactListState extends ConsumerState<ContactsList> {
  List<GroupContactModel> groupContacts = [];
  List<ChatContactModel> chatContacts = [];
  List<dynamic> displayContacts = [];

  void setupData(
    List<GroupContactModel> groupContacts,
    List<ChatContactModel> chatContacts,
  ) {
    groupContacts = List.from(groupContacts);
    chatContacts = List.from(chatContacts);
    displayContacts = [...groupContacts, ...chatContacts];
    displayContacts = sortData(List.from(displayContacts));
    displayContacts = searching();
  }

  List<dynamic> sortData(List<dynamic> data) {
    data.sort((a, b) {
      if (a.runtimeType == GroupContactModel) {
        if (b.runtimeType == GroupContactModel) {
          return DateTime.parse((a as GroupContactModel).date)
              .millisecondsSinceEpoch
              .compareTo(DateTime.parse((b as GroupContactModel).date)
                  .millisecondsSinceEpoch);
        } else {
          return DateTime.parse((a as GroupContactModel).date)
              .millisecondsSinceEpoch
              .compareTo(DateTime.parse((b as ChatContactModel).timeSent)
                  .millisecondsSinceEpoch);
        }
      } else {
        if (b.runtimeType == GroupContactModel) {
          return DateTime.parse((a as ChatContactModel).timeSent)
              .millisecondsSinceEpoch
              .compareTo(DateTime.parse((b as GroupContactModel).date)
                  .millisecondsSinceEpoch);
        } else {
          return DateTime.parse((a as ChatContactModel).timeSent)
              .millisecondsSinceEpoch
              .compareTo(DateTime.parse((b as ChatContactModel).timeSent)
                  .millisecondsSinceEpoch);
        }
      }
    });
    return data.reversed.toList();
  }

  List<dynamic> searching() {
    List<dynamic> filterContacts = List.from(
      displayContacts.where((element) {
        if (element.runtimeType == GroupContactModel) {
          return (element as GroupContactModel)
              .name
              .toLowerCase()
              .contains(ref.watch(searchingStateProvider).toLowerCase());
        } else {
          return (element as ChatContactModel)
              .name
              .toLowerCase()
              .contains(ref.watch(searchingStateProvider).toLowerCase());
        }
      }).toList(),
    );
    return filterContacts;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder2<List<GroupContactModel>, List<ChatContactModel>?>(
      streams: StreamTuple2(
        ref.watch(groupControllerProvider).getGroupContacts(),
        ref.watch(chatControllerProvider).getChatContacts(),
      ),
      builder: (context, snapshot) {
        if (snapshot.snapshot1.connectionState == ConnectionState.waiting ||
            snapshot.snapshot2.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.snapshot1.hasData && snapshot.snapshot2.hasData) {
          setupData(snapshot.snapshot1.data!, snapshot.snapshot2.data!);
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ListView.builder(
              itemCount: displayContacts.length,
              itemBuilder: (context, index) {
                final displayContact = displayContacts[index];
                if (displayContact.runtimeType == GroupContactModel) {
                  final groupContact = displayContact as GroupContactModel;
                  return GroupContactItem(
                    groupContact: groupContact,
                    groupId: groupContact.groupId,
                  );
                } else {
                  final chatContact = displayContact as ChatContactModel;
                  return ChatContactItem(contact: chatContact);
                }
              },
            ),
          );
        } else {
          return const ErrorScreen();
        }
      },
    );
  }
}
