class FarmModel {
  final String id;
  final String name;
  final String? location;
  final String periode;
  final int chickenCount;
  final String capital;
  final String priceSell;
  final String priceFeed;
  final String priceOps;
  final int eggTarget;

  const FarmModel({
    required this.id,
    required this.name,
    this.location,
    required this.periode,
    required this.chickenCount,
    required this.capital,
    required this.priceSell,
    required this.priceFeed,
    required this.priceOps,
    required this.eggTarget,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      periode: json['periode'] as String? ?? '-',
      chickenCount:
          int.tryParse(json['chicken_count']?.toString() ?? '') ??
          (json['chicken_count'] as int? ?? 0),
      capital: json['capital'] as String? ?? '0',
      priceSell: json['price_sell'] as String? ?? '0',
      priceFeed: json['price_feed'] as String? ?? '0',
      priceOps: json['price_ops'] as String? ?? '0',
      eggTarget:
          int.tryParse(json['egg_target']?.toString() ?? '') ??
          (json['egg_target'] as int? ?? 0),
    );
  }
}
