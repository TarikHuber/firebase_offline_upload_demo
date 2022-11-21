import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

String syncBasePath = '/users/';

/*
Service to update User data to the RTD or Firestore
and listen to changes of that data
*/
class UserService {
  static Future _syncWithFirestore(Map<String, dynamic> data) async {
    if (_auth.currentUser != null) {
      await _firestore
          .doc('$syncBasePath${_auth.currentUser?.uid}')
          .set(data, SetOptions(merge: true));
    }
  }

  static Stream<DocumentSnapshot> _firestoreListener() {
    return _firestore.doc('$syncBasePath${_auth.currentUser?.uid}').snapshots();
  }

  static updateUser(Map<String, dynamic> data) async {
    return _syncWithFirestore(data);
  }

  static listenUserDataChanges(Function(dynamic) onUserDataChanged) {
    return _firestoreListener().listen((e) {
      //_user = e.data();
      onUserDataChanged(e.data());
    });
  }

  static Future signOut() async {
    _auth.signOut();
  }

  static Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  static Future createAccount(
      String email, String password, String displayName) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    try {
      await userCredential.user?.updateDisplayName(displayName);

      await _auth.currentUser?.reload();

      await _auth.currentUser?.sendEmailVerification();

      //TO DO sync to database
    } catch (e) {
      print('error! $e');
    }
  }
}
