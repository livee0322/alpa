import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/models/portfolio_image.dart';
import 'package:livee/presentation/screens/studio/models/day_schedule.dart';

/// '스튜디오 등록' 페이지의 상태와 로직을 관리하는 ViewModel
class StudioEditViewModel with ChangeNotifier {
  // --- 이미지 관련 상태 변수 ---
  PortfolioImage? mainThumbnailSource;
  PortfolioImage? backgroundImageSource;
  final List<PortfolioImage> subThumbnailSources = [];
  //  3x3 그리드 갤러리를 위한 새로운 이미지 목록
  final List<PortfolioImage> galleryImageSources = [];

  // --- 텍스트 입력 필드 컨트롤러 ---
  final brandNameController = TextEditingController();
  final oneLineIntroController = TextEditingController();
  final detailedIntroController = TextEditingController();
  final usageInfoController = TextEditingController();
  final priceInfoController = TextEditingController();

  // 요일별 스케줄을 관리하는 새로운 데이터 구조
  Map<String, DaySchedule> weeklySchedule = {
    '월': DaySchedule(),
    '화': DaySchedule(),
    '수': DaySchedule(),
    '목': DaySchedule(),
    '금': DaySchedule(),
    '토': DaySchedule(isOpen: false), // 기본값으로 토,일은 휴무처리
    '일': DaySchedule(isOpen: false),
  };

  // TODO: 연락처, 주소, 스케줄 관련 컨트롤러 및 상태 변수 추가

  // --- 메소드 ---
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
