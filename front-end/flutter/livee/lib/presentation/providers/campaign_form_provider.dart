// lib/presentation/providers/campaign_form_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/product.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';

class CampaignFormProvider with ChangeNotifier {
  final CampaignUseCase _campaignUseCase;
  final ApiClient _apiClient;

  // 컨트롤러 리스너를 추가, 실시간 UI 업데이트 로직 설정
  CampaignFormProvider(
    this._campaignUseCase,
    this._apiClient,
  ) {
    payWanController.addListener(_updatePayWanPreview);
    timeStartController.addListener(_updateDuration);
    timeEndController.addListener(_updateDuration);
  }

  // --- 상태 변수 정의 ---

  String _campaignType = 'product';
  bool _isLoading = false;
  String? _editCampaignId;
  Campaign? _editingCampaign;

  // [추가] 태그 리스트를 관리할 상태 변수
  List<String> _tags = [];

  // 공통 필드
  final TextEditingController internalTitleController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  // 상품 캠페인 필드
  final TextEditingController titleController = TextEditingController();
  final TextEditingController productUrlController = TextEditingController();
  List<Product> _products = [];
  final TextEditingController salePriceController = TextEditingController();
  String? saleDuration;
  final TextEditingController liveDateController = TextEditingController();
  final TextEditingController liveTimeController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // 쇼호스트 모집 필드
  final TextEditingController titleRecruitController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController timeStartController = TextEditingController();
  final TextEditingController timeEndController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController payWanController = TextEditingController();
  bool payNegotiable = false;
  final TextEditingController categoryRecruitController = TextEditingController();
  final TextEditingController descRecruitController = TextEditingController();

  // 계산된 값을 위한 상태 변수
  String _payWanPreview = ''; // 출연료 미리보기 (예: "30만원")
  String _durationText = '촬영시간: -'; // 촬영 시간 계산 결과

  // --- Getter: 외부에서 상태 값을 안전하게 읽을 수 있도록 ---
  String get campaignType => _campaignType;
  bool get isLoading => _isLoading;
  List<Product> get products => _products;
  Campaign? get editingCampaign => _editingCampaign;
  String get payWanPreview => _payWanPreview;
  String get durationText => _durationText;
  // [추가] 외부에서 태그 리스트를 안전하게 읽기 위한 Getter
  List<String> get tags => _tags;

  // --- 상태 변경 메소드 ---

