import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';
import 'package:whatsapp_ui/features/models/group_contact_model.dart';
import 'package:whatsapp_ui/features/models/user_model.dart';
import 'package:whatsapp_ui/widgets/chat_list.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../widgets/bottom_chat_field.dart';

class MobileChatScreen extends ConsumerStatefulWidget {
  const MobileChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.isGroupChat,
  }) : super(key: key);

  final String receiverId;
  final String receiverName;
  final bool isGroupChat;

  static const String routeName = '/mobile-chat';

  static Route route({
    required String receiverId,
    required String receiverName,
    required bool isGroup,
  }) {
    return MaterialPageRoute(
      builder: (_) => MobileChatScreen(
        isGroupChat: isGroup,
        receiverId: receiverId,
        receiverName: receiverName,
      ),
      settings: const RouteSettings(
        name: routeName,
      ),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MobileChatScreenState();
}

class _MobileChatScreenState extends ConsumerState<MobileChatScreen> {
  late final List<UserModel> groupMembersData;

  ZegoSendCallInvitationButton makeVideoCall() {
    return ZegoSendCallInvitationButton(
      icon: ButtonIcon(icon: const Icon(Icons.video_call)),
      resourceID: "zegouikit_call",
      invitees: widget.isGroupChat
          ? groupMembersData
              .map((memberData) => ZegoUIKitUser(
                    id: memberData.uid,
                    name: memberData.name,
                  ))
              .toList()
          : [
              ZegoUIKitUser(
                id: widget.receiverId,
                name: widget.receiverName,
              )
            ],
      isVideoCall: true,
      // customData: widget.receiverId,
    );
  }

  ZegoSendCallInvitationButton makeAudioCall() {
    return ZegoSendCallInvitationButton(
      icon: ButtonIcon(icon: const Icon(Icons.call)),
      resourceID: "zegouikit_call",
      invitees: widget.isGroupChat
          ? groupMembersData
              .map((memberData) => ZegoUIKitUser(
                    id: memberData.uid,
                    name: memberData.name,
                  ))
              .toList()
          : [
              ZegoUIKitUser(
                id: widget.receiverId,
                name: widget.receiverName,
              )
            ],
      isVideoCall: false,
      // customData: widget.receiverId,
    );
  }

  Widget buildScaffold({
    required final currentUserName,
    required String currentUserUId,
  }) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: widget.isGroupChat
            ? StreamBuilder2<GroupContactModel, bool>(
                streams: StreamTuple2(
                  ref
                      .watch(groupControllerProvider)
                      .getGroupContactDataStream(widget.receiverId),
                  ref
                      .watch(groupControllerProvider)
                      .getGroupOnlineStatus(widget.receiverId),
                ),
                builder: (context, snapshot) {
                  if (snapshot.snapshot1.connectionState ==
                          ConnectionState.waiting ||
                      snapshot.snapshot1.connectionState ==
                          ConnectionState.waiting) {
                    return const Loader();
                  }
                  return BuildChatScreenAppBarTitle(
                    receiverName: snapshot.snapshot1.data!.name,
                    isOnline: snapshot.snapshot2.data!,
                  );
                },
              )
            : StreamBuilder<UserModel>(
                stream: ref
                    .watch(authControllerProvider)
                    .getUserDataById(widget.receiverId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Loader();
                  }
                  return BuildChatScreenAppBarTitle(
                    isOnline: snapshot.data!.isOnline,
                    receiverName: widget.receiverName,
                  );
                },
              ),
        centerTitle: false,
        actions: [
          makeVideoCall(),
          makeAudioCall(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: ChatList(
                currentUserName: currentUserName,
                receiverId: widget.receiverId,
                isGroupChat: widget.isGroupChat,
                currentUserUId: currentUserUId,
              ),
            ),
            BottomChatField(
              receiverId: widget.receiverId,
              receiverName: widget.receiverName,
              isGroupChat: widget.isGroupChat,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      initialData: const [],
      future: widget.isGroupChat
          ? ref
              .read(groupControllerProvider)
              .getGroupMembersData(context: context, groupId: widget.receiverId)
          : null,
      builder: (context, snapshot1) {
        if (snapshot1.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else {
          if (widget.isGroupChat) groupMembersData = snapshot1.data!;
          return FutureBuilder<UserModel?>(
            future:
                ref.read(authControllerProvider).getCurrentUserDataOrByUId(),
            builder: (context, snapshot2) {
              if (snapshot2.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return buildScaffold(
                currentUserName: snapshot2.data!.name,
                currentUserUId: snapshot2.data!.uid,
              );
            },
          );
        }
      },
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
        Text(
          receiverName,
          style: const TextStyle(fontSize: 16),
        ),
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
