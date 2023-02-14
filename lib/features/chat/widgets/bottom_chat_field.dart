import 'dart:async';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_ui/common/enums/enums.dart';
import 'package:whatsapp_ui/common/providers/message_reply.dart';
import 'package:whatsapp_ui/common/utils/utils.dart' as utils;
import 'package:whatsapp_ui/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_ui/features/chat/widgets/message_reply_review.dart';

import '../../../colors.dart';

class BottomChatField extends ConsumerStatefulWidget {
  const BottomChatField({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.isGroupChat,
  }) : super(key: key);

  final String receiverId;
  final String receiverName;
  final bool isGroupChat;

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSentButton = false;
  bool isShowEmoji = false;
  bool isHideOptionIcons = false;

  Timer? hideOptionIconsTimer;

  final messageController = TextEditingController();
  final messageFocusNode = FocusNode();

  FlutterSoundRecorder? soundRecorder;
  bool isRecording = false;
  bool isRecorderInitialized = false;

  @override
  void initState() {
    super.initState();
    openAudio();
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
    soundRecorder!.closeRecorder();
    hideOptionIconsTimer?.cancel();
  }

  Future<void> openAudio() async {
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.denied) {
      throw RecordingPermissionException('Mic permission not allowed!');
    } else {
      soundRecorder = await FlutterSoundRecorder().openRecorder();
      isRecorderInitialized = true;
    }
  }

  void pickImageAndVideo(MessageTypeEnum messageType) async {
    File? file;
    switch (messageType) {
      case MessageTypeEnum.image:
        file = await utils.pickImageOrVideoFromGallery(
          context: context,
          type: ImagePickerTypeEnum.image,
        );
        break;
      case MessageTypeEnum.video:
        file = await utils.pickImageOrVideoFromGallery(
          context: context,
          type: ImagePickerTypeEnum.video,
        );
        break;
      default:
        file = null;
    }

    if (file == null) {
      return;
    }

    await sentFileMessage(widget.receiverId, file, messageType);
  }

  void pickEmoji() {
    setState(() {
      messageFocusNode.unfocus();
      isShowEmoji = !isShowEmoji;
    });
  }

  void pickRecorderFile() async {
    if (!isRecorderInitialized) {
      return;
    }

    final temDir = await getTemporaryDirectory();
    final String recorderDir = '${temDir.path}/flutter_sound.aac';

    if (!isRecording) {
      setState(() {
        isRecording = !isRecording;
      });
      await soundRecorder!.startRecorder(toFile: recorderDir);
    } else {
      await soundRecorder!.stopRecorder();
      setState(() {
        isRecording = !isRecording;
      });
      await sentFileMessage(
        widget.receiverId,
        File(recorderDir),
        MessageTypeEnum.audio,
      );
    }
  }

  void pickGIF() async {
    final GiphyGif? gif = await utils.pickGif(context);
    if (gif == null) {
      return;
    }
    await sentGIFMessage(widget.receiverId, gif, MessageTypeEnum.gif);
  }

  void sentTextOrEmojiMessage() {
    ref.watch(chatControllerProvider).sentTextOrEmojiMessage(
          receiverId: widget.receiverId,
          text: messageController.text.trim(),
          context: context,
          receiverName: widget.receiverName,
          isGroupChat: widget.isGroupChat,
        );
    messageController.clear();
    // FocusScope.of(context).unfocus();
  }

  Future<void> sentFileMessage(
    String receiverId,
    File file,
    MessageTypeEnum messageType,
  ) async {
    await ref.watch(chatControllerProvider).sentFileMessage(
          context: context,
          receiverId: receiverId,
          file: file,
          messageType: messageType,
          receiverName: widget.receiverName,
          isGroupChat: widget.isGroupChat,
        );
  }

  Future<void> sentGIFMessage(
    String receiverId,
    GiphyGif gif,
    MessageTypeEnum messageType,
  ) async {
    await ref.watch(chatControllerProvider).sentGIFMessage(
          receiverId: receiverId,
          gifUrl: gif.url!,
          context: context,
          receiverName: widget.receiverName,
          isGroupChat: widget.isGroupChat,
        );
  }

  void toggleHideOptionIcons(bool hasFocus) {
    if (hasFocus) {
      isHideOptionIcons = true;
      hideOptionIconsTimer = Timer(const Duration(seconds: 6), () {
        if (messageController.text.isEmpty) {
          setState(() {
            isHideOptionIcons = false;
          });
        }
      });
    } else {
      isHideOptionIcons = false;
      hideOptionIconsTimer!.cancel();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final messageReplyData = ref.watch(messageReplyStateProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Offstage(
        //   offstage: !isReplyMessage,
        //   child: MessageReplyReview(receiverName: widget.receiverName),
        // ),
        (messageReplyData != null)
            ? MessageReplyReview(receiverName: widget.receiverName)
            : const SizedBox(),
        Container(
          color: blackColor,
          padding: EdgeInsets.only(
            top: 10,
            bottom: messageFocusNode.hasFocus ? 10 : 0,
          ),
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isHideOptionIcons) ...[
                  IconButton(
                    iconSize: 35,
                    color: const Color(0xFF128C7E),
                    onPressed: () {
                      setState(() {
                        isHideOptionIcons = false;
                      });
                    },
                    icon: const Icon(Icons.navigate_next_outlined),
                  ),
                ],
                Expanded(
                  child: Focus(
                    onFocusChange: toggleHideOptionIcons,
                    child: TextFormField(
                      // expands: true,
                      controller: messageController,
                      decoration: InputDecoration(
                        // isDense: true,
                        filled: true,
                        fillColor: mobileChatBoxColor,
                        prefixIcon: isHideOptionIcons
                            ? null
                            : SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: pickEmoji,
                                      icon: const Icon(Icons.emoji_emotions),
                                      color: Colors.grey,
                                    ),
                                    IconButton(
                                      onPressed: pickGIF,
                                      icon: const Icon(Icons.gif),
                                      color: Colors.grey,
                                      iconSize: 30,
                                    ),
                                  ],
                                ),
                              ),
                        suffixIcon: isHideOptionIcons
                            ? null
                            : Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: SizedBox(
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => pickImageAndVideo(
                                            MessageTypeEnum.image),
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.grey,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      IconButton(
                                        onPressed: () => pickImageAndVideo(
                                            MessageTypeEnum.video),
                                        icon: const Icon(
                                          Icons.attach_file,
                                          color: Colors.grey,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        hintText: 'Type a message!',
                        hintStyle: const TextStyle(fontSize: 13),
                        // hintStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      autofocus: false,
                      onTap: () {
                        // isHideOptionIcon = true;
                        if (isShowEmoji) {
                          isShowEmoji = !isShowEmoji;
                        }
                        setState(() {});
                      },
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          isShowSentButton = true;
                          isHideOptionIcons = true;
                          setState(() {});
                        } else {
                          isShowSentButton = false;
                          toggleHideOptionIcons(messageFocusNode.hasFocus);
                        }
                      },
                      focusNode: messageFocusNode,
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                      minLines: 1,
                    ),
                  ),
                ),
                InkWell(
                  onTap: isShowSentButton
                      ? sentTextOrEmojiMessage
                      : pickRecorderFile,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 23,
                      backgroundColor: const Color(0xFF128C7E),
                      child: Icon(
                        isShowSentButton
                            ? Icons.send
                            : isRecording
                                ? Icons.close_rounded
                                : Icons.mic,
                        color: whiteColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Offstage(
          offstage: !isShowEmoji,
          child: SafeArea(
            child: SizedBox(
              height: 300,
              child: EmojiPicker(
                textEditingController: messageController,
                onEmojiSelected: (category, emoji) {
                  if (!isShowSentButton) {
                    setState(() {
                      // messageController.
                      isShowSentButton = !isShowSentButton;
                      // messageFocusNode.unfocus();
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