  void setCampaignType(String type) {
    if (_campaignType != type) {
      _campaignType = type;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setPayNegotiable(bool value) {
    payNegotiable = value;
    notifyListeners();
  }

  void setSaleDuration(String? duration) {
    saleDuration = duration;
    notifyListeners();
  }

  // [추가] 태그 추가 메소드
  void addTag(String tag) {
    if (tag.isNotEmpty && _tags.length < 5 && !_tags.contains(tag)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  // [추가] 태그 삭제 메소드
  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  // payWanController의 값이 변경될 때마다 미리보기 텍스트 업데이트
  void _updatePayWanPreview() {
    final number = int.tryParse(payWanController.text);
    if (number != null && number > 0) {
      final formatter = NumberFormat('#,###');
      _payWanPreview = '${formatter.format(number)}만원';
    } else {
      _payWanPreview = '';
    }
    notifyListeners();
  }

  // 촬영 시작/종료 시간이 변경될 때마다 총 촬영 시간을 계산하여 업데이트
  void _updateDuration() {
    // 입력된 시간 문자열을 TimeOfDay 객체로 파싱 시도
    TimeOfDay? parseTime(String timeText) {
      try {
        final parts = timeText.split(':');
        if (parts.length == 2) {
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      } catch (e) {
        return null;
      }
      return null;
    }

    final startTime = parseTime(timeStartController.text);
    final endTime = parseTime(timeEndController.text);

    if (startTime != null && endTime != null) {
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;
      if (endMinutes > startMinutes) {
        _durationText = '촬영시간: ${endMinutes - startMinutes}분';
      } else {
        _durationText = '촬영시간: 종료시간은 시작시간 이후여야 합니다.';
      }
    } else {
      _durationText = '촬영시간: -';
    }
    notifyListeners();
  }

  // 수정 모드 시, 서버에서 받은 데이터로 모든 컨트롤러를 채우기
  Future<void> loadCampaignForEdit(String id) async {
    setLoading(true);
    _editCampaignId = id;
    try {
      final campaign = await _campaignUseCase.getCampaignById(id);
      _editingCampaign = campaign;
      setCampaignType(campaign.type ?? 'product');

      // 공통 필드 채우기
      // TODO: API 응답 및 Campaign 모델에 internalTitle 필드 추가 필요
      // internalTitleController.text = campaign.internalTitle ?? '';
      imageUrlController.text = campaign.coverImageUrl ?? '';

      if (campaign.type == 'product') {
        titleController.text = campaign.title ?? '';
        _products = campaign.products ?? [];
        // ... (기타 상품 관련 필드 채우기 로직)
      } else if (campaign.type == 'recruit') {
        final recruit = campaign.recruit;
        titleRecruitController.text = recruit?.title ?? '';
        dateController.text = recruit?.date?.substring(0, 10) ?? '';
        // TODO: API 응답 및 Recruit 모델에 deadline 필드 추가 필요
        // deadlineController.text = recruit.deadline?.substring(0, 10) ?? '';
        timeStartController.text = recruit?.timeStart ?? '';
        timeEndController.text = recruit?.timeEnd ?? '';
        locationController.text = recruit?.location ?? '';
        // '30만원' 같은 문자열에서 숫자만 추출하여 payWanController에 설정
        payWanController.text = recruit?.pay?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
        payNegotiable = recruit?.payNegotiable ?? false;
        categoryRecruitController.text = recruit?.category ?? '';
        descRecruitController.text = recruit?.description ?? '';

        // 로드 후 계산 함수를 호출하여 미리보기 UI를 업데이트
        _updateDuration();
        _updatePayWanPreview();
      }
    } catch (e) {
      debugPrint('Error loading campaign for edit: $e');
      // TODO: 사용자에게 에러 알림
    } finally {
      setLoading(false);
    }
  }

  // 상품 URL로부터 정보를 가져와 목록에 추가
  Future<void> addProductFromUrl(String url) async {
    try {
      final response = await _apiClient.get('/scrape/product?url=${Uri.encodeComponent(url)}');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes))['data'] ?? jsonDecode(utf8.decode(response.bodyBytes));
        _products.add(Product.fromJson(data));
        notifyListeners();
      } else {
        throw Exception('상품 정보를 가져오지 못했습니다.');
      }
    } catch (e) {
      debugPrint('Error scraping product: $e');
      rethrow;
    }
  }

  void removeProduct(int index) {
    _products.removeAt(index);
    notifyListeners();
  }

  // [수정] 폼 데이터를 API 서버에 전송하는 메소드
  Future<void> submitForm() async {
    setLoading(true);
    try {
      Map<String, dynamic> payload;
      if (_campaignType == 'product') {
        payload = {
          'type': 'product',
          'internalTitle': internalTitleController.text.isEmpty ? null : internalTitleController.text,
          'title': titleController.text,
          'coverImageUrl': imageUrlController.text.isEmpty ? null : imageUrlController.text,
          'products': _products.map((p) => {/* ... */}).toList(),
          // ... (기타 상품 페이로드)
        };
      } else {
        // 쇼호스트 모집 캠페인
        payload = {
          'type': 'recruit',
          'title': titleRecruitController.text, // 공고 제목
          'internalTitle': internalTitleController.text.isEmpty ? null : internalTitleController.text,
          'coverImageUrl': imageUrlController.text.isEmpty ? null : imageUrlController.text,
          'brand': brandController.text.isEmpty ? null : brandController.text,
          // API 명세에 맞게 'recruit' 객체 구조 수정
          'recruit': {
            'title': titleRecruitController.text,
            'shootDate': dateController.text.isEmpty ? null : dateController.text, // 필드명 변경: date -> shootDate
            'applyDeadline':
                deadlineController.text.isEmpty ? null : deadlineController.text, // 필드명 변경: deadline -> applyDeadline
            'startAt':
                timeStartController.text.isEmpty ? null : timeStartController.text, // 필드명 변경: timeStart -> startAt
            'endAt': timeEndController.text.isEmpty ? null : timeEndController.text, // 필드명 변경: timeEnd -> endAt
            'location': locationController.text.isEmpty ? null : locationController.text,
            'fee': int.tryParse(payWanController.text), // 숫자 타입으로 전송
            'isNegotiable': payNegotiable, // 필드명 변경: payNegotiable -> isNegotiable
            'tags': _tags, // 태그 리스트 추가
            'category': categoryRecruitController.text.isEmpty ? null : categoryRecruitController.text,
            'description': descRecruitController.text.isEmpty ? null : descRecruitController.text,
          }
        };
      }

      if (_editCampaignId != null) {
        await _campaignUseCase.updateCampaign(_editCampaignId!, payload);
      } else {
        await _campaignUseCase.createCampaign(payload);
      }
    } catch (e) {
      debugPrint('Form submission failed: $e');
      // 서버 에러 코드를 확인하는 로직
      try {
        // Repository에서 전달된 Exception 메시지(JSON 문자열)를 파싱
        final errorJson = jsonDecode(e.toString().replaceFirst('Exception: ', ''));
        // "COVER_IMAGE_REQUIRED" 코드인지 확인
        if (errorJson['code'] == 'COVER_IMAGE_REQUIRED') {
          // 사용자에게 보여줄 메시지로 새로운 Exception을 발생시킴
          throw Exception('커버 이미지를 등록해주세요.');
        } else {
          // 그 외 서버 에러는 서버가 보내준 메시지를 사용
          throw Exception(errorJson['message'] ?? '알 수 없는 서버 오류가 발생했습니다.');
        }
      } catch (parseError) {
        // JSON 파싱에 실패하면 원래 에러를 그대로 전달
        rethrow;
      }
    } finally {
      setLoading(false);
    }
  }

  // 위젯이 제거될 때 컨트롤러의 리소스를 해제하여 메모리 누수를 방지
  @override
  void dispose() {
    internalTitleController.dispose();
    imageUrlController.dispose();
    titleController.dispose();
    productUrlController.dispose();
    salePriceController.dispose();
    liveDateController.dispose();
    liveTimeController.dispose();
    brandController.dispose();
    categoryController.dispose();
    descController.dispose();
    titleRecruitController.dispose();
    dateController.dispose();
    deadlineController.dispose();
    timeStartController.dispose();
    timeEndController.dispose();
    locationController.dispose();
    payWanController.dispose();
    categoryRecruitController.dispose();
    descRecruitController.dispose();
    super.dispose();
  }
}
