import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance;

class StorageService {
  static Future<String?> uploadFile(String path, File file) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref(path);
      await storageReference.putFile(file);

      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      return null;
    }
  }
}
