import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State for theme management
class ThemeState extends Equatable {
  const ThemeState({this.themeMode = ThemeMode.system});

  final ThemeMode themeMode;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object?> get props => [themeMode];
}
