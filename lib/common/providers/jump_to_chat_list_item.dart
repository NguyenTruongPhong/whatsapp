import 'package:riverpod/riverpod.dart';
import 'package:equatable/equatable.dart';

class JumpToChatListItem extends Equatable {
  final int replyMessageItemIndex;
  final int chatLengthsAtTimeSent; // chat lengths at reply text time
  final int presentsChatLengths;

  const JumpToChatListItem({
    this.replyMessageItemIndex = 0,
    this.presentsChatLengths = 0,
    this.chatLengthsAtTimeSent = 0,
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
  @override
  String toString() {
    return '{replyMessageItemIndex: $replyMessageItemIndex, chatLengthsAtTimeSent: $chatLengthsAtTimeSent, presentsChatLengths: $presentsChatLengths}';
  }
  
  @override
  List<Object?> get props => [replyMessageItemIndex, chatLengthsAtTimeSent, presentsChatLengths];
}

final jumpToChatListItemProvider = StateProvider<JumpToChatListItem>(((ref) {
  return const JumpToChatListItem();
}));
