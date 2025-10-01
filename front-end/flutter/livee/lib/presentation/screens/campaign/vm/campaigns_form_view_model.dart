import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/product.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';
import 'package:livee/service_locator.dart';

// [추가] 어떤 이미지를 선택할지 구분하기 위한 Enum
enum ImageType {
  cover,
  verticalCover,
  productThumbnail,
}

class CampaignFormViewModel with ChangeNotifier {
  final CampaignUseCase _campaignUseCase = locator<CampaignUseCase>();
  final ApiClient _apiClient = locator<ApiClient>();
  final String? campaignId;

  CampaignFormViewModel({this.campaignId}) {
    feeController.addListener(_updatePayWanPreview);
    startTimeController.addListener(_updateDuration);
    endTimeController.addListener(_updateDuration);
    // 수정 모드일 경우 데이터 로딩 시작
    if (campaignId != null) loadCampaignForEdit(campaignId!);
  }

  // FormKey를 ViewModel에서 관리
  final formKey = GlobalKey<FormState>();

  // --- 상태 변수 정의 ---
  String _campaignType = 'product';
  bool _isLoading = false;
  String? _editCampaignId;
  Campaign? _editingCampaign;
  List<String> _tags = [];

  // 드롭다운 선택 값을 관리할 상태 변수
  String? selectedPrefix;
  String? selectedCategory;

  // 선택한 이미지의 원본 데이터를 임시 저장할 변수
  Uint8List? tempCoverImageBytes;
  Uint8List? tempVerticalCoverImageBytes;
  Uint8List? tempProductThumbnailBytes;

  // 공통 필드
  final TextEditingController internalTitleController = TextEditingController();
  final TextEditingController coverImageUrlController = TextEditingController();
  final TextEditingController prefixController = TextEditingController(); // 말머리
  final TextEditingController liveVerticalCoverUrlController =
      TextEditingController(); // 세로 커버 이미지
  final TextEditingController liveStreamUrlController =
      TextEditingController(); // 라이브 스트리밍 URL

  // 상품 캠페인 필드
  final TextEditingController titleController = TextEditingController();
  final TextEditingController productUrlController =
      TextEditingController(); // 상품 스크래핑용 URL
  List<Product> _products = [];
  final TextEditingController salePriceController = TextEditingController();
  String? saleDuration;
  final TextEditingController liveDateController =
      TextEditingController(); // 라이브 날짜 (YYYY-MM-DD)
  final TextEditingController startTimeController =
      TextEditingController(); // 시작 시간 (HH:MM)
  final TextEditingController endTimeController =
      TextEditingController(); // 종료 시간 (HH:MM)
  final TextEditingController brandController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController productThumbnailUrlController =
      TextEditingController(); // 대표 상품 정보 필드
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController campaignProductUrlController =
      TextEditingController(); // 대표 상품 URL

  // 쇼호스트 모집 필드
  final TextEditingController titleRecruitController = TextEditingController();
  final TextEditingController shootDateController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  bool payNegotiable = false;
  final TextEditingController categoryRecruitController =
      TextEditingController();
  final TextEditingController descRecruitController = TextEditingController();
  final TextEditingController durationInHoursController =
      TextEditingController();

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

