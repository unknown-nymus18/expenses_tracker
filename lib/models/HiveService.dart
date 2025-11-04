import 'package:expenses_app/models/settings_state.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';

class HiveService {
  static final String _settingsBoxName = 'settings';

  static Future<void> init() async {
    try {
      print('🔧 Initializing Hive...');
      await Hive.initFlutter();
      print('✅ Hive.initFlutter() completed');

      print('🔧 Registering SettingsStateAdapter...');
      if (!Hive.isAdapterRegistered(3)) {
        // typeId is 3
        Hive.registerAdapter(SettingsStateAdapter());
        print('✅ SettingsStateAdapter registered with typeId 3');
      } else {
        print('⚠️ SettingsStateAdapter already registered');
      }

      print('🔧 Opening settings box...');
      await Hive.openBox<SettingsState>(_settingsBoxName);
      print('✅ Settings box opened');

      // Initialize default settings if none exist
      if (_settingsBox.isEmpty) {
        print('🔧 Creating default settings...');
        final defaultSettings = SettingsState(isDarkMode: false, fontSize: 14);
        await _settingsBox.put('settings', defaultSettings);
        print('✅ Default settings created');
      } else {
        print('✅ Existing settings found');
      }

      print('✅ Hive initialization complete');
    } catch (e, stackTrace) {
      print('❌ Hive initialization error: $e');
      print('Stack trace: $stackTrace');
      // Don't rethrow - let the app continue even if Hive fails
      // The app will use default settings
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
