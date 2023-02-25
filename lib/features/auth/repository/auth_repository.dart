import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:whatsapp_ui/common/repositories/common_firestore_repository.dart';
import 'package:whatsapp_ui/common/utils/utils.dart';
import 'package:whatsapp_ui/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/user_information_screen.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';

import '../../models/user_model.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    firebaseAuth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance,
  );
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUserDataOrByUId([String? uid]) async {
    UserModel? user;
    try {
      if (_firebaseAuth.currentUser == null) {
        return user;
      }
      await _firebaseFirestore
          .collection('users')
          .doc(uid ?? _firebaseAuth.currentUser?.uid)
          .get()
          .then((snap) {
        if (snap.exists) {
          user = UserModel.fromSnapshot(snap);
        }
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
    return user;
  }

  String getCurrentUserUId() {
    try {
      return _firebaseAuth.currentUser!.uid;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (FirebaseAuthException exception) {
          throw exception;
        },
        codeSent: (String verificationId, int? resentIdToken) {
          Navigator.pushNamed(
            context,
            OTPScreen.routeName,
            arguments: {
              'verificationId': verificationId,
              'phoneNumber': phoneNumber
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackbar(context, e.message!);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<void> verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      final phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );

      await _firebaseAuth.signInWithCredential(phoneAuthCredential);

      // check if the user had authenticated
      await getCurrentUserDataOrByUId().then((user) {
        if (user == null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            UserInformationScreen.routeName,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            MobileLayoutScreen.routeName,
            (route) => false,
          );
        }
      });
    } on FirebaseAuthException catch (e) {
      showSnackbar(context, e.message!);
      rethrow;
    }
  }

  Future<void> saveUserDataToFireStore({
    required BuildContext context,
    required ProviderRef ref,
    required File profilePic,
    required String name,
  }) async {
    try {
      final User currentUser = _firebaseAuth.currentUser!;

      String profilePicUrl = await ref
              .read<CommonFirestoreRepository>(
                  commonFirestoreRepositoryProvider)
              .storeFileToFirestore(
                  file: profilePic,
                  ref: 'userProfilePics/${currentUser.uid}') ??
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      final UserModel user = UserModel(
        uid: currentUser.uid,
        name: name,
        phoneNumber: currentUser.phoneNumber!,
        profilePicUrl: profilePicUrl,
        isOnline: true,
        groupsId: [],
      );

      await _firebaseFirestore
          .collection('users')
          .doc(currentUser.uid)
          .set(user.toDocument())
          .then((value) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MobileLayoutScreen()),
          (route) => false,
        );
      });
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Stream<UserModel> getUserDataByUId(String userId) {
    try {
      return _firebaseFirestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snap) => UserModel.fromSnapshot(snap));
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateOnlineState(bool isOnline) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({'isOnline': isOnline}).then(
        (value) => print('updated online status.'),
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
