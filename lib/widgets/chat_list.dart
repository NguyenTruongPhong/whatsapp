import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/providers/jump_to_chat_list_item.dart';
import 'package:whatsapp_ui/common/screens/error_screen.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';
import 'package:whatsapp_ui/features/models/message_model.dart';

import '../features/chat/widgets/my_message_card.dart';
import '../features/chat/widgets/sender_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  const ChatList({
    Key? key,
    required this.receiverId,
    required this.isGroupChat,
    required this.currentUserName,
  }) : super(key: key);

  final String receiverId;
  final bool isGroupChat;
  final String currentUserName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  // final ScrollController messageScrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  late final String currentUserUId;
  bool isShowScrollButton = false;
  bool fistScroll = true;

  @override
  void dispose() {
    super.dispose();
    // messageScrollController.dispose();
    // itemPositionsListener.itemPositions.
    itemPositionsListener.itemPositions.removeListener(() {});
  }

  @override
  void initState() {
    super.initState();
    currentUserUId = ref.read(authControllerProvider).getCurrentUserUId();
    // listen for chat scrolling
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value.first.index == 7 &&
          fistScroll) {
        fistScroll = false;
        setState(() {
          isShowScrollButton = true;
        });
      } else if (itemPositionsListener.itemPositions.value.first.index == 0.0 &&
          !fistScroll) {
        fistScroll = true;
        setState(() {
          isShowScrollButton = false;
        });
      }
    });
  }

  void updateReceiverMessageSeenStatus(MessageModel messageData) {
    if (!widget.isGroupChat) {
      //update message seen status
      if (!messageData.isSeen! && messageData.senderId == widget.receiverId) {
        ref.read(chatControllerProvider).setMessageSeenStatus(
              context: context,
              receiverId: widget.receiverId,
              messageId: messageData.messageId,
            );
      }
    }
  }

  void updateUnreadMessagesState() {
    // update unread messages state
    if (!widget.isGroupChat) {
      ref.read(chatControllerProvider).updateUnreadMessagesState(
            isHavingUnreadMessages: false,
            receiverId: widget.receiverId,
          );
    }
  }

  void jumpToReplyMessageItem() {
    ref.listen<JumpToChatListItem>(jumpToChatListItemProvider,
        (previous, next) {
      int newMessageItemNumber =
          next.presentsChatLengths - next.currentChatLengths;
      // print(newMessageItemNumber + next.replyMessageItemIndex);
      itemScrollController.scrollTo(
        index: newMessageItemNumber + next.replyMessageItemIndex,
        alignment: 0.5,
        duration: const Duration(seconds: 1),
      );
    });
  }

  void updateGroupMembersSeenMessageUId({
    required MessageModel message,
    required String groupId,
  }) async {
    if (message.senderId != currentUserUId &&
        !message.membersSeenMessageUId!.contains(currentUserUId)) {
      await ref
          .read(groupControllerProvider)
          .updateGroupMembersSeenMessageUId(groupId: groupId, message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    jumpToReplyMessageItem();
    return StreamBuilder<List<MessageModel>?>(
      stream: widget.isGroupChat
          ? ref
              .watch(groupControllerProvider)
              .getGroupMessagesStream(widget.receiverId)
          : ref
              .watch(chatControllerProvider)
              .getMessagesByUIdStream(widget.receiverId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Loader();
        }
        if (snapshot.hasData) {
          final List<MessageModel>? messages = snapshot.data;
          if (messages!.isEmpty) {
            return const Center(
              child: Text(
                'Let\'s start a conversation now.',
                // style: TextStyle(color: Colors.white),
              ),
            );
          }

          updateUnreadMessagesState();

          // if (!isShowScrollButton && messages.isNotEmpty) {
          //   // auto scroll to the last message
          //   SchedulerBinding.instance.addPostFrameCallback((_) {
          //     itemScrollController.jumpTo(index: 0);
          //   });
          // }
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ScrollablePositionedList.builder(
                reverse: true,
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                physics: const ClampingScrollPhysics(),
                itemCount: messages.length,
                initialScrollIndex: 0,
                itemBuilder: (context, index) {
                  final MessageModel messageData = messages[index];

                  updateReceiverMessageSeenStatus(messageData);
                  if (widget.isGroupChat) {
                    updateGroupMembersSeenMessageUId(
                      message: messageData,
                      groupId: widget.receiverId,
                    );
                  }

                  if (messageData.senderId == currentUserUId) {
                    return MyMessageCard(
                      currentUserName: widget.currentUserName,
                      message: messageData.text,
                      date: DateFormat.Hm().format(
                        DateTime.parse(
                          messageData.timeSent,
                        ),
                      ),
                      isSeen: widget.isGroupChat ? false : messageData.isSeen!,
                      messageType: messageData.messageType,
                      currentMessageItemIndex: index,
                      replyMessageItemIndex: messageData.replyMessageItemIndex,
                      chatLengths: messages.length,
                      receiverName: messageData.receiverName,
                      replyText: messageData.replyText,
                      replyTitle: messageData.replyTitle,
                      replyMessageType: messageData.replyMessageType,
                      isReplyToYourself: messageData.isReplyToYourself,
                      currentChatLengths: messageData.currentChatLengths,
                      senderName: messageData.senderName,
                      isGroupChat: widget.isGroupChat,
                      senderNameOfReplyMessage:
                          messageData.senderNameOfReplyMessage,
                      membersSeenMessageUId: messageData.membersSeenMessageUId,
                      isLastedMessage: index == 0 ? true : false,
                    );
                  } else {
                    return SenderMessageCard(
                      currentUserName: widget.currentUserName,
                      message: messageData.text,
                      date: DateFormat.Hm().format(
                        DateTime.parse(
                          messageData.timeSent,
                        ),
                      ),
                      senderNameOfReplyMessage:
                          messageData.senderNameOfReplyMessage,
                      messageType: messageData.messageType,
                      receiverName: messageData.receiverName,
                      messageItemIndex: index,
                      replyMessageItemIndex: messageData.replyMessageItemIndex,
                      chatLengths: messages.length,
                      replyText: messageData.replyText,
                      replyTitle: messageData.replyTitle,
                      replyMessageType: messageData.replyMessageType,
                      isReplyToYourself: messageData.isReplyToYourself,
                      currentChatLengths: messageData.currentChatLengths,
                      senderName: messageData.senderName,
                      isGroupChat: widget.isGroupChat,
                      avatarUrl: messageData.avatarUrl,
                      membersSeenMessageUId: messageData.membersSeenMessageUId,
                      isLastedMessage: index == 0 ? true : false,
                    );
                  }
                },
              ),
              Offstage(
                offstage: !isShowScrollButton,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blackColor,
                    foregroundColor: whiteColor,
                    shape: const CircleBorder(),
                  ),
                  onPressed: () {
                    // messageScrollController.position.jumpTo(
                    //   messageScrollController.position.minScrollExtent,
                    // );
                    itemScrollController.jumpTo(index: 0);
                  },
                  child: const Icon(Icons.arrow_downward),
                ),
              )
            ],
          );
        } else {
          return const ErrorScreen();
        }
      },
    );
  }
}
