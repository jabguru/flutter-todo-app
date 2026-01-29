import 'package:flutter/material.dart';
import 'package:todo_app/core/storage/key_value_local_storage.dart';
import 'package:todo_app/core/storage/local_storage_exception.dart';

/// Local data source for theme preferences
class ThemeLocalDataSource {
  ThemeLocalDataSource(this._localStorage);

  final KeyValueLocalStorage _localStorage;
  static const String _themeKey = 'theme_mode';

  /// Save theme mode to local storage
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _localStorage.put(key: _themeKey, value: mode.name);
  }

  /// Get theme mode from local storage
  /// Returns ThemeMode.system if no preference is saved
  Future<ThemeMode> getThemeMode() async {
    try {
      final themeName = await _localStorage.get(_themeKey);
      return ThemeMode.values.byName(themeName);
    } on LocalStorageException catch (_) {
      // If no preference is saved, return system default
      return ThemeMode.system;
    }
  }

  /// Clear saved theme preference
  Future<void> clearThemeMode() async {
    await _localStorage.delete({_themeKey});
  }
}
