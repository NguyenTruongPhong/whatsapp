import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod/riverpod.dart';

final commonFirestoreRepositoryProvider =
    Provider<CommonFirestoreRepository>((ref) {
  return CommonFirestoreRepository(firebaseStorage: FirebaseStorage.instance);
});

class CommonFirestoreRepository {
  final FirebaseStorage firebaseStorage;

  const CommonFirestoreRepository({
    required this.firebaseStorage,
  });

  Future<String?> storeFileToFirestore({
    required File file,
    required String ref,
  }) async {
    try {
      final TaskSnapshot taskSnapshot =
          await firebaseStorage.ref().child(ref).putFile(file);
      return taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
