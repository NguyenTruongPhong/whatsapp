import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/screens/error_screen.dart';
import 'package:whatsapp_ui/common/widgets/build_search_text_field.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/select_contacts/controller/select_contacts_controller.dart';

import '../../../common/providers/searching.dart';
import '../widgets/contact_item.dart';

class SelectContactsScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactsScreenState();
}

class _SelectContactsScreenState extends ConsumerState<SelectContactsScreen> {
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  void startSearching(String query) {
    ref.read(searchingStateProvider.notifier).update((state) => query.trim());
    setState(() {});
  }

  void cancelSearching() {
    isSearching = false;
    searchController.clear();
    ref.read(searchingStateProvider.notifier).update((state) => '');
    setState(() {});
  }

  void clearSearching() {
    searchController.clear();
    ref.read(searchingStateProvider.notifier).update((state) => '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isSearching,
        title: isSearching
            ? Expanded(
                child: BuildSearchTextField(
                  clearSearching: clearSearching,
                  startSearching: startSearching,
                  cancelSearching: cancelSearching,
                  searchController: searchController,
                ),
              )
            : const Text(
                'Select Contact',
                style: TextStyle(
                  fontSize: 20,
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: isSearching
            ? null
            : [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
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
              final List<Contact> filterContacts = contacts.where(
                (contact) {
                  String query =
                      ref.watch(searchingStateProvider).toLowerCase();
                  String name = contact.name.toString().toLowerCase();
                  return name.contains(query);
                },
              ).toList();
              return Padding(
                padding: const EdgeInsets.all(10).copyWith(bottom: 0, left: 5),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final Contact contact = filterContacts[index];
                    return ContactItem(
                      contact: contact,
                      onTap: () {
                        ref
                            .read(selectContactsControllerProvider)
                            .selectContact(context: context, contact: contact);
                      },
                    );
                  },
                  itemCount: filterContacts.length,
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
