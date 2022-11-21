import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final bool appleAvailable;

  SettingsProvider({required this.prefs, this.appleAvailable = false});

  Locale get locale {
    String l = prefs.getString('locale') ?? 'de';
    return Locale(l, '');
  }

  Brightness get brightness {
    bool isDarkOn = prefs.getBool('isDarkOn') ?? false;
    return isDarkOn ? Brightness.dark : Brightness.light;
  }

  bool get showOnboarding {
    bool showOnboarding = prefs.getBool('showOnboarding') ?? true;
    return showOnboarding;
  }

  bool get isAppleAvailable {
    return appleAvailable;
  }

  void initLocale() {
    String l = prefs.getString('locale') ?? 'de';
  }

  void setlocale(Locale l) async {
    prefs.setString('locale', l.languageCode);
    notifyListeners();

    try {
      UserService.updateUser({'locale': l.toString()});
    } catch (e) {
      print(e);
    }
  }

  void setBrigthness(Brightness b) {
    prefs.setBool('isDarkOn', b == Brightness.dark);
    notifyListeners();
  }

  void setShowOnboarding(bool show) {
    prefs.setBool('showOnboarding', show);
    notifyListeners();
  }
}
