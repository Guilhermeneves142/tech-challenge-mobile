import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ReceiptStorageService {
  ReceiptStorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> upload({
    required String userId,
    required String transactionId,
    required File file,
  }) async {
    final extension = file.path.split('.').last.toLowerCase();

    final ref = _storage.ref(
      'receipts/$userId/$transactionId.$extension',
    );

    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deleteByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        rethrow;
      }
    }
  }
}