import 'package:hive_flutter/adapters.dart';

part 'settings_state.g.dart';

@HiveType(typeId: 3)
class SettingsState extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  int fontSize;

  SettingsState({required this.isDarkMode, required this.fontSize});

  bool get isDarkModeEnabled => isDarkMode;

  int get getfontSize => fontSize;
}
