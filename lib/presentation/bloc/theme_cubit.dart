import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/theme_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeStorage _storage;
  ThemeCubit({ThemeMode initialMode = ThemeMode.light, ThemeStorage? storage})
      : _storage = storage ?? ThemeStorage(),
        super(initialMode);

  void setThemeMode(ThemeMode mode) {
    emit(mode);
    _storage.saveMode(mode);
  }
}


