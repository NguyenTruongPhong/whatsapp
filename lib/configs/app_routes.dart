import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsapp_ui/common/screens/error_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/login_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/user_information_screen.dart';
import 'package:whatsapp_ui/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_ui/features/landing/screens/landing_screen.dart';
import 'package:whatsapp_ui/features/models/status_model.dart';
import 'package:whatsapp_ui/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_ui/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_ui/features/status/screens/status_confirm_screen.dart';
import 'package:whatsapp_ui/features/status/screens/status_view_screen.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';


class AppRoutes {
  static Route onGenerateRoute(RouteSettings settings) {
    print('on route: ${settings.name}');
    switch (settings.name) {
      case LandingScreen.routeName:
        return LandingScreen.route();
      case LoginScreen.routeName:
        return LoginScreen.route();
      case OTPScreen.routeName:
        Map<String, String> arguments =
            settings.arguments as Map<String, String>;
        return OTPScreen.route(arguments['verificationId'] as String,
            arguments['phoneNumber'] as String);
      case UserInformationScreen.routeName:
        return UserInformationScreen.route();
      case SelectContactsScreen.routeName:
        return SelectContactsScreen.route();
      case MobileChatScreen.routeName:
        final arguments = settings.arguments as Map<String, dynamic>;
        return MobileChatScreen.route(
          // currentUserName: arguments['currentUserName'],
          isGroup: arguments['isGroup'] as bool,
          receiverId: arguments['receiverId'] as String,
          receiverName: arguments['receiverName'] as String,
        );
      case MobileLayoutScreen.routeName:
        return MobileLayoutScreen.route();
      case StatusConfirmScreen.routeName:
        final arguments = settings.arguments as File;
        return StatusConfirmScreen.route(arguments);
      case StatusViewScreen.routeName:
        final arguments = settings.arguments as StatusModel;
        return StatusViewScreen.route(arguments);
      case CreateGroupScreen.routeName:
        // final arguments = settings.arguments as StatusModel;
        return CreateGroupScreen.route();
 
      default:
        return ErrorScreen.route();
    }
  }

  static Route errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Something went wrong.'),
        ),
      ),
    );
  }
}
