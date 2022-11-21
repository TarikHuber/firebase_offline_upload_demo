import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user.dart';

final _auth = FirebaseAuth.instance;

class UserProvider extends ChangeNotifier {
  User? _user;

  UserProvider(BuildContext context) {
    _auth.authStateChanges().listen((User? user) {
      if (_user == null && user != null) {
        //Navigator.of(context).pushReplacementNamed('/');
      }

      _user = user;
      notifyListeners();

      if (user != null) {
        DateTime dateTime = DateTime.now();

        UserService.updateUser({
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'uid': user.uid,
          'timeZoneName': dateTime.timeZoneName,
          'timeZoneOffset': dateTime.timeZoneOffset.toString(),
          //'locale': settingsProvider.locale.languageCode
        });
      }
    });
  }

  void listen() {
    try {
      UserService.listenUserDataChanges((dynamic user) {
        {
          _user = user;
          print('user2 $user');
          notifyListeners();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  User? get user {
    return _auth.currentUser;
  }

  dynamic get userData {
    return _user;
  }
}
