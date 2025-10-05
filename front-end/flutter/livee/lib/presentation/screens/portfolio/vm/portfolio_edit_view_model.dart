import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/presentation/common/vm/form_view_model_base.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/presentation/screens/portfolio/models/portfolio_image.dart';
import 'package:livee/presentation/screens/portfolio/recent_live_controller.dart';
import 'package:livee/presentation/screens/portfolio/vm/profile_edit_view_model_base.dart';
import 'package:livee/service_locator.dart';

class PortfolioEditViewModel extends FormViewModelBase implements ProfileEditViewModelBase {
  // --- 의존성 주입 ---
  final PortfolioRepository _portfolioRepository = locator<PortfolioRepository>();
  final ImageHandlerProvider _imageHandlerProvider = locator<ImageHandlerProvider>();

  // [수정] 생성자에서 부모 클래스의 생성자를 호출
  PortfolioEditViewModel({required super.context, String? portfolioId}) : super(id: portfolioId);

  // --- 상태 변수 ---
  @override
  PortfolioImage? mainThumbnailSource;
  @override
  PortfolioImage? backgroundImageSource;
  @override
  final List<PortfolioImage> subThumbnailSources = [];

  // 컨트롤러
  @override
  final nicknameController = TextEditingController();
  @override
  final oneLineIntroController = TextEditingController();
  @override
  final detailedIntroController = TextEditingController();
  @override
  final experienceYearsController = TextEditingController();
  @override
  final ageController = TextEditingController();
  @override
  final regionController = TextEditingController();
  @override
  final detailedRegionController = TextEditingController();
  @override
  final heightController = TextEditingController();
  @override
  final weightController = TextEditingController();
  @override
  final topSizeController = TextEditingController();
  @override
  final bottomSizeController = TextEditingController();
  @override
  final shoeSizeController = TextEditingController();
  @override
  final websiteUrlController = TextEditingController();
  @override
  final instagramUrlController = TextEditingController();
  @override
  final youtubeUrlController = TextEditingController();
  @override
  final tiktokUrlController = TextEditingController();

  // 설정값
  String _publicScope = '전체공개';
  String? _gender;
  bool _isReceivingOffers = true;
  bool _isAgePublic = false;
  bool _isSizingPublic = false;
  bool _isExperiencePublic = false;
  bool _isRegionPublic = false;
  bool _isGenderPublic = false;
  bool _isHeightPublic = false;

  // 첨부 파일
  @override
  String? attachedFileUrl;
  @override
  String? attachedFileName;
  Uint8List? _tempAttachedFileBytes;

  final List<RecentLiveControllers> recentLiveControllers = [];

  // --- Getter ---
  @override
  String get publicScope => _publicScope;
  @override
  String? get gender => _gender;
  @override
  bool get isReceivingOffers => _isReceivingOffers;
  @override
  bool get isAgePublic => _isAgePublic;
  @override
  bool get isSizingPublic => _isSizingPublic;
  @override
  bool get isExperiencePublic => _isExperiencePublic;
  @override
  bool get isRegionPublic => _isRegionPublic;
  @override
  bool get isGenderPublic => _isGenderPublic;
  @override
  bool get isHeightPublic => _isHeightPublic;

  // --- 상태 변경 메소드 ---
  @override
  void setPublicScope(String? value) {
    if (value != null) {
      _publicScope = value;
      notifyListeners();
    }
  }

  @override
  void setIsReceivingOffers(bool? value) {
    _isReceivingOffers = value ?? true;
    notifyListeners();
  }

  @override
  void setGender(String? value) {
    if (value != null) {
      _gender = value == '선택 안함' ? null : value;
      notifyListeners();
    }
  }

  @override
  void removeSubThumbnail(int index) {
    subThumbnailSources.removeAt(index);
    notifyListeners();
  }

