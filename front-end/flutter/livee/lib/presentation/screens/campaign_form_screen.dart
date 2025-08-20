import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:file_picker/file_picker.dart';
import 'package:livee/data/core/cloudinary_uploader.dart';

class CampaignFormScreen extends StatefulWidget {
  final String? campaignId;
  const CampaignFormScreen({super.key, this.campaignId});

  @override
  State<CampaignFormScreen> createState() => _CampaignFormScreenState();
}

class _CampaignFormScreenState extends State<CampaignFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // 수정 모드일 경우 기존 데이터 로드
    if (widget.campaignId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<CampaignFormProvider>(context, listen: false).loadCampaignForEdit(widget.campaignId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CommonHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Consumer<CampaignFormProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageTitle(provider),
                        _buildSection('대표 썸네일', [_buildImagePicker(provider)]),
                        _buildSection('캠페인 유형', [_buildTypeSelector(provider)]),
                        if (provider.campaignType == 'product') _buildProductSection(provider),
                        if (provider.campaignType == 'recruit') _buildRecruitSection(provider),
                        _buildActions(provider),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  // 페이지 제목 위젯
  Widget _buildPageTitle(CampaignFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider.editingCampaign == null ? '캠페인 등록' : '캠페인 수정',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 섹션 제목을 포함한 컨테이너 위젯
  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEF0F3)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // 캠페인 유형 선택 위젯
  Widget _buildTypeSelector(CampaignFormProvider provider) {
    return Row(
      children: [
        _buildTypeButton('product', '상품 캠페인', provider),
        const SizedBox(width: 8),
        _buildTypeButton('recruit', '쇼호스트 모집', provider),
      ],
    );
  }

  // 유형 선택 버튼 위젯
  Widget _buildTypeButton(String type, String label, CampaignFormProvider provider) {
    final isSelected = provider.campaignType == type;
    return Expanded(
      child: InkWell(
        onTap: () => provider.setCampaignType(type),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFFE6E8EC),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4B4F68),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // 이미지 업로더 위젯
  Widget _buildImagePicker(CampaignFormProvider provider) {
    return Column(
      children: [
        // 이미지 미리보기
        Container(
          height: 150,
          color: Colors.grey[200],
          child: provider.imageUrlController.text.isNotEmpty
              ? Image.network(provider.imageUrlController.text)
              : const Center(child: Text('이미지 미리보기')),
        ),
        const SizedBox(height: 10),
        // 이미지 선택 및 업로드 버튼
        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.single.bytes != null) {
                    provider.setLoading(true);
                    try {
                      final url = await CloudinaryUploader()
                          .uploadImage(result.files.single.bytes!, fileName: result.files.single.name);
                      provider.imageUrlController.text = url;
                    } catch (e) {
                      // TODO: 사용자에게 에러 메시지 보여주기
                    } finally {
                      provider.setLoading(false);
                    }
                  }
                },
          child: provider.isLoading ? const CircularProgressIndicator() : const Text('이미지 선택 및 업로드'),
        ),
      ],
    );
  }

  // 상품 캠페인 섹션
  Widget _buildProductSection(CampaignFormProvider provider) {
    return _buildSection('상품 캠페인', [
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: provider.productUrlController,
              label: '상품 URL',
              hint: '네이버/쿠팡/지마켓 등 상품 URL',
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : () async {
                    try {
                      await provider.addProductFromUrl(provider.productUrlController.text);
                      // TODO: 성공 메시지 보여주기
                    } catch (e) {
                      // TODO: 에러 메시지 보여주기
                    }
                  },
            child: const Text('불러오기'),
          ),
        ],
      ),
      _buildProductList(provider),
      _buildTextField(
        controller: provider.salePriceController,
        label: '공통 할인가',
        hint: '예) 19900',
        keyboardType: TextInputType.number,
      ),
      _buildTextField(
        controller: provider.liveDateController,
        label: '라이브 날짜',
        keyboardType: TextInputType.datetime,
      ),
      _buildTextField(
        controller: provider.liveTimeController,
        label: '라이브 시간',
        keyboardType: TextInputType.datetime,
      ),
      _buildTextField(
        controller: provider.brandController,
        label: '브랜드명',
        hint: '예) ALPA',
      ),
      _buildTextField(
        controller: provider.categoryController,
        label: '상품군',
        hint: '예) 뷰티/패션/가전',
      ),
      _buildTextField(
        controller: provider.descController,
        label: '상세 설명',
        hint: '상세페이지에 노출할 소개/가이드/주의사항 등을 작성하세요.',
        maxLines: 7,
      ),
    ]);
  }

  // 상품 리스트 위젯
  Widget _buildProductList(CampaignFormProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: provider.products.isEmpty
          ? const Text('아직 등록된 상품이 없습니다.')
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final product = provider.products[index];
                return ListTile(
                  leading: product.thumbnail != null
                      ? Image.network(product.thumbnail!, width: 50, height: 50)
                      : const SizedBox(width: 50, height: 50, child: Placeholder()),
                  title: Text(product.title ?? '제목 없음'),
                  subtitle: Text(
                      '${product.price?.toStringAsFixed(0) ?? ''}원 -> ${product.salePrice?.toStringAsFixed(0) ?? ''}원'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.removeProduct(index),
                  ),
                );
              },
            ),
    );
  }

  // 쇼호스트 모집 섹션
  Widget _buildRecruitSection(CampaignFormProvider provider) {
    return _buildSection('쇼호스트 모집', [
      _buildTextField(
        controller: provider.titleRecruitController,
        label: '제목',
        hint: '예) 잘 먹는 쇼호스트 찾습니다',
        isRequired: true,
      ),
      _buildTextField(
        controller: provider.locationController,
        label: '촬영 장소',
        hint: '예) 서울 강남구 ○○스튜디오',
      ),
      _buildTextField(
        controller: provider.payController,
        label: '출연료',
        hint: '예) 30만원',
      ),
      CheckboxListTile(
        title: const Text('협의 가능'),
        value: provider.payNegotiable,
        onChanged: (value) => provider.setPayNegotiable(value ?? false),
      ),
      _buildTextField(
        controller: provider.categoryRecruitController,
        label: '상품군',
        hint: '예) 뷰티/패션/가전',
      ),
      _buildTextField(
        controller: provider.descRecruitController,
        label: '요구사항/우대사항',
        hint: '방송 내용, 요구 스킬, 우대사항 등을 상세히 적어주세요.',
        maxLines: 7,
      ),
    ]);
  }

  // 공통 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label을(를) 입력해주세요.';
          }
          return null;
        },
      ),
    );
  }

  // 하단 액션 버튼 위젯
  Widget _buildActions(CampaignFormProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: provider.isLoading
              ? null
              : () {
                  GoRouter.of(context).pop();
                },
          child: const Text('취소'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    await provider.submitForm();
                    if (context.mounted) {
                      GoRouter.of(context).go('/campaigns');
                    }
                  }
                },
          child: provider.isLoading
              ? const CircularProgressIndicator()
              : Text(provider.editingCampaign == null ? '등록하기' : '수정 저장'),
        ),
      ],
    );
  }
}
