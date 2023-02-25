import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/providers/jump_to_chat_list_item.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
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
    required this.currentUserUId,
  }) : super(key: key);

  final String receiverId;
  final bool isGroupChat;
  final String currentUserName;
  final String currentUserUId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void dispose() {
    super.dispose();
    itemPositionsListener.itemPositions.removeListener(() {});
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

  @override
  Widget build(BuildContext context) {
    // jumpToReplyMessageItem();
    return StreamBuilder<List<MessageModel>?>(
        stream: widget.isGroupChat
            ? ref
                .watch(groupControllerProvider)
                .getGroupMessagesStream(widget.receiverId)
            : ref
                .watch(chatControllerProvider)
                .getMessagesByUIdStream(widget.receiverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          final List<MessageModel>? messages = snapshot.data;
          if (messages!.isEmpty) {
            return const Center(
              child: Text(
                'Let\'s start a conversation now.',
              ),
            );
          }
          updateUnreadMessagesState();
          if (snapshot.hasData) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                BuildChatList(
                  isGroupChat: widget.isGroupChat,
                  currentUserUId: widget.currentUserUId,
                  currentUserName: widget.currentUserName,
                  receiverId: widget.receiverId,
                  messages: snapshot.data!,
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  // isAnimation: isAnimation,
                  // scrollToMessageIndex: scrollToMessageIndex,
                ),
                BuildShowScrollButton(
                  itemPositionsListener: itemPositionsListener,
                  itemScrollController: itemScrollController,
                ),
              ],
            );
          } else {
            return const Center(
              child: Text(
                'Something went wrong.',
                style: TextStyle(color: whiteColor),
              ),
            );
          }
        });
  }
}

class BuildChatList extends ConsumerStatefulWidget {
  const BuildChatList({
    Key? key,
    required this.isGroupChat,
    required this.currentUserUId,
    required this.currentUserName,
    required this.receiverId,
    required this.messages,
    required this.itemScrollController,
    required this.itemPositionsListener,
    // required this.isAnimation,
    // required this.scrollToMessageIndex,
  }) : super(key: key);

  final bool isGroupChat;
  final String currentUserUId;
  final String currentUserName;
  final String receiverId;
  final List<MessageModel> messages;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  // final bool isAnimation;
  // final int scrollToMessageIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BuildChatListState();
}

class _BuildChatListState extends ConsumerState<BuildChatList> {
  late final Size size;
  int scrollToMessageIndex = 0;
  bool isAnimation = false;
  Timer? animationTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    super.dispose();
    animationTimer?.cancel();
  }

  void updateReceiverMessageSeenStatus({
    required MessageModel messageData,
  }) {
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

  void updateGroupMembersSeenMessageUId({
    required MessageModel message,
  }) async {
    if (message.senderId != widget.currentUserUId &&
        !message.membersSeenMessageUId!.contains(widget.currentUserUId)) {
      await ref.read(groupControllerProvider).updateGroupMembersSeenMessageUId(
            groupId: widget.receiverId,
            message: message,
          );
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
    ref.listen<JumpToChatListItem>(
      jumpToChatListItemProvider,
      (previous, next) {
        int newMessageItemNumber =
            next.presentsChatLengths - next.chatLengthsAtTimeSent;
        scrollToMessageIndex =
            next.replyMessageItemIndex + newMessageItemNumber;
        // print(newMessageItemNumber + next.replyMessageItemIndex);
        widget.itemScrollController
            .scrollTo(
          index: scrollToMessageIndex,
          alignment: 0.5,
          duration: const Duration(seconds: 1),
        )
            .then(
          (value) {
            isAnimation = true;
            setState(() {});
            animationTimer = Timer(const Duration(seconds: 1), () {
              isAnimation = false;
              setState(() {});
              // ref
              //     .read(jumpToChatListItemProvider.notifier)
              //     .update((state) => JumpToChatListItem());
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    jumpToReplyMessageItem();
    return ScrollablePositionedList.builder(
      shrinkWrap: true,
      reverse: true,
      itemScrollController: widget.itemScrollController,
      itemPositionsListener: widget.itemPositionsListener,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.messages.length,
      initialScrollIndex: 0,
      itemBuilder: (context, index) {
        print('called 2');
        final MessageModel messageData = widget.messages[index];
        updateReceiverMessageSeenStatus(messageData: messageData);
        if (widget.isGroupChat) {
          updateGroupMembersSeenMessageUId(message: messageData);
        }
        return messageData.senderId == widget.currentUserUId
            ? AnimatedContainer(
                duration: const Duration(seconds: 1),
                color: isAnimation && scrollToMessageIndex == index
                    ? tabColor
                    : null,
                width: isAnimation && scrollToMessageIndex == index
                    ? size.width
                    : null,
                child: MyMessageCard(
                  currentUserName: widget.currentUserName,
                  message: messageData.text,
                  date: DateFormat.Hm().format(
                    DateTime.parse(messageData.timeSent),
                  ),
                  isSeen: widget.isGroupChat ? false : messageData.isSeen!,
                  messageType: messageData.messageType,
                  currentMessageItemIndex: index,
                  replyMessageItemIndex: messageData.replyMessageItemIndex,
                  chatLengths: widget.messages.length,
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
                ),
              )
            : AnimatedContainer(
                duration: const Duration(seconds: 1),
                color: isAnimation && scrollToMessageIndex == index
                    ? tabColor
                    : null,
                width: isAnimation && scrollToMessageIndex == index
                    ? size.width
                    : null,
                child: SenderMessageCard(
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
                  currentMessageItemIndex: index,
                  replyMessageItemIndex: messageData.replyMessageItemIndex,
                  chatLengths: widget.messages.length,
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
                ),
              );
      },
    );
  }
}

class BuildShowScrollButton extends StatefulWidget {
  const BuildShowScrollButton({
    Key? key,
    required this.itemScrollController,
    required this.itemPositionsListener,
  }) : super(key: key);

  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  @override
  State<BuildShowScrollButton> createState() => _BuildShowScrollButtonState();
}

class _BuildShowScrollButtonState extends State<BuildShowScrollButton> {
  bool isShowScrollButton = false;
  bool fistScroll = true;
  @override
  void initState() {
    super.initState();
    // listen for chat scrolling
    widget.itemPositionsListener.itemPositions.addListener(() {
      // print('listen scroll');
      if (widget.itemPositionsListener.itemPositions.value.first.index == 7 &&
          fistScroll) {
        fistScroll = false;
        isShowScrollButton = true;
        setState(() {});
      } else if (widget.itemPositionsListener.itemPositions.value.first.index ==
              0 &&
          !fistScroll) {
        fistScroll = true;
        isShowScrollButton = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('BuildShowScrollButton');
    return Offstage(
      offstage: !isShowScrollButton,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: blackColor,
          foregroundColor: whiteColor,
          shape: const CircleBorder(),
        ),
        onPressed: () => widget.itemScrollController.jumpTo(index: 0),
        child: const Icon(Icons.arrow_downward),
      ),
    );
  }
}
