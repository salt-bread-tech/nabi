class Ingestion {
  final double? totalCalories;
  final double? totalCarb;
  final double? totalFat;
  final double? totalProtein;
  final double? breakfastCalories;
  final double? lunchCalories;
  final double? dinnerCalories;
  final double? snackCalories;

  Ingestion({
    required this.totalCalories,
    required this.totalCarb,
    required this.totalFat,
    required this.totalProtein,
    required this.breakfastCalories,
    required this.lunchCalories,
    required this.dinnerCalories,
    required this.snackCalories,
  });

  factory Ingestion.fromJson(Map<String, dynamic> json) {
    return Ingestion(
      totalCalories: json['totalKcal'],
      totalCarb: json['totalCarbohydrate'],
      totalFat: json['totalFat'],
      totalProtein: json['totalProtein'],
      breakfastCalories: json['breakfastKcal'],
      lunchCalories: json['lunchKcal'],
      dinnerCalories: json['dinnerKcal'],
      snackCalories: json['snackKcal'],
    );
  }
}