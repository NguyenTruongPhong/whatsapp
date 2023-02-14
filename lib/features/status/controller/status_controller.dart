// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import 'package:whatsapp_ui/features/status/repository/status_repository.dart';

import '../../models/status_model.dart';

final statusContactsControllerProvider = Provider(
  (ref) {
    final statusContactsRepository = ref.read(statusContactsRepositoryProvider);
    return StatusController(
      statusContactsRepository: statusContactsRepository,
      ref: ref,
    );
  },
);

class StatusController {
  StatusRepository statusContactsRepository;
  ProviderRef ref;

  StatusController({
    required this.statusContactsRepository,
    required this.ref,
  });

  Future<void> addStatus({
    required File statusPhoto,
    required BuildContext context,
  }) async {
    await statusContactsRepository.addStatus(
      statusPhoto: statusPhoto,
      ref: ref,
      context: context,
    );
  }

  Stream<List<StatusModel>?> getStatuses() {
    return statusContactsRepository.getStatuses();
  }
}
