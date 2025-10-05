import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/presentation/common/vm/form_view_model_base.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/service_locator.dart';

// 어떤 이미지를 선택할지 구분하기 위한 Enum
enum ImageType {
  cover,
  verticalCover,
  productThumbnail,
}

class CampaignFormViewModel extends FormViewModelBase {
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();
  final ImageHandlerProvider _imageHandlerProvider = locator<ImageHandlerProvider>();

  // 성자에서 부모 클래스의 생성자를 호출
  CampaignFormViewModel({
    required super.context,
    String? campaignId,
  }) : super(id: campaignId) {
    feeController.addListener(_updatePayWanPreview);
    startTimeController.addListener(_updateDuration);
    endTimeController.addListener(_updateDuration);
  }

  // --- 상태 변수 정의 ---
  Campaign? _editingCampaign;
  final List<String> _tags = [];

  // 드롭다운 선택 값을 관리할 상태 변수
  String? selectedPrefix;
  String? selectedCategory;

  // 선택한 이미지의 원본 데이터를 임시 저장할 변수
  Uint8List? tempCoverImageBytes;
  Uint8List? tempVerticalCoverImageBytes;
  Uint8List? tempProductThumbnailBytes;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController internalTitleController = TextEditingController();
  final TextEditingController coverImageUrlController = TextEditingController();
  final TextEditingController prefixController = TextEditingController();
  final TextEditingController liveVerticalCoverUrlController = TextEditingController();
  final TextEditingController liveStreamUrlController = TextEditingController();
  final TextEditingController shootDateController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController contentController = TextEditingController(); // descController -> contentController
  final TextEditingController productThumbnailUrlController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController campaignProductUrlController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController durationHoursController = TextEditingController();

  // 계산된 값을 위한 상태 변수
  String _payWanPreview = '';
  String _durationText = '촬영시간: -';

  bool payNegotiable = false;

  // --- Getter ---
  Campaign? get editingCampaign => _editingCampaign;
  String get payWanPreview => _payWanPreview;
  String get durationText => _durationText;
  List<String> get tags => _tags;

  // --- 상태 변경 메소드 ---

  // [추가] 이미지 데이터를 설정하고 UI를 갱신하는 공개 메소드들을 추가합니다.
  void setCoverImageBytes(Uint8List bytes) {
    tempCoverImageBytes = bytes;
    coverImageUrlController.clear();
    notifyListeners();
  }

  void setVerticalCoverImageBytes(Uint8List bytes) {
    tempVerticalCoverImageBytes = bytes;
    liveVerticalCoverUrlController.clear();
    notifyListeners();
  }

  void setProductThumbnailBytes(Uint8List bytes) {
    tempProductThumbnailBytes = bytes;
    productThumbnailUrlController.clear();
    notifyListeners();
  }

  // 드롭다운 값 변경 메소드
  void setPrefix(String? value) {
    selectedPrefix = value == '선택 안 함' ? null : value;
    prefixController.text = selectedPrefix ?? '';
    notifyListeners();
  }

  void setCategory(String? value) {
    selectedCategory = value == '선택' ? null : value;
    categoryController.text = selectedCategory ?? '';
    notifyListeners();
  }

