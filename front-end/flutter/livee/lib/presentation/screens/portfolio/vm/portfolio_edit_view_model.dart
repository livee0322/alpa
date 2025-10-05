import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/presentation/screens/portfolio/models/portfolio_image.dart';
import 'package:livee/presentation/screens/portfolio/recent_live_controller.dart';
import 'package:livee/presentation/screens/portfolio/vm/profile_edit_view_model_base.dart';
import 'package:livee/presentation/common/custom_toast.dart';
import 'package:livee/service_locator.dart';
import 'package:universal_html/html.dart' as html;

// PortfolioEditScreen의 상태와 비즈니스 로직을 모두 관리하는 ViewModel
class PortfolioEditViewModel with ChangeNotifier implements ProfileEditViewModelBase {
  // --- 의존성 주입 및 초기화 ---
  final PortfolioRepository _portfolioRepository = locator<PortfolioRepository>();
  final ImageHandlerProvider _imageHandlerProvider = locator<ImageHandlerProvider>();
  final String? portfolioId;
  final BuildContext context;

  /// 생성자: ViewModel이 생성될 때 portfolioId를 받아와 데이터 로딩을 시작
  PortfolioEditViewModel(this.context, {this.portfolioId}) {
    _loadMyPortfolio();
  }

  // MARK: 상태 변수

  /// UI의 Form 위젯과 연결된 GlobalKey
  final formKey = GlobalKey<FormState>();

  /// 로딩 오버레이 표시 여부를 제어하는 변수
  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;
  bool get isEditing => portfolioId != null;

  /// 이미지 데이터 소스 (로컬 파일 또는 네트워크 URL)
  @override
  PortfolioImage? mainThumbnailSource;
  @override
  PortfolioImage? backgroundImageSource;
  @override
  final List<PortfolioImage> subThumbnailSources = [];

  /// 텍스트 입력 필드 컨트롤러
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

  // 선택 정보 컨트롤러
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

  // 링크 컨트롤러
  @override
  final websiteUrlController = TextEditingController();
  @override
  final instagramUrlController = TextEditingController();
  @override
  final youtubeUrlController = TextEditingController();
  @override
  final tiktokUrlController = TextEditingController();

  /// 드롭다운 및 체크박스 상태 변수
  String _publicScope = '전체공개';
  String? _gender;
  @override
  String? get gender => _gender;
  @override
  String get publicScope => _publicScope;
  bool _isReceivingOffers = true;
  @override
  bool get isReceivingOffers => _isReceivingOffers;

  // 각 필드별 공개 여부 상태 변수
  bool _isAgePublic = false;
  @override
  bool get isAgePublic => _isAgePublic;
  bool _isSizingPublic = false;
  @override
  bool get isSizingPublic => _isSizingPublic;
  bool _isExperiencePublic = false;
  @override
  bool get isExperiencePublic => _isExperiencePublic;
  bool _isRegionPublic = false;
  @override
  bool get isRegionPublic => _isRegionPublic;
  bool _isGenderPublic = false;
  @override
  bool get isGenderPublic => _isGenderPublic;
  bool _isHeightPublic = false;
  @override
  bool get isHeightPublic => _isHeightPublic;

  // 첨부 파일 관련 상태 변수
  @override
  String? attachedFileUrl;
  @override
  String? attachedFileName;

  /// 동적 입력 필드 (최근 라이브 링크, 태그)
  final List<RecentLiveControllers> recentLiveControllers = [];

  // 캐시된 새 파일 데이터를 임시 저장할 상태 변수
  Uint8List? _tempAttachedFileBytes;

  // MARK: 기능 함수

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

  /// 로딩 상태를 변경하고 UI에 알림(내부 전용)
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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

  /// '최근 라이브 링크' 입력 필드 한 줄을 추가하고 UI에 알림
  void addRecentLiveLink() {
    recentLiveControllers.add(RecentLiveControllers());
    notifyListeners();
  }

  /// 특정 '최근 라이브 링크' 입력 필드를 삭제하고 UI에 알림
  void removeRecentLiveLink(int index) {
    recentLiveControllers[index].dispose();
    recentLiveControllers.removeAt(index);
    notifyListeners();
  }

  @override
  void setGender(String? value) {
    if (value != null) {
      _gender = value == '선택 안함' ? null : value;
      notifyListeners();
    }
  }

  /// (수정 모드일 경우) 기존 포트폴리오 데이터를 서버에서 불러와 각 컨트롤러와 상태 변수에 채우기
  Future<void> _loadMyPortfolio() async {
    if (portfolioId == null) {
      addRecentLiveLink(); // 생성 모드일 경우 기본 입력 필드 하나만 추가
      return;
    }
    _setLoading(true);
    try {
      final portfolio = await _portfolioRepository.getPortfolioById(portfolioId!);
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
    } catch (e) {
      showCustomToast(context, '데이터를 불러오는 데 실패했습니다.', type: ToastType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// 입력된 모든 데이터를 취합하고, 서버에 저장/수정 요청을 보내기
  Future<void> savePortfolio() async {
    if (!formKey.currentState!.validate()) return;
    _setLoading(true);

    try {
      String? finalAttachedFileUrl = attachedFileUrl;
      if (_tempAttachedFileBytes != null) {
        // [수정] 파일 타입('raw')을 명시하여 업로드합니다.
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

      if (portfolioId == null) {
        await _portfolioRepository.createPortfolio(payload);
      } else {
        await _portfolioRepository.updatePortfolio(portfolioId!, payload);
      }

      showCustomToast(context, '포트폴리오가 성공적으로 저장되었습니다.', type: ToastType.success);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        html.window.history.go(-1);
      });
    } catch (e) {
      showCustomToast(context, '저장 실패: ${parseApiError(e)}', type: ToastType.error);
    } finally {
      _setLoading(false);
    }
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
