import 'package:flutter/material.dart';

class BottomNavbarManager extends ChangeNotifier {
  bool _isFloating = true; // Start as floating

  bool get isFloating => _isFloating;

  void makeFloating() {
    if (!_isFloating) {
      _isFloating = true;
      notifyListeners();
    }
  }

  void stickToBottom() {
    if (_isFloating) {
      _isFloating = false;
      notifyListeners();
    }
  }

  void toggleFloating() {
    _isFloating = !_isFloating;
    notifyListeners();
  }
}
