import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactItem extends ConsumerWidget {
  const ContactItem({
    Key? key,
    required this.contact,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  final Contact contact;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white,
        child: ListTile(
          leading: contact.photo == null
              ? const CircleAvatar(
                  backgroundImage: AssetImage('assets/empty_person.png'),
                )
              : CircleAvatar(
                  backgroundImage: MemoryImage(contact.photo!),
                ),
          title: Text(
            contact.displayName,
            style: const TextStyle(fontSize: 18),
          ),
          trailing: isSelected ? const Icon(Icons.done_outline_sharp) : null,
        ),
      ),
    );
  }
}
