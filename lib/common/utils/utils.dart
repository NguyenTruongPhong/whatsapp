import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_ui/common/enums/enums.dart';

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
}

Future<File?> pickImageOrVideoFromGallery({
  required BuildContext context,
  required ImagePickerTypeEnum type,
}) async {
  File? file;

  try {
    XFile? imageXFile = type == ImagePickerTypeEnum.image
        ? await ImagePicker().pickImage(
            source: ImageSource.gallery,
            // maxWidth: 500,
            // maxHeight: 500,
          )
        : await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (imageXFile != null) {
      file = File(imageXFile.path);
    }
  } catch (e) {
    showSnackbar(context, e.toString());
  }

  return file;
}

Future<GiphyGif?> pickGif(BuildContext context) async {
  GiphyGif? gif;
  try {
    gif = await GiphyGet.getGif(
      context: context,
      apiKey: '9B1cxylXQnmyzwqDpeQ64nIWJQP4QQtX',
    );
  } catch (e) {
    showSnackbar(context, e.toString());
  }
  return gif;
}
