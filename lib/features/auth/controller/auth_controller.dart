import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:whatsapp_ui/features/auth/repository/auth_repository.dart';

import '../../models/user_model.dart';

final authControllerProvider = Provider((ref) {
  final AuthRepository authRepository =
      ref.watch<AuthRepository>(authRepositoryProvider);
  return AuthController(authRepository: authRepository, providerRef: ref);
});

final userDataAuthProvider = FutureProvider<UserModel?>((ref) {
  return ref
      .watch<AuthController>(authControllerProvider)
      .getCurrentUserDataOrByUId();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef providerRef;

  const AuthController({
    required this.authRepository,
    required this.providerRef,
  });

  Future<UserModel?> getCurrentUserDataOrByUId([String? uid]) async {
    return await authRepository.getCurrentUserDataOrByUId(uid);
  }

  Future<void> singInWithPhoneNumber(
    BuildContext context,
    String phoneNumber,
  ) async {
    await authRepository.signInWithPhoneNumber(
      phoneNumber: phoneNumber,
      context: context,
    );
  }

  Future<void> logout() async {
    await authRepository.logout();
  }

  Future<void> verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    await authRepository.verifyOTP(
      context: context,
      verificationId: verificationId,
      userOTP: userOTP,
    );
  }

  Future<void> saveUserDataToFireStore({
    required BuildContext context,
    required File profilePic,
    required String name,
  }) async {
    await authRepository.saveUserDataToFireStore(
      context: context,
      ref: providerRef,
      profilePic: profilePic,
      name: name,
    );
  }

  Stream<UserModel> getUserDataById(String userId) {
    return authRepository.getUserDataByUId(userId);
  }

  Future<void> updateOnlineState(bool isOnline) async {
    await authRepository.updateOnlineState(isOnline);
  }

  String getCurrentUserUId() {
    return authRepository.getCurrentUserUId();
  }
}
