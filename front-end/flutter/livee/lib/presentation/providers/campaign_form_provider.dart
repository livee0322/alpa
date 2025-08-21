import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livee/data/core/api_client.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/domain/models/product.dart';
import 'package:livee/domain/repositories/campaign_repository.dart';
import 'package:livee/domain/usecases/campaign_use_case.dart';

class CampaignFormProvider with ChangeNotifier {
  final CampaignUseCase _campaignUseCase;
  final CampaignRepository _campaignRepository;
  final ApiClient _apiClient;

  CampaignFormProvider(this._campaignUseCase, this._campaignRepository, this._apiClient);

  String _campaignType = 'product';
  bool _isLoading = false;
  String? _editCampaignId;
  Campaign? _editingCampaign;

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

  final TextEditingController titleRecruitController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeStartController = TextEditingController();
  final TextEditingController timeEndController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController payController = TextEditingController();
  bool payNegotiable = false;
  final TextEditingController categoryRecruitController = TextEditingController();
  final TextEditingController descRecruitController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  String get campaignType => _campaignType;
  bool get isLoading => _isLoading;
  List<Product> get products => _products;
  Campaign? get editingCampaign => _editingCampaign;

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

  Future<void> loadCampaignForEdit(String id) async {
    setLoading(true);
    _editCampaignId = id;
    try {
      final campaign = await _campaignUseCase.getCampaignById(id);
      _editingCampaign = campaign;
      setCampaignType(campaign.type ?? 'product');
      imageUrlController.text = campaign.coverImageUrl ?? '';

      if (campaign.type == 'product') {
        titleController.text = campaign.title ?? '';
        _products = campaign.products ?? [];
        salePriceController.text =
            campaign.products?.firstWhere((p) => p.salePrice != null, orElse: () => Product())?.salePrice?.toString() ??
                '';
        // saleDuration은 모델에 없음
        liveDateController.text = campaign.date ?? '';
        liveTimeController.text = campaign.live?.time ?? ''; // 임시
        brandController.text = campaign.brand ?? '';
        categoryController.text = campaign.category ?? '';
        descController.text = campaign.descriptionHTML ?? '';
      } else if (campaign.type == 'recruit') {
        final recruit = campaign.recruit;
        titleRecruitController.text = recruit?.title ?? '';
        dateController.text = recruit?.date ?? '';
        timeStartController.text = recruit?.timeStart ?? '';
        timeEndController.text = recruit?.timeEnd ?? '';
        locationController.text = recruit?.location ?? '';
        payController.text = recruit?.pay ?? '';
        payNegotiable = recruit?.payNegotiable ?? false;
        categoryRecruitController.text = recruit?.category ?? '';
        descRecruitController.text = recruit?.description ?? '';
      }
    } catch (e) {
      debugPrint('Error loading campaign for edit: $e');
    } finally {
      setLoading(false);
    }
  }

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

  Future<void> submitForm() async {
    setLoading(true);
    try {
      Map<String, dynamic> payload;
      if (_campaignType == 'product') {
        payload = {
          'type': 'product',
          'title': titleController.text,
          'coverImageUrl': imageUrlController.text,
          'products': _products
              .map((p) => {
                    'url': p.url,
                    'title': p.title,
                    'price': p.price,
                    'salePrice': p.salePrice,
                    'thumbnail': p.thumbnail,
                  })
              .toList(),
          'sale': {
            'price': num.tryParse(salePriceController.text),
            'durationSec': saleDuration != null ? int.tryParse(saleDuration!) : null,
          },
          'live': {
            'date': liveDateController.text,
            'time': liveTimeController.text,
          },
          'brand': brandController.text,
          'category': categoryController.text,
          'descriptionHTML': descController.text,
        };
      } else {
        payload = {
          'type': 'recruit',
          'title': titleRecruitController.text,
          'coverImageUrl': imageUrlController.text,
          'recruit': {
            'title': titleRecruitController.text,
            'date': dateController.text,
            'timeStart': timeStartController.text,
            'timeEnd': timeEndController.text,
            'location': locationController.text,
            'pay': payController.text,
            'payNegotiable': payNegotiable,
            'category': categoryRecruitController.text,
            'description': descRecruitController.text,
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
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}
