import 'package:expenses_app/models/settings_state.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

class HiveService {
  static final String _settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(SettingsStateAdapter());

    await Hive.openBox<SettingsState>(_settingsBoxName);

    // Initialize default settings if none exist
    if (_settingsBox.isEmpty) {
      final defaultSettings = SettingsState(isDarkMode: false, fontSize: 14);
      await _settingsBox.put('settings', defaultSettings);
    }
  }

  static Box<SettingsState> get _settingsBox =>
      Hive.box<SettingsState>(_settingsBoxName);

  // Settings management
  static SettingsState? getSettings() {
    return _settingsBox.get('settings');
  }

  static Future<void> updateDarkMode(bool isDarkMode) async {
    final settings = getSettings();
    if (settings != null) {
      settings.isDarkMode = isDarkMode;
      await _settingsBox.put('settings', settings);
    }
  }

  static Future<void> updateFontSize(int fontSize) async {
    final settings = getSettings();
    if (settings != null) {
      settings.fontSize = fontSize;
      await _settingsBox.put('settings', settings);
    }
  }

  static Listenable get settingsListenable => _settingsBox.listenable();
}
