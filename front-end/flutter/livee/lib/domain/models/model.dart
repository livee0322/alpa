/// 모델 프로필 정보를 담는 데이터 모델
class Model {
  final String id;
  final String? name;
  final String? profileImage;
  final String? jobTag;
  final int? experienceYears;
  final String? region;
  final String? category;
  final String? nickname;
  final String? oneLineIntro;
  final String? detailedIntro;
  final int? age;
  final String? mainLink;
  final String? mainThumbnailUrl;
  final String? backgroundImageUrl;
  final List<String>? subThumbnailUrls;
  final String? publicScope;
  final bool? isReceivingOffers;
  final String? status;
  final bool? isAgePublic;
  final String? detailedRegion;
  final String? gender;
  final int? height;
  final int? weight;
  final String? topSize;
  final String? bottomSize;
  final int? shoeSize;
  final bool? isSizingPublic;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? tiktokUrl;
  final bool? isExperiencePublic;
  final bool? isRegionPublic;
  final bool? isGenderPublic;
  final bool? isHeightPublic;
  final String? attachedFileUrl;

  Model({
    required this.id,
    this.name,
    this.profileImage,
    this.jobTag,
    this.experienceYears,
    this.region,
    this.category,
    this.nickname,
    this.oneLineIntro,
    this.detailedIntro,
    this.age,
    this.mainLink,
    this.mainThumbnailUrl,
    this.backgroundImageUrl,
    this.subThumbnailUrls,
    this.publicScope,
    this.isReceivingOffers,
    this.status,
    this.isAgePublic,
    this.detailedRegion,
    this.gender,
    this.height,
    this.weight,
    this.topSize,
    this.bottomSize,
    this.shoeSize,
    this.isSizingPublic,
    this.websiteUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.tiktokUrl,
    this.isExperiencePublic,
    this.isRegionPublic,
    this.isGenderPublic,
    this.isHeightPublic,
    this.attachedFileUrl,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['_id'] as String,
      name: json['name'] as String? ?? '이름 없음',
      profileImage: json['profileImage'] as String?,
      jobTag: json['jobTag'] as String?,
      experienceYears: json['experienceYears'] as int?,
      region: json['region'] as String?,
      category: json['category'] as String?,
      nickname: json['nickname'] as String?,
      oneLineIntro: json['oneLineIntro'] as String?,
      detailedIntro: json['detailedIntro'] as String?,
      age: json['age'] as int?,
      mainLink: json['mainLink'] as String?,
      mainThumbnailUrl: json['mainThumbnailUrl'] as String?,
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
      subThumbnailUrls: (json['subThumbnailUrls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      publicScope: json['publicScope'] as String?,
      isReceivingOffers: json['isReceivingOffers'] as bool?,
      status: json['status'] as String?,
      isAgePublic: json['isAgePublic'] as bool?,
      detailedRegion: json['detailedRegion'] as String?,
      gender: json['gender'] as String?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      topSize: json['topSize'] as String?,
      bottomSize: json['bottomSize'] as String?,
      shoeSize: json['shoeSize'] as int?,
      isSizingPublic: json['isSizingPublic'] as bool?,
      websiteUrl: json['websiteUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      isExperiencePublic: json['isExperiencePublic'] as bool?,
      isRegionPublic: json['isRegionPublic'] as bool?,
      isGenderPublic: json['isGenderPublic'] as bool?,
      isHeightPublic: json['isHeightPublic'] as bool?,
      attachedFileUrl: json['attachedFileUrl'] as String?,
    );
  }
}
