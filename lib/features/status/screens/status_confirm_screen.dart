import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/status/controller/status_controller.dart';

class StatusConfirmScreen extends ConsumerStatefulWidget {
  const StatusConfirmScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  final File file;

  static const String routeName = '/status-confirm';

  static Route route(File file) {
    return MaterialPageRoute(
      builder: (context) => StatusConfirmScreen(file: file),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StatusConfirmScreenState();
}

class _StatusConfirmScreenState extends ConsumerState<StatusConfirmScreen> {
  bool isLoading = false;

  void addStatus() async {
    setState(() {
      isLoading = true;
    });
    await ref
        .read(statusContactsControllerProvider)
        .addStatus(statusPhoto: widget.file, context: context)
        .then((value) {
      isLoading = false;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Confirm'),
      ),
      body: isLoading
          ? const Loader()
          : Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(widget.file),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: tabColor,
        foregroundColor: whiteColor,
        onPressed: addStatus,
        child: const Icon(Icons.done),
      ),
    );
  }
}

// class StatusConfirmScreen extends ConsumerWidget {
//   const StatusConfirmScreen({
//     Key? key,
//     required this.file,
//   }) : super(key: key);

//   final File file;

//   static const String routeName = '/status-confirm';

//   static Route route(File file) {
//     return MaterialPageRoute(
//       builder: (context) => StatusConfirmScreen(file: file),
//       settings: const RouteSettings(name: routeName),
//     );
//   }

//   void addStatus(BuildContext context, WidgetRef ref) async {
//     await ref
//         .read(statusContactsControllerProvider)
//         .addStatus(statusPhoto: file, context: context);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Status Confirm'),
//       ),
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: 16 / 9,
//           child: Image.file(file),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: tabColor,
//         foregroundColor: whiteColor,
//         onPressed: () => addStatus(context, ref),
//         child: const Icon(Icons.done),
//       ),
//     );
//   }
// }
