import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/product.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/service_locator.dart';

class CampaignFormViewModel with ChangeNotifier {
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();
  final ApiClient _apiClient = locator<ApiClient>();

  CampaignFormViewModel() {
    feeController.addListener(_updatePayWanPreview);
    startTimeController.addListener(_updateDuration);
    endTimeController.addListener(_updateDuration);
  }

  // --- 상태 변수 정의 ---
  String _campaignType = 'product';
  bool _isLoading = false;
  String? _editCampaignId;
  Campaign? _editingCampaign;
  List<String> _tags = [];

  // 공통 필드
  final TextEditingController internalTitleController = TextEditingController();
  final TextEditingController coverImageUrlController = TextEditingController();
  final TextEditingController prefixController = TextEditingController(); // 말머리
  final TextEditingController liveVerticalCoverUrlController = TextEditingController(); // 세로 커버 이미지
  final TextEditingController liveStreamUrlController = TextEditingController(); // 라이브 스트리밍 URL

  // 상품 캠페인 필드
  final TextEditingController titleController = TextEditingController();
  final TextEditingController productUrlController = TextEditingController(); // 상품 스크래핑용 URL
  List<Product> _products = [];
  final TextEditingController salePriceController = TextEditingController();
  String? saleDuration;
  final TextEditingController liveDateController = TextEditingController(); // 라이브 날짜 (YYYY-MM-DD)
  final TextEditingController startTimeController = TextEditingController(); // 시작 시간 (HH:MM)
  final TextEditingController endTimeController = TextEditingController(); // 종료 시간 (HH:MM)
  final TextEditingController brandController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController productThumbnailUrlController = TextEditingController(); // 대표 상품 정보 필드
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController campaignProductUrlController = TextEditingController(); // 대표 상품 URL

  // 쇼호스트 모집 필드
  final TextEditingController titleRecruitController = TextEditingController();
  final TextEditingController shootDateController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  bool payNegotiable = false;
  final TextEditingController categoryRecruitController = TextEditingController();
  final TextEditingController descRecruitController = TextEditingController();
  final TextEditingController durationInHoursController = TextEditingController();

  // 계산된 값을 위한 상태 변수
  String _payWanPreview = '';
  String _durationText = '촬영시간: -';

