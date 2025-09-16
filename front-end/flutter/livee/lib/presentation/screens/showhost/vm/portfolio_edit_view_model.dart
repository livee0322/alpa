import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/domain/repositories/portfolio_repository.dart';
import 'package:livee/presentation/screens/showhost/models/portfolio_image.dart';
import 'package:livee/presentation/screens/showhost/recent_live_controller.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:livee/service_locator.dart';
import 'package:universal_html/html.dart' as html;

// PortfolioEditScreen의 상태와 비즈니스 로직을 모두 관리하는 ViewModel
class PortfolioEditViewModel with ChangeNotifier {
  // --- 의존성 주입 및 초기화 ---
  final PortfolioRepository _portfolioRepository =
      locator<PortfolioRepository>();
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
  bool get isLoading => _isLoading;
  bool get isEditing => portfolioId != null;

  /// 이미지 데이터 소스 (로컬 파일 또는 네트워크 URL)
  PortfolioImage? mainThumbnailSource;
  PortfolioImage? backgroundImageSource;
  final List<PortfolioImage> subThumbnailSources = [];

  /// 텍스트 입력 필드 컨트롤러
  final nicknameController = TextEditingController();
  final oneLineIntroController = TextEditingController();
  final detailedIntroController = TextEditingController();
  final experienceYearsController = TextEditingController();
  final ageController = TextEditingController();
  final mainLinkController = TextEditingController(); // (구) 대표링크
  final tagController = TextEditingController();

  // 선택 정보 컨트롤러
  final regionController = TextEditingController();
  final detailedRegionController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final topSizeController = TextEditingController();
  final bottomSizeController = TextEditingController();
  final shoeSizeController = TextEditingController();

  // 링크 컨트롤러
  final websiteUrlController = TextEditingController();
  final instagramUrlController = TextEditingController();
  final youtubeUrlController = TextEditingController();
  final tiktokUrlController = TextEditingController();

  /// 드롭다운 및 체크박스 상태 변수
  String _publicScope = '전체공개';
  String? _gender;
  String? get gender => _gender;
  String get publicScope => _publicScope;
  bool _isReceivingOffers = true;
  bool get isReceivingOffers => _isReceivingOffers;

  // 각 필드별 공개 여부 상태 변수
  bool _isAgePublic = false;
  bool get isAgePublic => _isAgePublic;
  bool _isSizingPublic = false;
  bool get isSizingPublic => _isSizingPublic;
  bool _isExperiencePublic = false;
  bool get isExperiencePublic => _isExperiencePublic;
  bool _isRegionPublic = false;
  bool get isRegionPublic => _isRegionPublic;
  bool _isGenderPublic = false;
  bool get isGenderPublic => _isGenderPublic;
  bool _isHeightPublic = false;
  bool get isHeightPublic => _isHeightPublic;

  /// 동적 입력 필드 (최근 라이브 링크, 태그)
  final List<RecentLiveControllers> recentLiveControllers = [];
  final List<String> tags = [];

  // MARK: 기능 함수

  // 서브 썸네일 이미지를 삭제하는 메소드
  void removeSubThumbnail(int index) {
    subThumbnailSources.removeAt(index);
    notifyListeners();
  }

  void setIsAgePublic(bool? value) {
    _isAgePublic = value ?? false;
    notifyListeners();
  }

  void setIsSizingPublic(bool? value) {
    _isSizingPublic = value ?? false;
    notifyListeners();
  }

  // [추가] 새로운 setter 메소드들
  void setIsExperiencePublic(bool? value) {
    _isExperiencePublic = value ?? false;
    notifyListeners();
  }

  void setIsRegionPublic(bool? value) {
    _isRegionPublic = value ?? false;
    notifyListeners();
  }

  void setIsGenderPublic(bool? value) {
    _isGenderPublic = value ?? false;
    notifyListeners();
  }

  void setIsHeightPublic(bool? value) {
    _isHeightPublic = value ?? false;
    notifyListeners();
  }

  /// 로딩 상태를 변경하고 UI에 알림(내부 전용)
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// '공개 범위' 드롭다운 선택 값을 업데이트하고 UI에 알림
  void setPublicScope(String? value) {
    if (value != null) {
      _publicScope = value;
      notifyListeners();
    }
  }

  /// '제안 받기' 체크박스 값을 업데이트하고 UI에 알림
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

