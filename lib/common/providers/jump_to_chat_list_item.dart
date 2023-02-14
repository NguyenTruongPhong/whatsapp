import 'package:riverpod/riverpod.dart';

class JumpToChatListItem {
  final int replyMessageItemIndex;
  final int currentChatLengths; // chat lengths at reply text
  final int presentsChatLengths;
  JumpToChatListItem({
    this.replyMessageItemIndex = 0,
    this.presentsChatLengths = 0,
    this.currentChatLengths = 0,
  });

  // JumpToChatListItem copyWith({
  //   int? messageItemIndex,
  //   int? chatLengths,
  // }) {
  //   return JumpToChatListItem(
  //     replyMessageItemIndex: messageItemIndex ?? this.replyMessageItemIndex,
  //     presentsChatLengths: chatLengths ?? this.presentsChatLengths,
  //   );
  // }
}

final jumpToChatListItemProvider = StateProvider<JumpToChatListItem>(((ref) {
  return JumpToChatListItem();
}));
