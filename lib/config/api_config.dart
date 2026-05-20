import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// IP lokal komputer – dipakai saat test di device fisik.
  /// Jalankan `ipconfig getifaddr en0` di terminal untuk tahu IP-nya.
  static const String _localIp = '192.168.200.240';

  /// Ganti false → true jika test di device fisik (bukan emulator).
  static const bool _usePhysicalDevice = false;

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) {
      // 10.0.2.2 = localhost host di Android emulator
      return _usePhysicalDevice
          ? 'http://$_localIp:8000'
          : 'http://10.0.2.2:8000';
    }
    if (Platform.isIOS) return 'http://$_localIp:8000';
    return 'http://127.0.0.1:8000';
  }

  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get getMeUrl => '$baseUrl/api/auth/getMe';
  static String get registerUrl => '$baseUrl/api/auth/registration';
  static String get logoutUrl => '$baseUrl/api/auth/logout';
  static String get farmsUrl => '$baseUrl/api/farms';
  static String farmUrl(String id) => '$baseUrl/api/farm/$id';
  static String get createFarmUrl => '$baseUrl/api/farm';
}
