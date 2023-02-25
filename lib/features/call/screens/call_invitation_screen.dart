import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/configs/zego_config.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_ui/features/models/user_model.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class CallInvitationScreen extends ConsumerWidget {
  const CallInvitationScreen({
    Key? key,
    required this.child,
    required this.isGroupChat,
  }) : super(key: key);
  final Widget child;
  final bool isGroupChat;

  static const String routeName = '/call-invitation';

  static Route route({
    required Widget child,
    required bool isGroupChat,
  }) {
    return MaterialPageRoute(
      builder: (context) => CallInvitationScreen(
        isGroupChat: isGroupChat,
        child: child,
      ),
      settings: const RouteSettings(
        name: routeName,
      ),
    );
  }

  Widget avatarBuilder({
    required ZegoUIKitUser? receiver,
    required WidgetRef ref,
  }) {
    return receiver != null
        ? FutureBuilder<UserModel?>(
            future: ref
                .read(authControllerProvider)
                .getCurrentUserDataOrByUId(receiver.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        snapshot.data!.profilePicUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
            })
        : const SizedBox();
  }

  ZegoUIKitPrebuiltCallConfig selectConfig({
    required ZegoCallInvitationData data,
    required WidgetRef ref,
  }) {
    if (isGroupChat) {
      switch (data.type) {
        case ZegoCallType.voiceCall:
          return ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
            ..avatarBuilder = (
              BuildContext context,
              Size size,
              ZegoUIKitUser? user,
              Map extraInfo,
            ) {
              return avatarBuilder(
                receiver: user,
                ref: ref,
              );
            }
            ..onOnlySelfInRoom = (context) => Navigator.of(context).pop();

        default:
          return ZegoUIKitPrebuiltCallConfig.groupVideoCall()
            ..avatarBuilder = (
              BuildContext context,
              Size size,
              ZegoUIKitUser? user,
              Map extraInfo,
            ) {
              return avatarBuilder(
                receiver: user,
                ref: ref,
              );
            }
            ..onOnlySelfInRoom = (context) => Navigator.of(context).pop();
      }
    } else {
      switch (data.type) {
        case ZegoCallType.voiceCall:
          return ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
            ..avatarBuilder = (
              BuildContext context,
              Size size,
              ZegoUIKitUser? user,
              Map extraInfo,
            ) {
              return avatarBuilder(
                receiver: user,
                ref: ref,
              );
            }
            ..onOnlySelfInRoom = (context) => Navigator.of(context).pop();

        default:
          return ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..avatarBuilder = (
              BuildContext context,
              Size size,
              ZegoUIKitUser? user,
              Map extraInfo,
            ) {
              return avatarBuilder(
                receiver: user,
                ref: ref,
              );
            }
            ..onOnlySelfInRoom = (context) => Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<UserModel?>(
      future: ref.read(authControllerProvider).getCurrentUserDataOrByUId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Loader();
        }
        final UserModel currentUserData = snapshot.data!;
        return SafeArea(
          child: ZegoUIKitPrebuiltCallWithInvitation(
            appID: ZegoConfig.appId,
            appSign: ZegoConfig.appSign,
            userID: currentUserData.uid,
            userName: currentUserData.name,
            plugins: [ZegoUIKitSignalingPlugin()],
            tokenServerUrl: ZegoConfig.idToken,
            requireConfig: (data) => selectConfig(
              data: data,
              ref: ref,
            ),
            androidNotificationConfig: ZegoAndroidNotificationConfig(
              channelID: '20929060b76b9fa946dfa7c173b94df586bff2b5',
              // channelName: call!.callId,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
