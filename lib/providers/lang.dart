import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:ui';

/// Singleton pour stocker les traductions
class LangProvider {
  static final LangProvider _instance = LangProvider._internal();
  static Map<String, dynamic>? _translations;

  LangProvider._internal();

  factory LangProvider() => _instance;

  static Future<void> init() async {
    final lang = PlatformDispatcher.instance.locale.languageCode;
    final fileLang = 'assets/langs/$lang.json';
    final jsonString = await rootBundle.loadString(fileLang);
    _translations = json.decode(jsonString) as Map<String, dynamic>;
  }

  static get(String key) {
    return _translations?[key] ?? key;
  }
}
