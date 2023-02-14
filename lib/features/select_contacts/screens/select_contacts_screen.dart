import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/screens/error_screen.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/select_contacts/controller/select_contacts_controller.dart';

import '../widgets/contact_item.dart';

class SelectContactsScreen extends ConsumerWidget {
  const SelectContactsScreen({Key? key}) : super(key: key);

  static const String routeName = '/select-contact';

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const SelectContactsScreen(),
      settings: const RouteSettings(
        name: routeName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          )
        ],
      ),
      body: ref.watch(getContactsProvider).when(
            data: (List<Contact> contacts) {
              return Padding(
                padding: const EdgeInsets.all(10).copyWith(bottom: 0, left: 5),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final Contact contact = contacts[index];
                    return ContactItem(
                      contact: contact,
                      onTap: () {
                        ref
                            .read(selectContactsControllerProvider)
                            .selectContact(context: context, contact: contact);
                      },
                    );
                  },
                  itemCount: contacts.length,
                ),
              );
            },
            error: (error, stackTrace) {
              return const ErrorScreen();
            },
            loading: () => const Loader(),
          ),
    );
  }
}
