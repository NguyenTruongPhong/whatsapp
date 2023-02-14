import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/enums/enums.dart';
import 'package:whatsapp_ui/features/chat/widgets/message_content.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';

import '../../models/user_model.dart';

class NormalMessage extends ConsumerStatefulWidget {
  const NormalMessage({
    Key? key,
    required this.messageType,
    required this.message,
    required this.date,
    required this.color,
    required this.isGroupChat,
    this.avatarUrl,
    this.isSeen,
    this.isLastedMessage = false,
    this.membersSeenMessageUId,
    required this.isSenderMessage,
  }) : super(key: key);

  final MessageTypeEnum messageType;
  final String message;
  final String date;
  final bool? isSeen;
  final Color color;
  final bool isGroupChat;
  final String? avatarUrl;
  final bool isLastedMessage;
  final List<String>? membersSeenMessageUId;
  final bool isSenderMessage;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NormalMessageState();
}

class _NormalMessageState extends ConsumerState<NormalMessage> {
  bool isShowDetailMessageSeenMembers = false;
  bool isShowRandomDetailMessageSeenMembers = false;

  void toggleMessageSeenMembers() {
    isShowDetailMessageSeenMembers = !isShowDetailMessageSeenMembers;
    setState(() {});
  }

  void toggleShowRandomMessageSeenMembers() {
    isShowRandomDetailMessageSeenMembers =
        !isShowRandomDetailMessageSeenMembers;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: widget.isSenderMessage
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: toggleShowRandomMessageSeenMembers,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: widget.isSenderMessage
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (widget.isGroupChat && widget.avatarUrl != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 7),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(
                      widget.avatarUrl!,
                    ),
                  ),
                ),
              ],
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: widget.avatarUrl == null
                      ? size.width * 0.7
                      : size.width * 0.6,
                  minHeight: 60,
                  maxHeight: widget.messageType == MessageTypeEnum.video ||
                          widget.messageType == MessageTypeEnum.image
                      ? size.height * 0.3
                      : double.infinity,
                  minWidth: 110,
                ),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: widget.color,
                  margin: widget.isGroupChat
                      ? const EdgeInsets.symmetric(horizontal: 15, vertical: 7)
                      : const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  child: Stack(
                    children: [
                      Padding(
                        padding: widget.messageType != MessageTypeEnum.text
                            ? const EdgeInsets.only(
                                left: 5,
                                right: 5,
                                top: 5,
                                bottom: 25,
                              )
                            : const EdgeInsets.only(
                                left: 10,
                                right: 30,
                                top: 5,
                                bottom: 25,
                              ),
                        child: MessageContent(
                          message: widget.message,
                          messageType: widget.messageType,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 10,
                        child: Row(
                          children: [
                            Text(
                              widget.date,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white60,
                              ),
                            ),
                            if (widget.isSeen != null && widget.isSeen!) ...[
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Icons.done_all,
                                size: 20,
                                color: Colors.white60,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.isGroupChat &&
            widget.isLastedMessage &&
            widget.membersSeenMessageUId!.isNotEmpty) ...[
          buildShowMembersSeenMessage(size)
        ],
        if (widget.isGroupChat &&
            !widget.isLastedMessage &&
            isShowRandomDetailMessageSeenMembers) ...[
          BuildShowRandomDetailMessageSeenMembers(
            ref: ref,
            size: size,
            avatarUrl: widget.avatarUrl,
            membersSeenMessageUId: widget.membersSeenMessageUId,
          )
        ],
      ],
    );
  }

  Padding buildShowMembersSeenMessage(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: StreamBuilder<List<UserModel>>(
        stream: ref
            .watch(groupControllerProvider)
            .getGroupMembersSeenMessageDataStream(
                widget.membersSeenMessageUId!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<UserModel> seenMessageMembers = snapshot.data!;
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.avatarUrl == null
                    ? size.width * 0.7
                    : size.width * 0.6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isShowDetailMessageSeenMembers) ...[
                    Text(
                      seenMessageMembers
                          .map(
                            (seenMessageMember) => seenMessageMember.name,
                          )
                          .join(', '),
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 10,
                      ),
                      softWrap: true,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (seenMessageMembers.length > 7) ...[
                        GestureDetector(
                          onTap: toggleMessageSeenMembers,
                          child: Container(
                            alignment: Alignment.center,
                            width: 30,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: greyColor,
                            ),
                            child: Text(
                              '+${seenMessageMembers.length - 9}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                      ...seenMessageMembers
                          .getRange(
                            0,
                            seenMessageMembers.length > 9
                                ? 9
                                : seenMessageMembers.length,
                          )
                          .map(
                            (seenMessageMember) => Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: CircleAvatar(
                                radius: 8,
                                backgroundImage: NetworkImage(
                                  seenMessageMember.profilePicUrl,
                                ),
                              ),
                            ),
                          )
                          .toList()
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}

class BuildShowRandomDetailMessageSeenMembers extends StatelessWidget {
  const BuildShowRandomDetailMessageSeenMembers({
    Key? key,
    required this.ref,
    required this.size,
    required this.avatarUrl,
    required this.membersSeenMessageUId,
  }) : super(key: key);

  final WidgetRef ref;
  final String? avatarUrl;
  final List<String>? membersSeenMessageUId;

  final Size size;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: ref
          .watch(groupControllerProvider)
          .getGroupMembersSeenMessageDataStream(membersSeenMessageUId!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<UserModel> seenMessageMembers = snapshot.data!;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: avatarUrl == null ? size.width * 0.7 : size.width * 0.6,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 15,
              ),
              child: Text(
                seenMessageMembers
                    .map(
                      (seenMessageMember) => seenMessageMember.name,
                    )
                    .join(', '),
                style: const TextStyle(
                  color: greyColor,
                  fontSize: 10,
                ),
                softWrap: true,
                // textAlign: TextAlign.start,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
