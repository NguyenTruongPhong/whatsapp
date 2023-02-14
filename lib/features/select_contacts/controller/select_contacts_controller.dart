import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:riverpod/riverpod.dart';

import 'package:whatsapp_ui/features/select_contacts/repository/select_contacts_repository.dart';

final getContactsProvider = FutureProvider((ref) {
  final selectContactsRepository = ref.watch(selectContactsRepositoryProvider);
  return selectContactsRepository.getContacts();
});

final selectContactsControllerProvider = Provider((ref) {
  final selectContactsRepository = ref.watch(selectContactsRepositoryProvider);
  return SelectContactsController(
    selectContactsRepository: selectContactsRepository,
  );
});

class SelectContactsController {
  final SelectContactsRepository selectContactsRepository;

  const SelectContactsController({
    required this.selectContactsRepository,
  });

  Future<void> selectContact({
    required BuildContext context,
    required Contact contact,
  }) async {
    await selectContactsRepository.selectContact(
      contact: contact,
      context: context,
    );
  }
}
