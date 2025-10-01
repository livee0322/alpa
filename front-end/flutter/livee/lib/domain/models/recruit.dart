class Recruit {
  final String? recruitType;
  final String? location;
  final String? requirements;
  final String? preferred;
  final List<String>? questions;
  final num? durationInHours; // 촬영 시간을 시간 단위

  Recruit({
    this.recruitType,
    this.location,
    this.requirements,
    this.preferred,
    this.questions,
    this.durationInHours,
  });

  factory Recruit.fromJson(Map<String, dynamic> json) {
    return Recruit(
      recruitType: json['recruitType'] as String?,
      location: json['location'] as String?,
      requirements: json['requirements'] as String?,
      preferred: json['preferred'] as String?,
      questions: json['questions'] != null ? List<String>.from(json['questions']) : null,
      durationInHours: json['durationInHours'] as num?,
    );
  }
}
