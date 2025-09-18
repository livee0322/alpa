import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/models/portfolio_image.dart';

/// '모델'과 '포트폴리오' 등록/수정 ViewModel이 따라야 할 공통 설계도(인터페이스)
abstract class ProfileEditViewModelBase with ChangeNotifier {
  // --- Controllers ---
  TextEditingController get nicknameController;
  TextEditingController get oneLineIntroController;
  TextEditingController get detailedIntroController;
  TextEditingController get experienceYearsController;
  TextEditingController get ageController;
  TextEditingController get regionController;
  TextEditingController get detailedRegionController;
  TextEditingController get heightController;
  TextEditingController get weightController;
  TextEditingController get topSizeController;
  TextEditingController get bottomSizeController;
  TextEditingController get shoeSizeController;
  TextEditingController get websiteUrlController;
  TextEditingController get instagramUrlController;
  TextEditingController get youtubeUrlController;
  TextEditingController get tiktokUrlController;

  // --- Properties ---
  PortfolioImage? get mainThumbnailSource;
  set mainThumbnailSource(PortfolioImage? value);
  PortfolioImage? get backgroundImageSource;
  set backgroundImageSource(PortfolioImage? value);
  List<PortfolioImage> get subThumbnailSources;
  String? get attachedFileUrl;
  set attachedFileUrl(String? value);
  String? get attachedFileName;
  String get publicScope;
  bool get isReceivingOffers;
  String? get gender;
  bool get isAgePublic;
  bool get isSizingPublic;
  bool get isExperiencePublic;
  bool get isRegionPublic;
  bool get isGenderPublic;
  bool get isHeightPublic;
  bool get isLoading;

  // --- Methods ---
  void pickImage({required Function(PortfolioImage) onImageSelected});
  void removeSubThumbnail(int index);
  void setPublicScope(String? value);
  void setIsReceivingOffers(bool? value);
  void setGender(String? value);
  void setIsAgePublic(bool? value);
  void setIsSizingPublic(bool? value);
  void setIsExperiencePublic(bool? value);
  void setIsRegionPublic(bool? value);
  void setIsGenderPublic(bool? value);
  void setIsHeightPublic(bool? value);
  void pickFileForCache();
  void removeAttachedFile();
}
