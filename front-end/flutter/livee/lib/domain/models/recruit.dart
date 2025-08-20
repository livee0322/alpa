class Recruit {
  final String? title;
  final String? date;
  final String? timeStart;
  final String? timeEnd;
  final String? location;
  final String? pay;
  final bool? payNegotiable;
  final String? category;
  final String? description;

  Recruit({
    this.title,
    this.date,
    this.timeStart,
    this.timeEnd,
    this.location,
    this.pay,
    this.payNegotiable,
    this.category,
    this.description,
  });

  factory Recruit.fromJson(Map<String, dynamic> json) {
    return Recruit(
      title: json['title'] as String?,
      date: json['date'] as String?,
      timeStart: json['timeStart'] as String?,
      timeEnd: json['timeEnd'] as String?,
      location: json['location'] as String?,
      pay: json['pay'] as String?,
      payNegotiable: json['payNegotiable'] as bool?,
      category: json['category'] as String?,
      description: json['description'] as String?,
    );
  }
}