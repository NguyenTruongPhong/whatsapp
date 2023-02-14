import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/common/widgets/custom_button.dart';
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String routeName = '/login';

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const LoginScreen(),
      settings: const RouteSettings(
        name: routeName,
      ),
    );
  }

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  String phoneCode = '';

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          phoneCode = '+${country.phoneCode}';
        });
        print('Select country: ${country.displayName}');
      },
    );
  }

  Future<void> sentPhoneNumber() async {
    final String phoneNumber = phoneController.text.trim();
    if (phoneCode.isEmpty) {
      showSnackbar(
          context, 'You have to pick country to get the phone code fist.');
      return;
    } else if (phoneNumber.isEmpty || phoneNumber.length < 9) {
      showSnackbar(context, 'Invalid phone Number.');
      return;
    }

    await ref
        .read<AuthController>(authControllerProvider)
        .singInWithPhoneNumber(context, '$phoneCode$phoneNumber');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter your phone number',
        ),
        // backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    'WhatsApp will need to verify your phone number.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: pickCountry,
                  child: const Text('Pick country'),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text(phoneCode),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'phone number',
                        ),
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SafeArea(
              left: false,
              right: false,
              top: false,
              child: SizedBox(
                width: size.width * 0.3,
                child: CustomButton(
                  text: 'NEXT',
                  onPress: sentPhoneNumber,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
