import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String _definedHost = String.fromEnvironment('HOST');
  static const String _computerHost = 'http://192.168.124.25:8000';

  static String get host {
    if (_definedHost.isNotEmpty) return _definedHost;
    if (kIsWeb) return Uri.base.origin;

    return Platform.isAndroid ? _computerHost : 'http://127.0.0.1:8000';
  }

  static const String language = 'ru';

  static String get baseUrl => '$host/$language/';

  static const int pageSize = 20;
  static const int bigLimit = 100;
}
