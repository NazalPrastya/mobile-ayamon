class ScheduleModel {
  final String id;
  final String farmId;
  final String activity;
  final String category;
  final String date;
  final String loop;
  final String? note;
  final String createdAt;

  const ScheduleModel({
    required this.id,
    required this.farmId,
    required this.activity,
    required this.category,
    required this.date,
    required this.loop,
    this.note,
    required this.createdAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      activity: json['activity'] as String? ?? '',
      category: json['category'] as String? ?? '',
      date: json['date'] as String? ?? '',
      loop: json['loop'] as String? ?? '',
      note: json['note'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  String get displayDate {
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  String get shortDate {
    try {
      final d = DateTime.parse(date);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${d.day} ${months[d.month]}';
    } catch (_) {
      return date;
    }
  }

  DateTime get dateTime {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return DateTime.now();
    }
  }
}
