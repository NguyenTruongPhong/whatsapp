import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../colors.dart';
import '../../../common/providers/refresh_screen.dart';
import '../../../common/providers/toggle_group_chat.dart';
import '../../auth/controller/auth_controller.dart';
import '../../models/chat_contact_model.dart';
import '../../models/user_model.dart';
import '../screens/mobile_chat_screen.dart';

class ChatContactItem extends ConsumerWidget {
  const ChatContactItem({
    Key? key,
    required this.contact,
    // required this.currentUserName,
  }) : super(key: key);

  final ChatContactModel contact;
  // final String currentUserName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            ref.read(toggleGroupChatProvider.notifier).update((state) => false);
            Navigator.of(context).pushNamed(
              MobileChatScreen.routeName,
              arguments: {
                // 'currentUserName': currentUserName,
                'receiverId': contact.id,
                'receiverName': contact.name,
                'isGroup': false,
              },
            ).then(
              // refresh the mobile layout screen in the case not ready cancel the search field
              (value) => ref
                  .read(refreshScreenStateProvider.notifier)
                  .update((state) => true),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              // contentPadding: const EdgeInsets.only(bottom: 8.0),
              title: Text(
                contact.name,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  contact.lastMessage,
                  style: const TextStyle(fontSize: 15),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              leading: SizedBox(
                width: 50,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: contact.profilePicUrl,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 30,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 10,
                      child: StreamBuilder<UserModel>(
                        stream: ref
                            .watch(authControllerProvider)
                            .getUserDataById(contact.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.isOnline) {
                              return Container(
                                height: 10,
                                width: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: greenColor,
                                ),
                              );
                            }
                            return Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: greyColor,
                              ),
                            );
                          }
                          return Container(
                            height: 10,
                            width: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: greyColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.Hm().format(DateTime.parse(contact.timeSent)),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  contact.isHavingUnreadMessages
                      ? Container(
                          height: 15,
                          width: 15,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: greenColor,
                          ),
                        )
                      : const SizedBox(),
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
