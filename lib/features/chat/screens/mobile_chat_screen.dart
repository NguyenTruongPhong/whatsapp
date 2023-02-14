import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';
import 'package:whatsapp_ui/features/models/group_contact_model.dart';
import 'package:whatsapp_ui/features/models/user_model.dart';
import 'package:whatsapp_ui/widgets/chat_list.dart';

import '../widgets/bottom_chat_field.dart';

class MobileChatScreen extends ConsumerWidget {
  const MobileChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.isGroupChat,
    // required this.currentUserName,
  }) : super(key: key);

  final String receiverId;
  final String receiverName;
  final bool isGroupChat;
  // final String currentUserName;

  static const String routeName = '/mobile-chat';

  static Route route({
    required String receiverId,
    required String receiverName,
    required bool isGroup,
    // required String currentUserName,
  }) {
    return MaterialPageRoute(
      builder: (_) => MobileChatScreen(
        isGroupChat: isGroup,
        receiverId: receiverId,
        receiverName: receiverName,
        // currentUserName: currentUserName,
      ),
      settings: const RouteSettings(
        name: routeName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: isGroupChat
              ? StreamBuilder<GroupContactModel>(
                  stream: ref
                      .watch(groupControllerProvider)
                      .getGroupContactDataStream(receiverId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Loader();
                    }
                    return StreamBuilder<bool>(
                        stream: ref
                            .watch(groupControllerProvider)
                            .getGroupOnlineStatus(receiverId),
                        builder: (context, snapshot) {
                          return BuildChatScreenAppBarTitle(
                            isOnline: snapshot.data ?? false,
                            receiverName: receiverName,
                          );
                        });
                  },
                )
              : StreamBuilder<UserModel>(
                  stream: ref
                      .watch(authControllerProvider)
                      .getUserDataById(receiverId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Loader();
                    }
                    return BuildChatScreenAppBarTitle(
                      isOnline: snapshot.data!.isOnline,
                      receiverName: receiverName,
                    );
                  },
                ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: FutureBuilder<UserModel?>(
          future: ref.read(authControllerProvider).getCurrentUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            } else {
              return Column(
                children: [
                  Expanded(
                    child: ChatList(
                      currentUserName: snapshot.data!.name,
                      receiverId: receiverId,
                      isGroupChat: isGroupChat,
                    ),
                  ),
                  BottomChatField(
                    receiverId: receiverId,
                    receiverName: receiverName,
                    isGroupChat: isGroupChat,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class BuildChatScreenAppBarTitle extends StatelessWidget {
  const BuildChatScreenAppBarTitle({
    Key? key,
    required this.receiverName,
    required this.isOnline,
  }) : super(key: key);

  final String receiverName;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(receiverName),
        Text(
          isOnline ? 'online' : 'offline',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
