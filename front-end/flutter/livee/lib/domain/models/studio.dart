import 'package:livee/presentation/screens/studio/models/day_schedule.dart';

/// 스튜디오 정보를 담는 데이터 모델
class Studio {
  final String? id; // 고유 식별자
  final String brandName; // 브랜드명
  final String oneLineIntro; // 한 줄 소개
  final String detailedIntro; // 상세 소개
  final String usageInfo; // 이용 안내
  final String priceInfo; // 금액 안내
  final String? mainThumbnailUrl; // 메인 썸네일 URL
  final String? backgroundImageUrl; // 배경 이미지 URL
  final List<String> subThumbnailUrls; // 서브 썸네일 URL 목록
  final List<String> galleryUrls; // 갤러리 이미지 URL 목록
  final Contact contact; // 연락처 정보
  final Location location; // 위치 정보
  final Map<String, DaySchedule> weeklySchedule; // 주간 스케줄

  Studio({
    this.id,
    required this.brandName,
    required this.oneLineIntro,
    required this.detailedIntro,
    required this.usageInfo,
    required this.priceInfo,
    this.mainThumbnailUrl,
    this.backgroundImageUrl,
    required this.subThumbnailUrls,
    required this.galleryUrls,
    required this.contact,
    required this.location,
    required this.weeklySchedule,
  });

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(
      id: json['_id'] as String?,
      brandName: json['brandName'] as String,
      oneLineIntro: json['oneLineIntro'] as String,
      detailedIntro: json['detailedIntro'] as String,
      usageInfo: json['usageInfo'] as String,
      priceInfo: json['priceInfo'] as String,
      mainThumbnailUrl: json['mainThumbnailUrl'] as String?,
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
      subThumbnailUrls: List<String>.from(json['subThumbnailUrls']),
      galleryUrls: List<String>.from(json['galleryUrls']),
      contact: Contact.fromJson(json['contact']),
      location: Location.fromJson(json['location']),
      weeklySchedule: (json['weeklySchedule'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, DaySchedule.fromJson(value)),
      ),
    );
  }
}

/// 연락처 정보를 담는 보조 모델
class Contact {
  final String phone; // 전화번호
  final String email; // 이메일
  final String kakao; // 카카오톡 링크
  Contact({required this.phone, required this.email, required this.kakao});
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      phone: json['phone'] as String,
      email: json['email'] as String,
      kakao: json['kakao'] as String,
    );
  }
}

/// 위치 정보를 담는 보조 모델
class Location {
  final String address; // 주소
  final String mapUrl; // 지도 URL
  Location({required this.address, required this.mapUrl});
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] as String,
      mapUrl: json['mapUrl'] as String,
    );
  }
}


