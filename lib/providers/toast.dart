import 'package:flutter/material.dart';

class ToastProvider extends ChangeNotifier {
  String _message = '';

  String get message => _message;

  void show(String msg) {
    _message = msg;
    notifyListeners();
  }

  void clear() {
    _message = '';
    notifyListeners();
  }
}
