import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _languageKey = "languageCode";

  LanguageProvider() {
    _loadLanguage();
  }

  Locale get locale => _locale;

  /// Returns the language code in the format TMDB API expects (e.g., 'hi-IN' or 'en-US')
  String get tmdbLanguageCode {
    switch (_locale.languageCode) {
      case 'hi':
        return 'hi-IN';
      case 'ur':
        return 'ur-PK';
      default:
        return 'en-US';
    }
  }

  void setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_languageKey, languageCode);
  }

  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
}
