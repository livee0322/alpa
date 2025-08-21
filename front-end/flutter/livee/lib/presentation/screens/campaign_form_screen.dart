import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/campaign_form/widget/campaign_type_selector.dart';
import 'package:livee/presentation/screens/campaign_form/widget/form_section_container.dart';
import 'package:livee/presentation/screens/campaign_form/widget/image_picker_section.dart';
import 'package:livee/presentation/screens/campaign_form/widget/product_form_section.dart';
import 'package:livee/presentation/screens/campaign_form/widget/recruit_form_section.dart';
import 'package:provider/provider.dart';
import 'package:livee/presentation/providers/campaign_form_provider.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/common_header.dart';

class CampaignFormScreen extends StatefulWidget {
  final String? campaignId;

  const CampaignFormScreen({
    super.key,
    this.campaignId,
  });

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
      // 위젯 트리가 빌드된 후 Provider에 접근하기 위해 사용
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          Provider.of<CampaignFormProvider>(context, listen: false)
              .loadCampaignForEdit(widget.campaignId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CampaignFormProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // 공통 헤더
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) =>
                      CommonHeader(isLoggedIn: authProvider.isLoggedIn),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 페이지 제목
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            provider.editingCampaign == null
                                ? '캠페인 등록'
                                : '캠페인 수정',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FormSectionContainer(
                          title: '캠페인 제목 (내부용)',
                          children: [
                            TextFormField(
                              controller: provider.internalTitleController,
                              decoration: const InputDecoration(
                                labelText: '캠페인 제목',
                                hintText: '예) 9월 2주차 뷰티 런칭',
                                helperText:
                                    '본인에게만 보이는 메모용 제목입니다. 외부에 노출되지 않습니다.',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),

                        FormSectionContainer(
                          title: '대표 썸네일',
                          children: [
                            ImagePickerSection(provider: provider),
                          ],
                        ),

                        FormSectionContainer(
                          title: '캠페인 유형',
                          children: [
                            CampaignTypeSelector(provider: provider),
                          ],
                        ),

                        // 선택된 유형에 따라 다른 폼 섹션을 보여줌
                        if (provider.campaignType == 'product')
                          FormSectionContainer(
                            title: '상품 캠페인',
                            children: [
                              ProductFormSection(provider: provider),
                            ],
                          ),

                        if (provider.campaignType == 'recruit')
                          FormSectionContainer(
                            title: '쇼호스트 모집 상세',
                            children: [
                              RecruitFormSection(provider: provider),
                            ],
                          ),

                        _buildActions(provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }

  // 하단 액션 버튼 (취소, 등록/수정)
  Widget _buildActions(CampaignFormProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed:
              provider.isLoading ? null : () => GoRouter.of(context).pop(),
          child: const Text('취소'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await provider.submitForm();
                      if (context.mounted) {
                        // 성공 시 캠페인 목록 화면으로 이동
                        GoRouter.of(context).go('/campaigns');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('저장 실패: $e')),
                        );
                      }
                    }
                  }
                },
          child: provider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(provider.editingCampaign == null ? '등록하기' : '수정 저장'),
        ),
      ],
    );
  }
}
