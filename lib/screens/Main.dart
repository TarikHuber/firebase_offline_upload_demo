import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_offline_upload_demo/services/files_sync.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/user_provider.dart';
import '../services/user.dart';

final ImagePicker _picker = ImagePicker();
final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Stream<QuerySnapshot> _imagesStream = _firestore
      .collection('users/${_auth.currentUser?.uid}/images')
      .snapshots();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FilesSync.syncTaskFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              UserService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _imagesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return ListView(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  String downloadURL = getValue(data, 'downloadURL', '');
                  String localPath = getValue(data, 'local_path', '');

                  return ListTile(
                    leading: CircleAvatar(
                        backgroundImage: localPath != ''
                            ? FileImage(File(localPath!)) as ImageProvider
                            : CachedNetworkImageProvider(downloadURL)),
                    title: Text(getValue(
                        document.data()!, 'local_path', 'local path missing')),
                    subtitle: Text(getValue(document.data()!, 'downloadURL',
                        'downloadURL missing')),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _firestore
                            .collection(
                                'users/${_auth.currentUser?.uid}/images')
                            .doc(document.id)
                            .delete();
                      },
                    ),
                  );
                })
                .toList()
                .cast(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile? photo =
              await _picker.pickImage(source: ImageSource.camera);
          DocumentReference ref = await _firestore
              .collection('users/${_auth.currentUser?.uid}/images')
              .add({'local_path': photo!.path});
          await _firestore
              .collection('users/${_auth.currentUser?.uid}/uploads')
              .add({
            'local_path': photo.path,
            'firestore_path':
                'users/${_auth.currentUser?.uid}/images/${ref.id}',
            'storage_path':
                'users/${_auth.currentUser?.uid}/images/${ref.id}_${DateTime.now()}.png'
          });

          FilesSync.syncTaskFiles();
        },
        child: const Icon(Icons.file_upload),
      ),
    );
  }
}
