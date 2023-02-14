import 'package:flutter/material.dart';

import '../../colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPress,
    this.height = 50,
  }) : super(key: key);

  final String text;
  final double height;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        foregroundColor: blackColor,
        backgroundColor: tabColor,
        minimumSize: Size(
          double.infinity,
          height,
        ),
      ),
      child:  Text(text),
    );
  }
}
