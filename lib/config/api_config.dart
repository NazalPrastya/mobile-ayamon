import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _prodUrl = 'https://ayamon.creators.co.id';

  /// Set true untuk pakai server lokal (development), false untuk production.
  static const bool _useLocal = false;

  /// IP lokal komputer – hanya dipakai saat _useLocal = true & Android emulator.
  static const String _localIp = '192.168.200.240';

  static String get baseUrl {
    if (!_useLocal) return _prodUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://$_localIp:8000';
  }

  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get getMeUrl => '$baseUrl/api/auth/getMe';
  static String get registerUrl => '$baseUrl/api/auth/registration';
  static String get logoutUrl => '$baseUrl/api/auth/logout';
  static String get farmsUrl => '$baseUrl/api/farms';
  static String farmUrl(String id) => '$baseUrl/api/farm/$id';
  static String get createFarmUrl => '$baseUrl/api/farm';
  static String get dailyProductionUrl => '$baseUrl/api/daily-production';
  static String dailyProductionItemUrl(String id) =>
      '$baseUrl/api/daily-production/$id';
  static String get dailyProductionsUrl => '$baseUrl/api/daily-productions';
  static String enumerationsUrl(String key) =>
      '$baseUrl/api/enumerations?key=$key';
  static String expensesUrl(String farmId, {int page = 1}) =>
      '$baseUrl/api/expenses?farm_id=$farmId&page=$page';
  static String expenseUrl(String id) => '$baseUrl/api/expense/$id';
  static String get createExpenseUrl => '$baseUrl/api/expense';

  // ── Dashboard ──────────────────────────────────────────────────────────────
  static String dashboardDailyProductionsUrl(String farmId) =>
      '$baseUrl/api/dashboard/daily-productions?farm_id=$farmId';
  static String dashboardProductivityUrl(String farmId, {int days = 7}) =>
      '$baseUrl/api/dashboard/productivity?farm_id=$farmId&days=$days';
  static String dashboardResumeUrl(String farmId) =>
      '$baseUrl/api/dashboard/resume?farm_id=$farmId';
  static String dashboardExpensesUrl(String farmId) =>
      '$baseUrl/api/dashboard/expenses?farm_id=$farmId';
  static String dashboardFinancialSummaryUrl(String farmId) =>
      '$baseUrl/api/dashboard/financial-summary?farm_id=$farmId';
  static String dashboardReportUrl(String farmId) =>
      '$baseUrl/api/dashboard/report?farm_id=$farmId';

  // ── Schedules ─────────────────────────────────────────────────────────────
  static String schedulesUrl(String farmId, {int page = 1}) =>
      '$baseUrl/api/schedules?farm_id=$farmId&page=$page';
  static String scheduleUrl(String id) => '$baseUrl/api/schedule/$id';
  static String get createScheduleUrl => '$baseUrl/api/schedule';
}