  /// 이미지를 선택하고, 해당하는 임시 변수에 원본 데이터를 저장합
  Future<void> pickImage(ImageType imageType) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    // Enum 타입에 따라 올바른 변수에 이미지 데이터를 저장
    switch (imageType) {
      case ImageType.cover:
        tempCoverImageBytes = bytes;
        coverImageUrlController.clear();
        break;
      case ImageType.verticalCover:
        tempVerticalCoverImageBytes = bytes;
        liveVerticalCoverUrlController.clear();
        break;
      case ImageType.productThumbnail:
        tempProductThumbnailBytes = bytes;
        productThumbnailUrlController.clear();
        break;
    }
    // 상태 변경 후 UI에 알림
    notifyListeners();
  }

  //  이미지 '업로드' 기능만 하는 별도의 메소드
  /// 이미지 원본 데이터(Bytes)를 Cloudinary에 업로드하고 URL을 반환
  Future<String?> _uploadImage(Uint8List? imageBytes) async {
    if (imageBytes == null) return null;
    try {
      return await CloudinaryUploader().uploadFile(imageBytes);
    } catch (e) {
      debugPrint('Image upload failed: $e');
      rethrow; // 에러를 다시 던져서 submitForm에서 처리하도록 함
    }
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
            return TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1]));
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
        durationInHoursController.text =
            (durationMinutes / 60).toStringAsFixed(1);
        _durationText =
            '촬영시간: ${hours > 0 ? '$hours시간 ' : ''}${minutes > 0 ? '$minutes분' : ''}';
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

      // 드롭다운 상태 변수도 업데이트
      selectedPrefix = campaign.prefix;
      selectedCategory = campaign.category;

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
        shootDateController.text = campaign.shootDate != null
            ? DateFormat('yyyy-MM-dd').format(campaign.shootDate!)
            : '';
        deadlineController.text = campaign.closeAt?.substring(0, 10) ?? '';
        startTimeController.text = campaign.startTime ?? '';
        endTimeController.text = campaign.endTime ?? '';
        locationController.text = campaign.location ?? '';
        feeController.text = campaign.fee?.toString() ?? '';
        payNegotiable = campaign.feeNegotiable ?? false;
        categoryRecruitController.text = campaign.category ?? '';
        descRecruitController.text = campaign.descriptionHTML ?? '';
        durationInHoursController.text =
            campaign.recruit?.durationInHours?.toString() ?? '';
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
      final response = await _apiClient
          .get('/scrape/product?url=${Uri.encodeComponent(url)}');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes))['data'] ??
            jsonDecode(utf8.decode(response.bodyBytes));
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

  Future<void> submitForm() async {
    setLoading(true);
    try {
      // --- 1. 저장 직전에 이미지 업로드 실행 ---
      final coverImageUrl = await _uploadImage(tempCoverImageBytes) ??
          coverImageUrlController.text;
      final verticalCoverUrl =
          await _uploadImage(tempVerticalCoverImageBytes) ??
              liveVerticalCoverUrlController.text;
      final productThumbUrl = await _uploadImage(tempProductThumbnailBytes) ??
          productThumbnailUrlController.text;

      // --- 2. 업로드된 URL을 포함하여 payload 생성 ---
      Map<String, dynamic> payload;
      if (_campaignType == 'product') {
        payload = {
          'type': 'product',
          'internalTitle': internalTitleController.text.isEmpty
              ? null
              : internalTitleController.text,
          'prefix':
              prefixController.text.isEmpty ? null : prefixController.text,
          'title': titleController.text,
          'coverImageUrl': coverImageUrl.isEmpty ? null : coverImageUrl,
          'liveVerticalCoverUrl':
              verticalCoverUrl.isEmpty ? null : verticalCoverUrl,
          'brand': brandController.text.isEmpty ? null : brandController.text,
          'category':
              categoryController.text.isEmpty ? null : categoryController.text,
          'descriptionHTML':
              descController.text.isEmpty ? null : descController.text,
          'liveStreamUrl': liveStreamUrlController.text.isEmpty
              ? null
              : liveStreamUrlController.text,
          'startTime': startTimeController.text.isEmpty
              ? null
              : startTimeController.text,
          'endTime':
              endTimeController.text.isEmpty ? null : endTimeController.text,
          'products': _products
              .map((p) => {
                    'url': p.url,
                    'title': p.title,
                    'price': p.price,
                    'salePrice': p.salePrice,
                    'thumbnail': p.thumbnail,
                  })
              .toList(),
          'productThumbnailUrl':
              productThumbUrl.isEmpty ? null : productThumbUrl,
          'productName': productNameController.text.isEmpty
              ? null
              : productNameController.text,
          'productUrl': campaignProductUrlController.text.isEmpty
              ? null
              : campaignProductUrlController.text,
        };
      } else {
        // 'recruit'
        payload = {
          'type': 'recruit',
          'internalTitle': internalTitleController.text.isEmpty
              ? null
              : internalTitleController.text,
          'prefix':
              prefixController.text.isEmpty ? null : prefixController.text,
          'title': titleRecruitController.text,
          'coverImageUrl': coverImageUrl.isEmpty ? null : coverImageUrl,
          'liveVerticalCoverUrl':
              verticalCoverUrl.isEmpty ? null : verticalCoverUrl,
          'brand': brandController.text.isEmpty ? null : brandController.text,
          'category': categoryRecruitController.text.isEmpty
              ? null
              : categoryRecruitController.text,
          'descriptionHTML': descRecruitController.text.isEmpty
              ? null
              : descRecruitController.text,
          'shootDate': shootDateController.text.isEmpty
              ? null
              : shootDateController.text,
          'startTime': startTimeController.text.isEmpty
              ? null
              : startTimeController.text,
          'endTime':
              endTimeController.text.isEmpty ? null : endTimeController.text,
          'closeAt':
              deadlineController.text.isEmpty ? null : deadlineController.text,
          'location':
              locationController.text.isEmpty ? null : locationController.text,
          'fee': int.tryParse(feeController.text),
          'feeNegotiable': payNegotiable,
          'recruit': {
            'durationInHours': double.tryParse(durationInHoursController.text),
            'location': locationController.text.isEmpty
                ? null
                : locationController.text,
            'questions': _tags,
          }
        };
      }

      // --- 3. API 호출 ---
      if (campaignId != null) {
        await _campaignUseCase.updateCampaign(campaignId!, payload);
      } else {
        await _campaignUseCase.createCampaign(payload);
      }
    } catch (e) {
      debugPrint('Form submission failed: $e');
      try {
        final errorJson =
            jsonDecode(e.toString().replaceFirst('Exception: ', ''));
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
