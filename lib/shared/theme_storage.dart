import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ThemeStorage {
  static const String _fileName = 'theme_mode.txt';

  Future<File> _getFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> saveMode(ThemeMode mode) async {
    try {
      final file = await _getFile();
      await file.writeAsString(_modeToString(mode), flush: true);
    } catch (_) {
      // ignore storage errors silently
    }
  }

  Future<ThemeMode?> readMode() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return _stringToMode(content.trim());
      }
    } catch (_) {
      // ignore storage errors silently
    }
    return null;
  }

  String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode? _stringToMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}


