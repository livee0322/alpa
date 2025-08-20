class Live {
  final String? date;
  final String? time;

  Live({
    this.date,
    this.time,
  });

  factory Live.fromJson(Map<String, dynamic> json) {
    return Live(
      date: json['date'] as String?,
      time: json['time'] as String?,
    );
  }
}