  void setPayNegotiable(bool value) {
    payNegotiable = value;
    notifyListeners();
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && _tags.length < 5 && !_tags.contains(tag)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  void _updatePayWanPreview() {
    final number = int.tryParse(feeController.text);
    if (number != null && number > 0) {
      final formatter = NumberFormat('#,###');
      _payWanPreview = '${formatter.format(number)}원';
    } else {
      _payWanPreview = '';
    }
    notifyListeners();
  }

  void _updateDuration() {
    TimeOfDay? parseTime(String timeText) {
      try {
        final format = DateFormat("h:mm a"); // "HH:mm" 또는 "h:mm a" 등 형식에 맞게 수정
        final time = format.parse(timeText);
        return TimeOfDay.fromDateTime(time);
      } catch (e) {
        try {
          final parts = timeText.split(':');
          if (parts.length == 2) {
            return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    final startTime = parseTime(startTimeController.text);
    final endTime = parseTime(endTimeController.text);

    if (startTime != null && endTime != null) {
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;
      if (endMinutes > startMinutes) {
        final durationMinutes = endMinutes - startMinutes;
        final hours = durationMinutes ~/ 60;
        final minutes = durationMinutes % 60;
        durationHoursController.text = (durationMinutes / 60).toStringAsFixed(1);
        _durationText = '촬영시간: ${hours > 0 ? '$hours시간 ' : ''}${minutes > 0 ? '$minutes분' : ''}';
      } else {
        _durationText = '촬영시간: 종료시간은 시작시간 이후여야 합니다.';
      }
    } else {
      _durationText = '촬영시간: -';
    }
    notifyListeners();
  }

  // 수정 모드 시, 새로운 스키마에 맞춰 컨트롤러를 채우도록 수정
  @override
  Future<void> loadDataForEdit() async {
    final campaign = await _campaignUseCase.getCampaignById(id!);
    _editingCampaign = campaign;

    // 공통 필드 및 새로운 필드 채우기
    titleController.text = campaign.title ?? '';
    brandController.text = campaign.brandName ?? '';
    internalTitleController.text = campaign.internalTitle ?? '';
    coverImageUrlController.text = campaign.coverImageUrl ?? '';
    prefixController.text = campaign.prefix ?? '';
    liveVerticalCoverUrlController.text = campaign.liveVerticalCoverUrl ?? '';
    liveStreamUrlController.text = campaign.liveStreamUrl ?? '';
    shootDateController.text = campaign.shootDate != null ? DateFormat('yyyy-MM-dd').format(campaign.shootDate!) : '';
    deadlineController.text = campaign.closeAt != null ? DateFormat('yyyy-MM-dd').format(campaign.closeAt!) : '';
    startTimeController.text = campaign.startTime ?? '';
    endTimeController.text = campaign.endTime ?? '';
    durationHoursController.text = campaign.durationHours?.toString() ?? '';
    categoryController.text = campaign.category ?? '';
    contentController.text = campaign.content ?? ''; // descriptionHTML -> content
    locationController.text = campaign.location ?? '';
    feeController.text = campaign.fee?.toString() ?? '';
    payNegotiable = campaign.feeNegotiable ?? false;
    productThumbnailUrlController.text = campaign.productThumbnailUrl ?? '';
    productNameController.text = campaign.productName ?? '';
    campaignProductUrlController.text = campaign.productUrl ?? '';

    selectedPrefix = campaign.prefix;
    selectedCategory = campaign.category;

    _updateDuration();
    _updatePayWanPreview();
  }

  // API Payload를 새로운 명세에 맞춰 재구성
  @override
  Future<void> onSave() async {
    final coverImageUrl = await _imageHandlerProvider.uploadImage(tempCoverImageBytes!) ?? coverImageUrlController.text;
    final verticalCoverUrl =
        await _imageHandlerProvider.uploadImage(tempVerticalCoverImageBytes!) ?? liveVerticalCoverUrlController.text;
    final productThumbUrl =
        await _imageHandlerProvider.uploadImage(tempProductThumbnailBytes!) ?? productThumbnailUrlController.text;

    // 날짜 문자열을 ISO 8601 형식으로 변환하는 헬퍼 함수
    String? toIso8601String(String dateStr) {
      if (dateStr.isEmpty) return null;
      try {
        return DateTime.parse(dateStr).toUtc().toIso8601String();
      } catch (e) {
        return null; // 파싱 실패 시 null 반환
      }
    }

    final Map<String, dynamic> payload = {
      'brandName': brandController.text,
      'title': titleController.text,
      'shootDate': toIso8601String(shootDateController.text),
      'closeAt': toIso8601String(deadlineController.text),
      'durationHours': double.tryParse(durationHoursController.text),
      'startTime': startTimeController.text,
      'endTime': endTimeController.text,
      'prefix': prefixController.text.isEmpty ? null : prefixController.text,
      'content': contentController.text.isEmpty ? null : contentController.text,
      'category': categoryController.text.isEmpty ? null : categoryController.text,
      'location': locationController.text.isEmpty ? null : locationController.text,
      'fee': int.tryParse(feeController.text),
      'feeNegotiable': payNegotiable,
      'coverImageUrl': coverImageUrl.isEmpty ? null : coverImageUrl,
      'liveVerticalCoverUrl': verticalCoverUrl.isEmpty ? null : verticalCoverUrl,
      'liveStreamUrl': liveStreamUrlController.text.isEmpty ? null : liveStreamUrlController.text,
      'productThumbnailUrl': productThumbUrl.isEmpty ? null : productThumbUrl,
      'productName': productNameController.text.isEmpty ? null : productNameController.text,
      'productUrl': campaignProductUrlController.text.isEmpty ? null : campaignProductUrlController.text,
    };

    if (isEditing) {
      await _campaignUseCase.updateCampaign(id!, payload);
    } else {
      await _campaignUseCase.createCampaign(payload);
    }
  }

  @override
  void dispose() {
    // 모든 컨트롤러를 dispose합니다.
    titleController.dispose();
    internalTitleController.dispose();
    coverImageUrlController.dispose();
    prefixController.dispose();
    liveVerticalCoverUrlController.dispose();
    liveStreamUrlController.dispose();
    shootDateController.dispose();
    deadlineController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    brandController.dispose();
    categoryController.dispose();
    contentController.dispose();
    productThumbnailUrlController.dispose();
    productNameController.dispose();
    campaignProductUrlController.dispose();
    locationController.dispose();
    feeController.dispose();
    durationHoursController.dispose();
    super.dispose();
  }
}
