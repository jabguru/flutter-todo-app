import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/settings/data/datasources/theme_local_data_source.dart';
import 'package:todo_app/features/settings/presentation/cubit/theme_state.dart';

/// Cubit to manage theme mode state
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._localDataSource) : super(const ThemeState());

  final ThemeLocalDataSource _localDataSource;

  /// Load saved theme preference on app startup
  Future<void> loadThemeMode() async {
    final result = await _localDataSource.getThemeMode();
    emit(state.copyWith(themeMode: result));
  }

  /// Change theme mode and persist the preference
  Future<void> changeThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _localDataSource.saveThemeMode(mode);
  }
}
