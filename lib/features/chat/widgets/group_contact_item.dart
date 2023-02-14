import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';
import 'package:whatsapp_ui/features/models/group_contact_model.dart';

import '../../../colors.dart';
import '../screens/mobile_chat_screen.dart';

class GroupContactItem extends ConsumerWidget {
  const GroupContactItem({
    Key? key,
    required this.groupContact,
    required this.groupId,
    // required this.currentUserName,
  }) : super(key: key);

  final GroupContactModel groupContact;
  final String groupId;
  // final String currentUserName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              MobileChatScreen.routeName,
              arguments: {
                // 'currentUserName':currentUserName,
                'receiverId': groupContact.groupId,
                'receiverName': groupContact.name,
                'isGroup': true,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      groupContact.groupAvatarUrl,
                    ),
                    radius: 30,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 10,
                    child: StreamBuilder<bool>(
                      stream: ref
                          .watch(groupControllerProvider)
                          .getGroupOnlineStatus(groupId),
                      initialData: false,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          bool isAnyMemberOnline = snapshot.data!;
                          // print(isAnyMemberOnline);
                          return Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAnyMemberOnline ? greenColor : greyColor,
                            ),
                          );
                        } else {
                          return Container(
                            height: 10,
                            width: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: greyColor,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              title: Text(
                groupContact.name,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  groupContact.lastMessage,
                  style: const TextStyle(fontSize: 15),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.Hm().format(DateTime.parse(groupContact.date)),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  // groupContact.isHavingUnreadMessages
                  //     ? Container(
                  //         height: 15,
                  //         width: 15,
                  //         decoration: const BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: greenColor,
                  //         ),
                  //       )
                  //     : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
        const Divider(color: dividerColor, indent: 85),
      ],
    );
  }
}
