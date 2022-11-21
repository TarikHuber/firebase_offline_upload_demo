import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_provider.dart';
import 'screens/Main.dart';
import 'screens/SignIn.dart';

final _auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({Key? key, required this.prefs}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) => SettingsProvider(prefs: prefs),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(context),
        ),
      ],
      child: Consumer2<SettingsProvider, UserProvider>(
          builder: (context, settingsProvider, userProvider, child) {
        //settingsProvider.initLocale();

        return StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: SignInScreen(),
              );
            } else {
              return FeatureDiscovery(
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: settingsProvider.locale,
                  initialRoute: '/',
                  routes: {
                    '/': (context) => MainScreen(),
                    '/sign_in': (context) => SignInScreen(),
                  },
                ),
              );
            }
          },
        );
      }),
    );
  }
}