  @override
  void setIsAgePublic(bool? value) {
    _isAgePublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsSizingPublic(bool? value) {
    _isSizingPublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsExperiencePublic(bool? value) {
    _isExperiencePublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsRegionPublic(bool? value) {
    _isRegionPublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsGenderPublic(bool? value) {
    _isGenderPublic = value ?? false;
    notifyListeners();
  }

  @override
  void setIsHeightPublic(bool? value) {
    _isHeightPublic = value ?? false;
    notifyListeners();
  }

  void addRecentLiveLink() {
    recentLiveControllers.add(RecentLiveControllers());
    notifyListeners();
  }

  void removeRecentLiveLink(int index) {
    recentLiveControllers[index].dispose();
    recentLiveControllers.removeAt(index);
    notifyListeners();
  }

  @override
  Future<void> pickFileForCache() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['hwp', 'doc', 'docx', 'ppt', 'pptx', 'pdf'],
    );

    if (result != null && result.files.single.bytes != null) {
      _tempAttachedFileBytes = result.files.single.bytes;
      attachedFileName = result.files.single.name;
      attachedFileUrl = null;
      notifyListeners();
    }
  }

  @override
  void removeAttachedFile() {
    attachedFileUrl = null;
    attachedFileName = null;
    _tempAttachedFileBytes = null;
    notifyListeners();
  }

  // [수정] 부모 클래스의 추상 메소드인 loadDataForEdit를 구현합니다.
  @override
  Future<void> loadDataForEdit() async {
    final portfolio = await _portfolioRepository.getPortfolioById(id!);
    // 각 컨트롤러에 데이터 채우기
    nicknameController.text = portfolio.nickname ?? '';
    oneLineIntroController.text = portfolio.oneLineIntro ?? '';
    detailedIntroController.text = portfolio.detailedIntro ?? '';
    experienceYearsController.text = portfolio.experienceYears?.toString() ?? '';
    ageController.text = portfolio.age?.toString() ?? '';
    _isAgePublic = portfolio.isAgePublic ?? false;

    regionController.text = portfolio.region ?? '';
    detailedRegionController.text = portfolio.detailedRegion ?? '';
    _gender = portfolio.gender;
    heightController.text = portfolio.height?.toString() ?? '';
    weightController.text = portfolio.weight?.toString() ?? '';
    topSizeController.text = portfolio.topSize ?? '';
    bottomSizeController.text = portfolio.bottomSize ?? '';
    shoeSizeController.text = portfolio.shoeSize?.toString() ?? '';
    _isSizingPublic = portfolio.isSizingPublic ?? false;
    _isExperiencePublic = portfolio.isExperiencePublic ?? false;
    _isRegionPublic = portfolio.isRegionPublic ?? false;
    _isGenderPublic = portfolio.isGenderPublic ?? false;
    _isHeightPublic = portfolio.isHeightPublic ?? false;

    websiteUrlController.text = portfolio.websiteUrl ?? '';
    instagramUrlController.text = portfolio.instagramUrl ?? '';
    youtubeUrlController.text = portfolio.youtubeUrl ?? '';
    tiktokUrlController.text = portfolio.tiktokUrl ?? '';
    _publicScope = portfolio.publicScope ?? '전체공개';
    _isReceivingOffers = portfolio.isReceivingOffers ?? true;

    if (portfolio.attachedFileUrl != null) {
      attachedFileUrl = portfolio.attachedFileUrl;
      attachedFileName = portfolio.attachedFileUrl!.split('/').last;
    }

    if (portfolio.mainThumbnailUrl != null) {
      mainThumbnailSource = PortfolioImage(networkUrl: portfolio.mainThumbnailUrl);
    }
    if (portfolio.backgroundImageUrl != null) {
      backgroundImageSource = PortfolioImage(networkUrl: portfolio.backgroundImageUrl);
    }
    subThumbnailSources.clear();
    subThumbnailSources.addAll((portfolio.subThumbnailUrls ?? []).map((url) => PortfolioImage(networkUrl: url)));
    recentLiveControllers.clear();
    if (portfolio.recentLives != null && portfolio.recentLives!.isNotEmpty) {
      for (var live in portfolio.recentLives!) {
        final controllers = RecentLiveControllers();
        controllers.titleController.text = live.title;
        controllers.urlController.text = live.url;
        controllers.dateController.text = live.date;
        recentLiveControllers.add(controllers);
      }
    } else {
      addRecentLiveLink();
    }
  }

  // [수정] 부모 클래스의 추상 메소드인 onSave를 구현합니다.
  @override
  Future<void> onSave() async {
    String? finalAttachedFileUrl = attachedFileUrl;
    if (_tempAttachedFileBytes != null) {
      finalAttachedFileUrl = await _imageHandlerProvider.uploadImage(
        _tempAttachedFileBytes!,
        fileName: attachedFileName,
        type: 'raw',
      );
    }

    String? finalMainThumbUrl = mainThumbnailSource?.networkUrl;
    if (mainThumbnailSource?.localBytes != null) {
      finalMainThumbUrl = await _imageHandlerProvider.uploadImage(mainThumbnailSource!.localBytes!);
    }

    String? finalBackgroundUrl = backgroundImageSource?.networkUrl;
    if (backgroundImageSource?.localBytes != null) {
      finalBackgroundUrl = await _imageHandlerProvider.uploadImage(backgroundImageSource!.localBytes!);
    }

    final List<String> finalSubUrls = [];
    for (final source in subThumbnailSources) {
      if (source.localBytes != null) {
        final newUrl = await _imageHandlerProvider.uploadImage(source.localBytes!);
        if (newUrl != null) finalSubUrls.add(newUrl);
      } else if (source.networkUrl != null) {
        finalSubUrls.add(source.networkUrl!);
      }
    }

    String? genderPayload;
    if (_gender == '남성') {
      genderPayload = 'male';
    } else if (_gender == '여성') {
      genderPayload = 'female';
    }

    final Map<String, dynamic> payload = {
      'nickname': nicknameController.text,
      'oneLineIntro': oneLineIntroController.text,
      'detailedIntro': detailedIntroController.text,
      'experienceYears': int.tryParse(experienceYearsController.text),
      'age': int.tryParse(ageController.text),
      'isAgePublic': _isAgePublic,
      'region': regionController.text,
      'detailedRegion': detailedRegionController.text,
      'gender': genderPayload,
      'height': int.tryParse(heightController.text),
      'weight': int.tryParse(weightController.text),
      'topSize': topSizeController.text,
      'bottomSize': bottomSizeController.text,
      'shoeSize': int.tryParse(shoeSizeController.text),
      'isSizingPublic': _isSizingPublic,
      'isExperiencePublic': _isExperiencePublic,
      'isRegionPublic': _isRegionPublic,
      'isGenderPublic': _isGenderPublic,
      'isHeightPublic': _isHeightPublic,
      'websiteUrl': websiteUrlController.text,
      'instagramUrl': instagramUrlController.text,
      'youtubeUrl': youtubeUrlController.text,
      'tiktokUrl': tiktokUrlController.text,
      'publicScope': _publicScope,
      'isReceivingOffers': _isReceivingOffers,
      'mainThumbnailUrl': finalMainThumbUrl,
      'backgroundImageUrl': finalBackgroundUrl,
      'subThumbnailUrls': finalSubUrls,
      'recentLives': recentLiveControllers
          .map((c) => {'title': c.titleController.text, 'url': c.urlController.text, 'date': c.dateController.text})
          .where((item) => item['title']!.isNotEmpty || item['url']!.isNotEmpty || item['date']!.isNotEmpty)
          .toList(),
      'attachedFileUrl': finalAttachedFileUrl,
    };

    if (isEditing) {
      await _portfolioRepository.updatePortfolio(id!, payload);
    } else {
      await _portfolioRepository.createPortfolio(payload);
    }
  }

  @override
  void dispose() {
    nicknameController.dispose();
    oneLineIntroController.dispose();
    detailedIntroController.dispose();
    experienceYearsController.dispose();
    ageController.dispose();
    regionController.dispose();
    detailedRegionController.dispose();
    heightController.dispose();
    weightController.dispose();
    topSizeController.dispose();
    bottomSizeController.dispose();
    shoeSizeController.dispose();
    websiteUrlController.dispose();
    instagramUrlController.dispose();
    youtubeUrlController.dispose();
    tiktokUrlController.dispose();
    for (var controller in recentLiveControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
