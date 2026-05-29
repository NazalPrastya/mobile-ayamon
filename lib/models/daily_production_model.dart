class DailyProductionModel {
  final String id;
  final String farmId;
  final String date;
  final int eggCount;
  final int chickenDeath;
  final double eggWeight;
  final double feedSold;
  final String? note;
  final String createdAt;

  const DailyProductionModel({
    required this.id,
    required this.farmId,
    required this.date,
    required this.eggCount,
    required this.chickenDeath,
    required this.eggWeight,
    required this.feedSold,
    this.note,
    required this.createdAt,
  });

  factory DailyProductionModel.fromJson(Map<String, dynamic> json) {
    return DailyProductionModel(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      date: json['date'] as String,
      eggCount: int.tryParse(json['egg_count']?.toString() ?? '') ?? 0,
      chickenDeath: int.tryParse(json['chicken_death']?.toString() ?? '') ?? 0,
      eggWeight: double.tryParse(json['egg_weight']?.toString() ?? '0') ?? 0.0,
      feedSold: double.tryParse(json['feed_sold']?.toString() ?? '0') ?? 0.0,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  /// Format date "2026-10-10T..." → "10/10/2026"
  String get displayDate {
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  static const _monthNames = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Format date "2026-10-10T..." → "10 Oct"
  String get shortDate {
    try {
      final d = DateTime.parse(date);
      return '${d.day} ${_monthNames[d.month]}';
    } catch (_) {
      return date;
    }
  }
}
