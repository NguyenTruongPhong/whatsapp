import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../colors.dart';
import '../../../common/enums/enums.dart';
import '../../../common/providers/jump_to_chat_list_item.dart';
import '../../group/controller/group_controller.dart';
import '../../models/user_model.dart';
import 'message_content.dart';
import 'message_reply_content.dart';

class ReplyMessage extends ConsumerStatefulWidget {
  const ReplyMessage({
    Key? key,
    required this.replyText,
    required this.date,
    this.isSeen,
    this.receiverName,
    this.senderName,
    required this.isReplyToYourself,
    required this.message,
    required this.messageType,
    required this.replyMessageType,
    required this.color,
    required this.isSenderMessage,
    required this.replyMessageItemIndex,
    required this.currentChatLengths,
    required this.presentChatLengths,
    required this.isGroupChat,
    required this.senderNameOfReplyMessage,
    required this.currentUserName,
    this.avatarUrl,
    this.isLastedMessage = false,
    this.membersSeenMessageUId,
  }) : super(key: key);

  final String currentUserName;
  final bool isSenderMessage;
  final String replyText;
  final MessageTypeEnum replyMessageType;
  final MessageTypeEnum messageType;
  final bool isReplyToYourself;
  final int replyMessageItemIndex;
  final int currentChatLengths;
  final int presentChatLengths;
  final String? receiverName;
  final String? senderName;
  final String message;
  final String date;
  final bool? isSeen;
  final Color color;
  final bool isGroupChat;
  final String? avatarUrl;
  final String senderNameOfReplyMessage;
  final bool isLastedMessage;
  final List<String>? membersSeenMessageUId;

  @override
  ConsumerState<ReplyMessage> createState() => _ReplyMessageState();
}

class _ReplyMessageState extends ConsumerState<ReplyMessage> {
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

  // final replyMessageKey = GlobalKey();
  // // final stackKey = GlobalKey();
  // final messageKey = GlobalKey();

  // Size? replyMessageSize;
  // Size? stackSize;
  // Size? messageSize;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     getSizeAndPosition();
  //   });
  // }

  // void getSizeAndPosition() {
  //   setState(() {
  //     replyMessageSize = replyMessageKey.currentContext?.size;
  //     // stackSize = stackKey.currentContext?.size;
  //     messageSize = messageKey.currentContext?.size;
  //   });
  // }

  String get getReplyMessageTitle {
    if (widget.isGroupChat) {
      if (widget.senderName == widget.senderNameOfReplyMessage) {
        if (widget.isSenderMessage) {
          return '${widget.senderName} self-answer';
        } else {
          return 'You answer yourself';
        }
      } else {
        if (widget.isSenderMessage) {
          if (widget.senderNameOfReplyMessage == widget.currentUserName) {
            return '${widget.senderName} answer you';
          } else {
            return '${widget.senderName} answer ${widget.senderNameOfReplyMessage}';
          }
        } else {
          return 'You answer ${widget.senderNameOfReplyMessage}';
        }
      }
    } else {
      if (widget.senderName == widget.senderNameOfReplyMessage) {
        if (widget.isSenderMessage) {
          return '${widget.senderName} self-answer';
        } else {
          return 'You answer yourself';
        }
      } else {
        if (widget.isSenderMessage) {
          return '${widget.senderName} answer you';
        } else {
          return 'You answer ${widget.senderName}';
        }
      }
    }
  }

  @override
  build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      child: Column(
        crossAxisAlignment: widget.isSenderMessage
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.7),
            child: GestureDetector(
              onTap: toggleShowRandomMessageSeenMembers,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (widget.isGroupChat && widget.avatarUrl != null) ...[
                    BuildMessageAvatar(widget: widget),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                  Expanded(
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(jumpToChatListItemProvider.notifier)
                                .update(
                                  (state) => JumpToChatListItem(
                                    replyMessageItemIndex:
                                        widget.replyMessageItemIndex,
                                    presentsChatLengths:
                                        widget.presentChatLengths,
                                    chatLengthsAtTimeSent:
                                        widget.currentChatLengths,
                                  ),
                                );
                            
                          },
                          child: BuildReplyTitleAndSummary(
                            isSenderMessage: widget.isSenderMessage,
                            size: size,
                            replyMessageTitle: getReplyMessageTitle,
                            isGroupChat: widget.isGroupChat,
                            replyMessageType: widget.replyMessageType,
                            replyText: widget.replyText,
                          ),
                        ),
                        BuildNewMessage(
                          isSenderMessage: widget.isSenderMessage,
                          messageType: widget.messageType,
                          message: widget.message,
                          date: widget.date,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          widget.isGroupChat &&
                  widget.isLastedMessage &&
                  widget.membersSeenMessageUId!.isNotEmpty
              ? BuildShowMembersSeenMessage(
                  ref: ref,
                  toggleMessageSeenMembers: toggleMessageSeenMembers,
                  isShowDetailMessageSeenMembers:
                      isShowDetailMessageSeenMembers,
                  membersSeenMessageUId: widget.membersSeenMessageUId!,
                )
              : const SizedBox(),
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
      ),
    );
  }
}