  // --- Getter ---
  String get campaignType => _campaignType;
  bool get isLoading => _isLoading;
  List<Product> get products => _products;
  Campaign? get editingCampaign => _editingCampaign;
  String get payWanPreview => _payWanPreview;
  String get durationText => _durationText;
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
        // [수정] durationInHoursController에도 값을 채워줍니다.
        durationInHoursController.text = (durationMinutes / 60).toStringAsFixed(1);
        _durationText = '촬영시간: ${hours > 0 ? '$hours시간 ' : ''}${minutes > 0 ? '$minutes분' : ''}';
      } else {
        _durationText = '촬영시간: 종료시간은 시작시간 이후여야 합니다.';
      }
    } else {
      _durationText = '촬영시간: -';
    }
    notifyListeners();
  }

  // [수정] 수정 모드 시, 새로운 스키마에 맞춰 컨트롤러를 채우도록 수정
  Future<void> loadCampaignForEdit(String id) async {
    setLoading(true);
    _editCampaignId = id;
    try {
      final campaign = await _campaignUseCase.getCampaignById(id);
      _editingCampaign = campaign;
      setCampaignType(campaign.type ?? 'product');

      // 공통 필드
      internalTitleController.text = campaign.internalTitle ?? '';
      coverImageUrlController.text = campaign.coverImageUrl ?? '';
      prefixController.text = campaign.prefix ?? '';
      liveVerticalCoverUrlController.text = campaign.liveVerticalCoverUrl ?? '';
      liveStreamUrlController.text = campaign.liveStreamUrl ?? '';

      if (campaign.type == 'product') {
        titleController.text = campaign.title ?? '';
        _products = campaign.products ?? [];
        startTimeController.text = campaign.startTime ?? '';
        endTimeController.text = campaign.endTime ?? '';
        brandController.text = campaign.brand ?? '';
        categoryController.text = campaign.category ?? '';
        descController.text = campaign.descriptionHTML ?? '';
        productThumbnailUrlController.text = campaign.productThumbnailUrl ?? '';
        productNameController.text = campaign.productName ?? '';
        campaignProductUrlController.text = campaign.productUrl ?? '';
        // salePrice, saleDuration 등은 예시로 생략, 필요시 추가
      } else if (campaign.type == 'recruit') {
        titleRecruitController.text = campaign.title ?? '';
        shootDateController.text =
            campaign.shootDate != null ? DateFormat('yyyy-MM-dd').format(campaign.shootDate!) : '';
        deadlineController.text = campaign.closeAt?.substring(0, 10) ?? '';
        startTimeController.text = campaign.startTime ?? '';
        endTimeController.text = campaign.endTime ?? '';
        locationController.text = campaign.location ?? '';
        feeController.text = campaign.fee?.toString() ?? '';
        payNegotiable = campaign.feeNegotiable ?? false;
        categoryRecruitController.text = campaign.category ?? '';
        descRecruitController.text = campaign.descriptionHTML ?? '';
        durationInHoursController.text = campaign.recruit?.durationInHours?.toString() ?? '';
        _tags = campaign.recruit?.questions ?? []; // 임시로 questions를 태그로 사용
      }
      _updateDuration();
      _updatePayWanPreview();
    } catch (e) {
      debugPrint('Error loading campaign for edit: $e');
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

  // [수정] API 스키마 변경에 맞춰 서버에 전송할 데이터(payload) 구조를 수정합니다.
  Future<void> submitForm() async {
    setLoading(true);
    try {
      Map<String, dynamic> payload;
      if (_campaignType == 'product') {
        payload = {
          'type': 'product',
          'internalTitle': internalTitleController.text.isEmpty ? null : internalTitleController.text,
          'prefix': prefixController.text.isEmpty ? null : prefixController.text,
          'title': titleController.text,
          'coverImageUrl': coverImageUrlController.text.isEmpty ? null : coverImageUrlController.text,
          'liveVerticalCoverUrl':
              liveVerticalCoverUrlController.text.isEmpty ? null : liveVerticalCoverUrlController.text,
          'brand': brandController.text.isEmpty ? null : brandController.text,
          'category': categoryController.text.isEmpty ? null : categoryController.text,
          'descriptionHTML': descController.text.isEmpty ? null : descController.text,
          'liveStreamUrl': liveStreamUrlController.text.isEmpty ? null : liveStreamUrlController.text,
          'startTime': startTimeController.text.isEmpty ? null : startTimeController.text,
          'endTime': endTimeController.text.isEmpty ? null : endTimeController.text,
          'products': _products
              .map((p) => {
                    'url': p.url,
                    'title': p.title,
                    'price': p.price,
                    'salePrice': p.salePrice,
                    'thumbnail': p.thumbnail,
                  })
              .toList(),
          'productThumbnailUrl': productThumbnailUrlController.text.isEmpty ? null : productThumbnailUrlController.text,
          'productName': productNameController.text.isEmpty ? null : productNameController.text,
          'productUrl': campaignProductUrlController.text.isEmpty ? null : campaignProductUrlController.text,
        };
      } else {
        // 'recruit'
        payload = {
          'type': 'recruit',
          'internalTitle': internalTitleController.text.isEmpty ? null : internalTitleController.text,
          'prefix': prefixController.text.isEmpty ? null : prefixController.text,
          'title': titleRecruitController.text,
          'coverImageUrl': coverImageUrlController.text.isEmpty ? null : coverImageUrlController.text,
          'brand': brandController.text.isEmpty ? null : brandController.text,
          'category': categoryRecruitController.text.isEmpty ? null : categoryRecruitController.text,
          'descriptionHTML': descRecruitController.text.isEmpty ? null : descRecruitController.text,
          'shootDate': shootDateController.text.isEmpty ? null : shootDateController.text,
          'startTime': startTimeController.text.isEmpty ? null : startTimeController.text,
          'endTime': endTimeController.text.isEmpty ? null : endTimeController.text,
          'closeAt': deadlineController.text.isEmpty ? null : deadlineController.text,
          'location': locationController.text.isEmpty ? null : locationController.text,
          'fee': int.tryParse(feeController.text),
          'feeNegotiable': payNegotiable,
          'recruit': {
            'durationInHours': double.tryParse(durationInHoursController.text),
            'location': locationController.text.isEmpty ? null : locationController.text,
            'questions': _tags,
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
      try {
        final errorJson = jsonDecode(e.toString().replaceFirst('Exception: ', ''));
        if (errorJson['code'] == 'COVER_IMAGE_REQUIRED') {
          throw Exception('커버 이미지를 등록해주세요.');
        } else {
          throw Exception(errorJson['message'] ?? '알 수 없는 서버 오류가 발생했습니다.');
        }
      } catch (parseError) {
        rethrow;
      }
    } finally {
      setLoading(false);
    }
  }

  // [추가] 이미지 선택 및 업로드를 처리하는 공통 메소드
  /// 이미지를 선택하고 Cloudinary에 업로드한 후, 전달받은 컨트롤러의 텍스트를 결과 URL로 업데이트합니다.
  Future<void> pickAndUploadImage(TextEditingController controller) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setLoading(true);
    try {
      final bytes = await pickedFile.readAsBytes();
      // CloudinaryUploader를 사용하여 이미지 업로드
      final url = await CloudinaryUploader().uploadFile(bytes, fileName: pickedFile.name);
      controller.text = url;
      // notifyListeners()를 호출하여 UI를 즉시 갱신
      notifyListeners();
    } catch (e) {
      debugPrint('Image upload failed: $e');
      // 에러가 발생하면 호출한 쪽으로 다시 던져서 UI단에서 처리하도록 함
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    // 모든 컨트롤러를 dispose합니다.
    internalTitleController.dispose();
    coverImageUrlController.dispose();
    prefixController.dispose();
    liveVerticalCoverUrlController.dispose();
    liveStreamUrlController.dispose();
    titleController.dispose();
    productUrlController.dispose();
    salePriceController.dispose();
    liveDateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    brandController.dispose();
    categoryController.dispose();
    descController.dispose();
    productThumbnailUrlController.dispose();
    productNameController.dispose();
    campaignProductUrlController.dispose();
    titleRecruitController.dispose();
    shootDateController.dispose();
    deadlineController.dispose();
    locationController.dispose();
    feeController.dispose();
    categoryRecruitController.dispose();
    descRecruitController.dispose();
    durationInHoursController.dispose();
    super.dispose();
  }
}