  /// 입력된 태그를 태그 목록에 추가하고 UI에 알림
  void addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagController.clear();
      notifyListeners();
    }
  }

  // [추가] 성별 상태 변경 메소드 (오류 해결의 핵심)
  void setGender(String? value) {
    if (value != null) {
      // '선택 안함'을 선택하면 null로 저장하여 서버 요구사항에 맞춤
      _gender = value == '선택 안함' ? null : value;
      notifyListeners();
    }
  }

  /// 특정 태그를 목록에서 삭제하고 UI에 알림
  void removeTag(String tag) {
    tags.remove(tag);
    notifyListeners();
  }

  /// 갤러리에서 이미지를 선택하고, 선택된 이미지 데이터를 콜백으로 전달
  Future<void> pickImage({
    required Function(PortfolioImage) onImageSelected,
  }) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    onImageSelected(PortfolioImage(localBytes: bytes));
    notifyListeners();
  }

  /// (수정 모드일 경우) 기존 포트폴리오 데이터를 서버에서 불러와 각 컨트롤러와 상태 변수에 채우기
  Future<void> _loadMyPortfolio() async {
    if (portfolioId == null) {
      addRecentLiveLink(); // 생성 모드일 경우 기본 입력 필드 하나만 추가
      return;
    }
    _setLoading(true);
    try {
      final portfolio =
          await _portfolioRepository.getPortfolioById(portfolioId!);
      // 각 컨트롤러에 데이터 채우기
      // 기본 정보
      nicknameController.text = portfolio.nickname ?? '';
      oneLineIntroController.text = portfolio.oneLineIntro ?? '';
      detailedIntroController.text = portfolio.detailedIntro ?? '';
      experienceYearsController.text =
          portfolio.experienceYears?.toString() ?? '';
      ageController.text = portfolio.age?.toString() ?? '';
      _isAgePublic = portfolio.isAgePublic ?? false;

      // 선택 정보
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

      // 링크 및 공개 설정
      websiteUrlController.text = portfolio.websiteUrl ?? '';
      instagramUrlController.text = portfolio.instagramUrl ?? '';
      youtubeUrlController.text = portfolio.youtubeUrl ?? '';
      tiktokUrlController.text = portfolio.tiktokUrl ?? '';
      _publicScope = portfolio.publicScope ?? '전체공개';
      _isReceivingOffers = portfolio.isReceivingOffers ?? true;

      // 이미지 및 동적 필드 데이터 채우기
      if (portfolio.mainThumbnailUrl != null) {
        mainThumbnailSource =
            PortfolioImage(networkUrl: portfolio.mainThumbnailUrl);
      }
      if (portfolio.backgroundImageUrl != null) {
        backgroundImageSource =
            PortfolioImage(networkUrl: portfolio.backgroundImageUrl);
      }
      subThumbnailSources.clear();
      subThumbnailSources.addAll((portfolio.subThumbnailUrls ?? [])
          .map((url) => PortfolioImage(networkUrl: url)));
      tags.clear();
      tags.addAll(portfolio.tags ?? []);
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

  /// 입력된 모든 데이터를 취합하고, '발행' 또는 '임시저장' 상태로 서버에 저장/수정 요청을 보내기
  Future<void> savePortfolio(String status) async {
    if (!formKey.currentState!.validate()) return;
    _setLoading(true);

    try {
      final uploader = CloudinaryUploader();

      // --- 지연된 이미지 업로드 처리 ---
      String? finalMainThumbUrl = mainThumbnailSource?.networkUrl;
      if (mainThumbnailSource?.localBytes != null) {
        finalMainThumbUrl =
            await uploader.uploadImage(mainThumbnailSource!.localBytes!);
      }

      String? finalBackgroundUrl = backgroundImageSource?.networkUrl;
      if (backgroundImageSource?.localBytes != null) {
        finalBackgroundUrl =
            await uploader.uploadImage(backgroundImageSource!.localBytes!);
      }

      final List<String> finalSubUrls = [];
      for (final source in subThumbnailSources) {
        if (source.localBytes != null) {
          final newUrl = await uploader.uploadImage(source.localBytes!);
          finalSubUrls.add(newUrl);
        } else if (source.networkUrl != null) {
          finalSubUrls.add(source.networkUrl!);
        }
      }

      // --- 최종 데이터 취합 ---
      final Map<String, dynamic> payload = {
        // 기본 정보
        'nickname': nicknameController.text,
        'oneLineIntro': oneLineIntroController.text,
        'detailedIntro': detailedIntroController.text,
        'experienceYears': int.tryParse(experienceYearsController.text),
        'age': int.tryParse(ageController.text),
        'isAgePublic': _isAgePublic,
        // 선택 정보
        'region': regionController.text,
        'detailedRegion': detailedRegionController.text,
        'gender': _gender,
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
        // 링크 및 공개 설정
        'websiteUrl': websiteUrlController.text,
        'instagramUrl': instagramUrlController.text,
        'youtubeUrl': youtubeUrlController.text,
        'tiktokUrl': tiktokUrlController.text,
        'publicScope': _publicScope,
        'isReceivingOffers': _isReceivingOffers,
        // 기타 정보
        'mainThumbnailUrl': finalMainThumbUrl,
        'backgroundImageUrl': finalBackgroundUrl,
        'subThumbnailUrls': finalSubUrls,
        'tags': tags,
        'recentLives': recentLiveControllers
            .map((c) => {
                  'title': c.titleController.text,
                  'url': c.urlController.text,
                  'date': c.dateController.text
                })
            .where((item) =>
                item['title']!.isNotEmpty ||
                item['url']!.isNotEmpty ||
                item['date']!.isNotEmpty)
            .toList(),
        'status': status,
      };

      // --- API 호출 ---
      if (portfolioId == null) {
        await _portfolioRepository.createPortfolio(payload);
      } else {
        await _portfolioRepository.updatePortfolio(portfolioId!, payload);
      }

      // --- 후처리 ---
      showCustomToast(
          context, '포트폴리오가 성공적으로 ${status == 'draft' ? '저장' : '발행'}되었습니다.',
          type: ToastType.success);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        html.window.history.go(-1);
      });
    } catch (e) {
      showCustomToast(context, '저장 실패: ${parseApiError(e)}',
          type: ToastType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// ViewModel이 소멸될 때 모든 컨트롤러의 리소스를 해제
  @override
  void dispose() {
    nicknameController.dispose();
    oneLineIntroController.dispose();
    detailedIntroController.dispose();
    experienceYearsController.dispose();
    ageController.dispose();
    mainLinkController.dispose();
    tagController.dispose();
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
