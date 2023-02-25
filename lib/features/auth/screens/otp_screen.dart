import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';

class OTPScreen extends ConsumerStatefulWidget {
  const OTPScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  static const String routeName = '/otp';

  final String verificationId;
  final String phoneNumber;

  static Route route(String verificationId, String phoneNumber) {
    return MaterialPageRoute(
      builder: (_) => OTPScreen(
        verificationId: verificationId,
        phoneNumber: phoneNumber,
      ),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  bool isLoading = false;

  Future<void> verifyOTP(BuildContext context, String userOTP) async {
    await ref.read<AuthController>(authControllerProvider).verifyOTP(
          context: context,
          verificationId: widget.verificationId,
          userOTP: userOTP,
        );
  }

  Future<void> reSent(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    await ref
        .read<AuthController>(authControllerProvider)
        .singInWithPhoneNumber(context, widget.phoneNumber);
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifying your number'),
        elevation: 0,
      ),
      body: isLoading
          ? const Loader()
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'We have sent and SMS with an code.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: TextField(
                      autofocus: true,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '- - - - - -',
                        hintStyle: TextStyle(fontSize: 30),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        if (val.length < 6) {
                          return;
                        }
                        verifyOTP(context, val.trim());
                      },
                    ),
                  ),
                  // const SizedBox(
                  //   height: 50,
                  // ),
                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width * 0.3,
                  //   child: CustomButton(
                  //     text: 'Resent',
                  //     height: 40,
                  //     onPress: () {
                  //       resent(context);
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
    );
  }
}
