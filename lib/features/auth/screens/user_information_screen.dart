import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/enums/enums.dart';

import 'package:whatsapp_ui/common/utils/utils.dart' as utils;
import 'package:whatsapp_ui/features/auth/controller/auth_controller.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/loader.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);

  static const routeName = '/user-information';

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const UserInformationScreen(),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  final nameController = TextEditingController();

  bool isLoading = false;

  File? image;

  Future<void> pickImage(BuildContext context) async {
    final pickedImage = await utils.pickImageOrVideoFromGallery(
      context: context,
      type: ImagePickerTypeEnum.image,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      image = pickedImage;
    });
  }

  void saveUserDataToFireStore() {
    setState(() {
      isLoading = !isLoading;
    });
    if (image == null) {
      showSnackbar(context, 'Please pick your profile image first.');
      return;
    } else if (nameController.text.isEmpty) {
      showSnackbar(context, 'Please type your name.');
      return;
    }

    try {
      ref.read<AuthController>(authControllerProvider).saveUserDataToFireStore(
            context: context,
            profilePic: image!,
            name: nameController.text.trim(),
          );

      isLoading = !isLoading;
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Loader()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          image == null
                              ? const CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'),
                                  radius: 60,
                                )
                              : CircleAvatar(
                                  backgroundImage: FileImage(image!),
                                  radius: 60,
                                ),
                          Positioned(
                            bottom: -10,
                            right: 0,
                            child: IconButton(
                              onPressed: () => pickImage(context),
                              icon: const Icon(
                                Icons.add_a_photo,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                    hintText: 'Enter you name'),
                                controller: nameController,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: saveUserDataToFireStore,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
