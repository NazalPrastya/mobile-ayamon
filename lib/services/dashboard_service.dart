import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class DashboardDailyData {
  final String date;
  final String farmName;
  final int chickenCount;
  final int eggTarget;
  final int eggCount;
  final double eggWeightKg;
  final int chickenAlive;
  final int chickenDeath;
  final double henDayPercent;
  final double henDayTarget;
  final double income;
  final double netIncome;
  final int totalEntry;

  const DashboardDailyData({
    required this.date,
    required this.farmName,
    required this.chickenCount,
    required this.eggTarget,
    required this.eggCount,
    required this.eggWeightKg,
    required this.chickenAlive,
    required this.chickenDeath,
    required this.henDayPercent,
    required this.henDayTarget,
    required this.income,
    required this.netIncome,
    required this.totalEntry,
  });

  factory DashboardDailyData.fromJson(Map<String, dynamic> json) {
    final farm = json['farm'] as Map<String, dynamic>;
    return DashboardDailyData(
      date: json['date'] as String? ?? '',
      farmName: farm['name'] as String? ?? '',
      chickenCount:
          int.tryParse(farm['chicken_count']?.toString() ?? '') ??
          (farm['chicken_count'] as num?)?.toInt() ??
          0,
      eggTarget:
          int.tryParse(farm['egg_target']?.toString() ?? '') ??
          (farm['egg_target'] as num?)?.toInt() ??
          0,
      eggCount: (json['egg_count'] as num?)?.toInt() ?? 0,
      eggWeightKg: (json['egg_weight_kg'] as num?)?.toDouble() ?? 0,
      chickenAlive: (json['chicken_alive'] as num?)?.toInt() ?? 0,
      chickenDeath: (json['chicken_death'] as num?)?.toInt() ?? 0,
      henDayPercent: (json['hen_day_percent'] as num?)?.toDouble() ?? 0,
      henDayTarget: (json['hen_day_target'] as num?)?.toDouble() ?? 0,
      income: (json['income'] as num?)?.toDouble() ?? 0,
      netIncome: (json['net_income'] as num?)?.toDouble() ?? 0,
      totalEntry: (json['total_entry'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProductivityPoint {
  final String date;
  final int eggCount;
  final double eggWeight;
  final int chickenDeath;

  const ProductivityPoint({
    required this.date,
    required this.eggCount,
    required this.eggWeight,
    required this.chickenDeath,
  });

  factory ProductivityPoint.fromJson(Map<String, dynamic> json) {
    return ProductivityPoint(
      date: json['date'] as String? ?? '',
      eggCount: (json['egg_count'] as num?)?.toInt() ?? 0,
      eggWeight: (json['egg_weight'] as num?)?.toDouble() ?? 0,
      chickenDeath: (json['chicken_death'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardResume {
  final double capital;
  final double totalIncome;
  final double totalExpenses;
  final double net;
  final double bepProgressPercent;
  final double bepRemaining;
  final int bepEstimatedDays;

  const DashboardResume({
    required this.capital,
    required this.totalIncome,
    required this.totalExpenses,
    required this.net,
    required this.bepProgressPercent,
    required this.bepRemaining,
    required this.bepEstimatedDays,
  });

  factory DashboardResume.fromJson(Map<String, dynamic> json) {
    return DashboardResume(
      capital: double.tryParse(json['capital']?.toString() ?? '0') ?? 0,
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0,
      net: (json['net'] as num?)?.toDouble() ?? 0,
      bepProgressPercent:
          (json['bep_progress_percent'] as num?)?.toDouble() ?? 0,
      bepRemaining: (json['bep_remaining'] as num?)?.toDouble() ?? 0,
      bepEstimatedDays: (json['bep_estimated_days'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardScheduleItem {
  final String id;
  final String name;
  final String date;
  final String type;
  final bool isOverdue;

  const DashboardScheduleItem({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    required this.isOverdue,
  });

  factory DashboardScheduleItem.fromJson(
    Map<String, dynamic> json, {
    required bool isOverdue,
  }) {
    return DashboardScheduleItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      date: json['date'] as String? ?? '',
      type: json['category'] as String? ?? json['type'] as String? ?? '',
      isOverdue: isOverdue,
    );
  }
}

class DashboardExpensesData {
  final List<DashboardScheduleItem> upcomingSchedules;
  final List<DashboardScheduleItem> overdueSchedules;

  const DashboardExpensesData({
    required this.upcomingSchedules,
    required this.overdueSchedules,
  });

  List<DashboardScheduleItem> get allSchedules => [
    ...overdueSchedules,
    ...upcomingSchedules,
  ];

  factory DashboardExpensesData.fromJson(Map<String, dynamic> json) {
    final upcoming = (json['upcoming_schedules'] as List<dynamic>? ?? [])
        .map(
          (e) => DashboardScheduleItem.fromJson(
            e as Map<String, dynamic>,
            isOverdue: false,
          ),
        )
        .toList();
    final overdue = (json['overdue_schedules'] as List<dynamic>? ?? [])
        .map(
          (e) => DashboardScheduleItem.fromJson(
            e as Map<String, dynamic>,
            isOverdue: true,
          ),
        )
        .toList();
    return DashboardExpensesData(
      upcomingSchedules: upcoming,
      overdueSchedules: overdue,
    );
  }
}

class DashboardService {
  DashboardService._();
  static final DashboardService instance = DashboardService._();

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<DashboardDailyData?> fetchDailyData(String farmId) async {
    try {
      final resp = await http
          .get(
            Uri.parse(ApiConfig.dashboardDailyProductionsUrl(farmId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 401) {
        AuthService.instance.handleUnauthorized();
        return null;
      }
      if (resp.statusCode == 200 && body['status'] == 'success') {
        return DashboardDailyData.fromJson(
          body['data'] as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<List<ProductivityPoint>> fetchProductivity(
    String farmId, {
    int days = 7,
  }) async {
    try {
      final resp = await http
          .get(
            Uri.parse(ApiConfig.dashboardProductivityUrl(farmId, days: days)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 401) {
        AuthService.instance.handleUnauthorized();
        return [];
      }
      if (resp.statusCode == 200 && body['status'] == 'success') {
        final list = body['data'] as List<dynamic>;
        return list
            .map((e) => ProductivityPoint.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<DashboardResume?> fetchResume(String farmId) async {
    try {
      final resp = await http
          .get(
            Uri.parse(ApiConfig.dashboardResumeUrl(farmId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 401) {
        AuthService.instance.handleUnauthorized();
        return null;
      }
      if (resp.statusCode == 200 && body['status'] == 'success') {
        return DashboardResume.fromJson(body['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<DashboardExpensesData?> fetchExpenses(String farmId) async {
    try {
      final resp = await http
          .get(
            Uri.parse(ApiConfig.dashboardExpensesUrl(farmId)),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (resp.statusCode == 401) {
        AuthService.instance.handleUnauthorized();
        return null;
      }
      if (resp.statusCode == 200 && body['status'] == 'success') {
        return DashboardExpensesData.fromJson(
          body['data'] as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return null;
  }
}
