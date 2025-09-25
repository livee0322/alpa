import 'package:flutter/material.dart';
import 'package:livee/data/core/api_error_parser.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/domain/usecases/studio_use_case.dart';
import 'package:livee/presentation/screens/showhost/models/portfolio_image.dart';
import 'package:livee/presentation/screens/studio/models/day_schedule.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:livee/service_locator.dart';
import 'package:universal_html/html.dart' as html;

/// '스튜디오 등록' 페이지의 상태와 로직을 관리하는 ViewModel
class StudioEditViewModel with ChangeNotifier {
  // UseCase 의존성 주입
  final StudioUseCase _studioUseCase = locator<StudioUseCase>();
  final BuildContext context;

  // ViewModel 생성 시 context를 받도록 수정
  StudioEditViewModel(this.context);

  // --- 상태 변수 ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- 이미지 관련 상태 변수 ---
  PortfolioImage? mainThumbnailSource;
  PortfolioImage? backgroundImageSource;
  final List<PortfolioImage> subThumbnailSources = [];
  final List<PortfolioImage> galleryImageSources = [];

  // --- 텍스트 입력 필드 컨트롤러 ---
  final brandNameController = TextEditingController();
  final oneLineIntroController = TextEditingController();
  final detailedIntroController = TextEditingController();
  final usageInfoController = TextEditingController();
  final priceInfoController = TextEditingController();
  // 연락처 및 위치 정보 컨트롤러
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final kakaoController = TextEditingController();
  final addressController = TextEditingController();
  final mapUrlController = TextEditingController();

  Map<String, DaySchedule> weeklySchedule = {
    '월': DaySchedule(),
    '화': DaySchedule(),
    '수': DaySchedule(),
    '목': DaySchedule(),
    '금': DaySchedule(),
    '토': DaySchedule(isOpen: false),
    '일': DaySchedule(isOpen: false),
  };

  // --- 메소드 ---

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setMainThumbnail(PortfolioImage source) {
    mainThumbnailSource = source;
    notifyListeners();
  }

  void setBackgroundImage(PortfolioImage source) {
    backgroundImageSource = source;
    notifyListeners();
  }

  void addSubThumbnail(PortfolioImage source) {
    if (subThumbnailSources.length < 5) {
      subThumbnailSources.add(source);
      notifyListeners();
    }
  }

  void removeSubThumbnail(int index) {
    subThumbnailSources.removeAt(index);
    notifyListeners();
  }

  // 3x3 그리드 갤러리 이미지 추가
  void addGalleryImage(PortfolioImage source) {
    if (galleryImageSources.length < 9) {
      galleryImageSources.add(source);
      notifyListeners();
    }
  }

  // 3x3 그리드 갤러리 이미지 삭제
  void removeGalleryImage(int index) {
    galleryImageSources.removeAt(index);
    notifyListeners();
  }

  // 특정 요일의 영업 상태(토글)를 변경
  void setDayOpen(String day, bool isOpen) {
    if (weeklySchedule.containsKey(day)) {
      weeklySchedule[day]!.isOpen = isOpen;
      notifyListeners();
    }
  }

  // 특정 요일의 시작 시간을 변경
  void setStartTime(String day, String time) {
    if (weeklySchedule.containsKey(day)) {
      weeklySchedule[day]!.startTime = time;
      // 시작/종료 시간이 변경되면 기존 제외 시간은 초기화하는 것이 안전
      weeklySchedule[day]!.excludedTimes.clear();
      notifyListeners();
    }
  }

  // 특정 요일의 마감 시간을 변경
  void setEndTime(String day, String time) {
    if (weeklySchedule.containsKey(day)) {
      weeklySchedule[day]!.endTime = time;
      // 시작/종료 시간이 변경되면 기존 제외 시간은 초기화하는 것이 안전
      weeklySchedule[day]!.excludedTimes.clear();
      notifyListeners();
    }
  }

  // 특정 요일의 제외 시간을 업데이트
  void setExcludedTimes(String day, List<String> times) {
    if (weeklySchedule.containsKey(day)) {
      weeklySchedule[day]!.excludedTimes = times;
      notifyListeners();
    }
  }

  // 스튜디오 정보를 서버에 저장하는 핵심 로직
  Future<void> saveStudio() async {
    _setLoading(true);
    try {
      final uploader = CloudinaryUploader();

      // 모든 이미지를 Cloudinary에 업로드하고 URL을 받아오는 로직
      Future<String?> uploadImage(PortfolioImage? source) async {
        if (source?.localBytes != null) {
          return await uploader.uploadFile(source!.localBytes!);
        }
        return source?.networkUrl;
      }

      Future<List<String>> uploadImageList(List<PortfolioImage> sources) async {
        final List<String> urls = [];
        for (final source in sources) {
          final url = await uploadImage(source);
          if (url != null) urls.add(url);
        }
        return urls;
      }

      final mainThumbUrl = await uploadImage(mainThumbnailSource);
      final backgroundUrl = await uploadImage(backgroundImageSource);
      final subUrls = await uploadImageList(subThumbnailSources);
      final galleryUrls = await uploadImageList(galleryImageSources);

      // API 스키마에 맞게 Payload(전송 데이터) 구성
      final Map<String, dynamic> payload = {
        'brandName': brandNameController.text,
        'oneLineIntro': oneLineIntroController.text,
        'detailedIntro': detailedIntroController.text,
        'usageInfo': usageInfoController.text,
        'priceInfo': priceInfoController.text,
        'mainThumbnailUrl': mainThumbUrl,
        'backgroundImageUrl': backgroundUrl,
        'subThumbnailUrls': subUrls,
        'galleryUrls': galleryUrls,
        'contact': {
          'phone': phoneController.text,
          'email': emailController.text,
          'kakao': kakaoController.text,
        },
        'location': {
          'address': addressController.text,
          'mapUrl': mapUrlController.text,
        },
        'weeklySchedule': weeklySchedule.map(
          (key, value) => MapEntry(key, {
            'isOpen': value.isOpen,
            'startTime': value.startTime,
            'endTime': value.endTime,
            'excludedTimes': value.excludedTimes,
          }),
        ),
      };

      // UseCase를 통해 API 호출
      await _studioUseCase.createStudio(payload);

      showCustomToast(context, '스튜디오가 성공적으로 등록되었습니다.', type: ToastType.success);
      // 성공 시 이전 페이지로 이동
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

  @override
  void dispose() {
    brandNameController.dispose();
    oneLineIntroController.dispose();
    detailedIntroController.dispose();
    usageInfoController.dispose();
    priceInfoController.dispose();
    super.dispose();
  }
}