class BuildShowMembersSeenMessage extends StatelessWidget {
  const BuildShowMembersSeenMessage({
    Key? key,
    required this.ref,
    required this.toggleMessageSeenMembers,
    required this.isShowDetailMessageSeenMembers,
    required this.membersSeenMessageUId,
  }) : super(key: key);
  final WidgetRef ref;
  final void Function() toggleMessageSeenMembers;
  final bool isShowDetailMessageSeenMembers;
  final List<String> membersSeenMessageUId;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: StreamBuilder<List<UserModel>>(
          stream: ref
              .watch(groupControllerProvider)
              .getGroupMembersSeenMessageDataStream(
                membersSeenMessageUId,
              ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<UserModel> seenMessageMembers = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isShowDetailMessageSeenMembers) ...[
                    Text(
                      '${seenMessageMembers.map(
                            (seenMessageMember) => seenMessageMember.name,
                          ).join(', ')} seen.',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
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
                              child: CachedNetworkImage(
                                imageUrl: seenMessageMember.profilePicUrl,
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                  radius: 8,
                                  backgroundImage: imageProvider,
                                ),
                              ),
                            ),
                          )
                          .toList()
                    ],
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          }),
    );
  }
}

class BuildNewMessage extends StatelessWidget {
  const BuildNewMessage({
    Key? key,
    required this.messageType,
    required this.message,
    required this.date,
    required this.isSenderMessage,
    this.isSeen,
  }) : super(key: key);

  final MessageTypeEnum messageType;
  final String message;
  final String date;
  final bool? isSeen;
  final bool isSenderMessage;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSenderMessage ? Alignment.topLeft : Alignment.topRight,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(0),
        color: isSenderMessage ? senderMessageColor : messageColor,
        child: Stack(
          children: [
            Padding(
              padding: messageType != MessageTypeEnum.text
                  ? const EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 5,
                      bottom: 25,
                    )
                  : const EdgeInsets.only(
                      left: 10,
                      right: 25,
                      top: 5,
                      bottom: 25,
                    ),
              child: MessageContent(
                message: message,
                messageType: messageType,
              ),
            ),
            Positioned(
              bottom: 4,
              right: 10,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                    if (isSeen != null && isSeen!) ...[
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
            ),
          ],
        ),
      ),
    );
  }
}

class BuildReplyTitleAndSummary extends StatelessWidget {
  const BuildReplyTitleAndSummary({
    Key? key,
    required this.size,
    required this.replyMessageTitle,
    required this.isGroupChat,
    required this.replyMessageType,
    required this.replyText,
    required this.isSenderMessage,
    this.avatarUrl,
  }) : super(key: key);

  final Size size;
  final bool isGroupChat;
  final String? avatarUrl;
  final MessageTypeEnum replyMessageType;
  final String replyMessageTitle;
  final String replyText;
  final bool isSenderMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isSenderMessage ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4.0,
            bottom: 5,
          ),
          child: Text(
            replyMessageTitle,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontSize: 10),
            maxLines: 3,
          ),
        ),
        Align(
          alignment: isSenderMessage ? Alignment.topLeft : Alignment.topRight,
          heightFactor: replyMessageType != MessageTypeEnum.text ? 1 : 0.75,
          child: Card(
            margin: const EdgeInsets.all(0),
            color: transparentColor,
            shape: RoundedRectangleBorder(
              side: replyMessageType == MessageTypeEnum.text
                  ? const BorderSide(
                      color: Colors.white,
                      width: 1.0,
                    )
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: replyMessageType != MessageTypeEnum.text
                  ? const EdgeInsets.only(bottom: 5)
                  : const EdgeInsets.only(
                      left: 10,
                      right: 25,
                      top: 5,
                      bottom: 25,
                    ),
              child: MessageReplyContent(
                message: replyText,
                messageType: replyMessageType,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BuildMessageAvatar extends StatelessWidget {
  const BuildMessageAvatar({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final ReplyMessage widget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.avatarUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 15,
        backgroundImage: imageProvider,
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
