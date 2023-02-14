import 'dart:io';

import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/features/group/controller/group_controller.dart';

import '../../../common/enums/enums.dart';
import '../../../common/screens/error_screen.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/loader.dart';
import '../../select_contacts/controller/select_contacts_controller.dart';
import '../../select_contacts/widgets/contact_item.dart';

final selectedGroupMemberContactsProvider = StateProvider((ref) => <Contact>[]);

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  static const routeName = '/create-group';
  static Route route() {
    return MaterialPageRoute(
      builder: (context) => const CreateGroupScreen(),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  bool isLoading = false;
  File? groupAvatarFile;
  List<int> groupContactsIndex = [];

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  void pickGroupAvatar() async {
    final image = await pickImageOrVideoFromGallery(
      context: context,
      type: ImagePickerTypeEnum.image,
    );

    if (image == null) {
      return;
    }

    setState(() {
      groupAvatarFile = image;
    });
  }

  void toggleGroupMembers({
    required int contactIndex,
    required Contact contact,
  }) {
    if (groupContactsIndex.contains(contactIndex)) {
      groupContactsIndex.remove(contactIndex);
      ref
          .read(selectedGroupMemberContactsProvider.notifier)
          .update((currentGroupContacts) {
        currentGroupContacts.remove(contact);
        return currentGroupContacts;
      });
    } else {
      groupContactsIndex.add(contactIndex);
      ref
          .read(selectedGroupMemberContactsProvider.notifier)
          .update((currentGroupContacts) {
        currentGroupContacts.add(contact);
        return currentGroupContacts;
      });
    }
    setState(() {});
  }

  void createGroup() async {
    if (groupContactsIndex.isEmpty ||
        groupAvatarFile == null ||
        groupNameController.text.isEmpty) {
      showSnackbar(
          context, 'Please select group avatar, group member and group name.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    await ref.read(groupControllerProvider).createGroup(
          groupName: groupNameController.text.trim(),
          groupAvatar: groupAvatarFile!,
          context: context,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }

    isLoading = false;

    ref
        .read(selectedGroupMemberContactsProvider.notifier)
        .update((state) => []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text('Create Group'),
      ),
      body: isLoading
          ? const Loader()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      groupAvatarFile == null
                          ? const CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'),
                              radius: 60,
                            )
                          : CircleAvatar(
                              backgroundImage: FileImage(groupAvatarFile!),
                              radius: 60,
                            ),
                      Positioned(
                        bottom: -10,
                        right: 0,
                        child: IconButton(
                          onPressed: pickGroupAvatar,
                          icon: const Icon(
                            Icons.add_a_photo,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    decoration:
                        const InputDecoration(hintText: 'Enter group name'),
                    controller: groupNameController,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Select Contacts',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ref.watch(getContactsProvider).when(
                        loading: () => const Loader(),
                        data: (List<Contact> contacts) {
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              final Contact contact = contacts[index];
                              return ContactItem(
                                contact: contact,
                                onTap: () => toggleGroupMembers(
                                  contactIndex: index,
                                  contact: contact,
                                ),
                                isSelected: groupContactsIndex.contains(index),
                              );
                            },
                            itemCount: contacts.length,
                          );
                        },
                        error: (error, stackTrace) {
                          return const ErrorScreen();
                        },
                      ),
                )
              ],
            ),
      floatingActionButton: isLoading ? null : FloatingActionButton(
        backgroundColor: tabColor,
        foregroundColor: whiteColor,
        onPressed: createGroup,
        child: const Icon(Icons.done),
      ),
    );
  }
}
