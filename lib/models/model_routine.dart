
class Routine {
  final int id;
  final String name;
  final int max;
  final String color;
  final int counts;

  Routine({required this.id, required this.name, required this.max, required this.color, required this.counts});

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      max: json['max'],
      color: json['color'],
      counts: json['counts'],
    );
  }
}
