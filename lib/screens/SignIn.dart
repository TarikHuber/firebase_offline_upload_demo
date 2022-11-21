import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:fluttericon/font_awesome_icons.dart';
import '../services/user.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sign In'),
        ),
        //resizeToAvoidBottomInset: false,
        //backgroundColor: Theme.of(context).colorScheme.secondary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Visibility(
                    visible: true,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            UserService.signInWithGoogle();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                FontAwesome.google,
                                color: Colors.white,
                              ),
                              Container(
                                width: 10,
                              ),
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
