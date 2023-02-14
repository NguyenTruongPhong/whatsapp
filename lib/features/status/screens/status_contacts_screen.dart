import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/screens/error_screen.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/models/status_model.dart';
import 'package:whatsapp_ui/features/status/controller/status_controller.dart';
import 'package:whatsapp_ui/features/status/screens/status_view_screen.dart';

class StatusContactsScreen extends ConsumerWidget {
  const StatusContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder<List<StatusModel>?>(
        stream: ref.watch(statusContactsControllerProvider).getStatuses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Loader();
          }
          if (snapshot.hasData) {
            final List<StatusModel>? statuses = snapshot.data;
            if (statuses!.isEmpty) {
              return const Center(
                child: Text(
                  'Let\'s start a new status now.',
                  // style: TextStyle(color: Colors.white),
                ),
              );
            }
            return ListView.builder(
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final statusData = statuses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        StatusViewScreen.routeName,
                        arguments: statusData,
                      );
                    },
                    splashColor: Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(statusData.ownerProfilePic),
                      ),
                      title: Text(
                        statusData.ownerName,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const ErrorScreen();
          }
        },
      ),
    );
  }
}
