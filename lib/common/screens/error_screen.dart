import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key, this.message = 'Something went wrong.'})
      : super(key: key);

  final String message;

  static const String routeName = '/error';

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const ErrorScreen(),
      settings: const RouteSettings(
        name: routeName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).errorColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
