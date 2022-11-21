import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_offline_upload_demo/constants.dart';
import 'dart:io';
import 'package:firebase_offline_upload_demo/services/storage.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

final _storage = FirebaseStorage.instance;
final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

String getRenamePath(File file, String newFileName) {
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  return path.substring(0, lastSeparator + 1) +
      newFileName +
      basename(file.path);
}

Future<String?> uploadFile(String storagePath, String filePath) async {
  String? downloadURL = '';

  try {
    downloadURL = await StorageService.uploadFile(storagePath, File(filePath));
  } catch (e) {
    print(e);
  }

  return downloadURL;
}

class FilesSync {
  static bool isSyncing = false;

  static Future<void> syncTaskFiles() async {
    User? user = _auth.currentUser;

    if (user == null) {
      return;
    }

    if (isSyncing) {
      return;
    }

    isSyncing = true;
    try {
      String syncPath = 'users/${user.uid}/uploads';
      print('syncPath: $syncPath');
      QuerySnapshot uploadsSnap = await _firestore.collection(syncPath).get();

      uploadsSnap.docs.forEach((QueryDocumentSnapshot syncFile) async {
        String id = syncFile.id;
        String localPath = getValue(syncFile.data(), 'local_path', '');
        String storagePath = getValue(syncFile.data(), 'storage_path', '');
        String firestorePath = getValue(syncFile.data(), 'firestore_path', '');

        if (localPath != '') {
          String? downloadURL = await uploadFile(storagePath, localPath);

          print('downloadURL: $downloadURL');
          print('firestorePath: $firestorePath');

          if (downloadURL != '') {
            _firestore.doc(firestorePath).update({
              "downloadURL": downloadURL,
              "storageURL": storagePath,
              "local_path": FieldValue.delete(),
              "bucket": _storage.bucket
            });
            _firestore.doc('$syncPath/$id').delete();
          }
        }
      });
    } catch (e) {
      print('error syncing files: $e');
    }

    isSyncing = false;
    return;
  }
}
