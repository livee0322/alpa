import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/presentation/screens/campaign/vm/campaigns_form_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/custom_calendar_dialog.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class CampaignsFormScreen extends StatelessWidget {
  final String? campaignId;

  const CampaignsFormScreen({
    super.key,
    this.campaignId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CampaignFormViewModel>(
      builder: (context, viewModel, child) {
        final imageHandler = context.watch<ImageHandlerProvider>();
        return Scaffold(
          body: LoadingOverlay(
            isLoading: viewModel.isLoading || imageHandler.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 기본 정보 ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        campaignId == null ? '공고 등록' : '공고 수정',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildSectionTitle('기본 정보'),
                    CustomTextFormField(
                        controller: viewModel.brandController, label: '브랜드명', isRequired: true, hintText: '예) ACME'),
                    const SizedBox(height: 16),
                    CustomDropdown(
                      menuOffset: Offset(0, 54),
                      label: '말머리 (선택)',
                      value: viewModel.prefixController.text.isEmpty ? '선택 안 함' : viewModel.prefixController.text,
                      items: const ['선택 안 함', '쇼호스트모집', '촬영스태프', '모델모집', '기타모집'],
                      onChanged: viewModel.setPrefix,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: viewModel.titleController,
                        label: '제목',
                        isRequired: true,
                        hintText: '예) 9월 신제품 쇼핑라이브 진행'),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: viewModel.contentController,
                        label: '내용',
                        maxLines: 5,
                        hintText: '요구역량/업무/준비물/참고링크 등을 자유롭게 입력'),
                    const SizedBox(height: 16),
                    CustomDropdown(
                      menuOffset: Offset(0, 54),
                      label: '카테고리',
                      isRequired: true,
                      value: viewModel.categoryController.text.isEmpty ? '선택' : viewModel.categoryController.text,
                      items: const ['선택', '뷰티', '패션', '식품', '가전', '생활/리빙'],
                      onChanged: viewModel.setCategory,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: viewModel.locationController, label: '장소(선택)', hintText: '예) 서울 성수동 스튜디오'),

                    const SizedBox(height: 32),

                    // --- 일정 및 출연료 ---
                    _buildSectionTitle('일정 및 출연료'),
                    _buildDateField(context, controller: viewModel.shootDateController, label: '촬영일 *'),
                    const SizedBox(height: 16),
                    _buildDateField(context, controller: viewModel.deadlineController, label: '공고 마감일 *'),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: viewModel.durationHoursController,
                        label: '촬영 시간(시간 기준)',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        hintText: '예) 3'),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: _buildTimeField(context, controller: viewModel.startTimeController, label: '시작 시간 *')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTimeField(context, controller: viewModel.endTimeController, label: '종료 시간 *')),
                    ]),
                    const SizedBox(height: 16),
                    _buildFeeField(viewModel),

                    const SizedBox(height: 32),

                    // --- 미디어 및 링크 ---
                    _buildSectionTitle('미디어 및 링크'),
                    _buildImagePicker(
                      context: context,
                      viewModel: viewModel,
                      label: '대표 이미지 (16:9)',
                      controller: viewModel.coverImageUrlController,
                      imageBytes: viewModel.tempCoverImageBytes,
                      imageType: ImageType.cover,
                      aspectRatio: 16 / 9,
                      hintText: '대표 이미지를 넣어주세요',
                    ),
                    const SizedBox(height: 16),

                    _buildImagePicker(
                      context: context,
                      viewModel: viewModel,
                      label: '쇼핑라이브 세로 커버 (2:3)',
                      controller: viewModel.liveVerticalCoverUrlController,
                      imageBytes: viewModel.tempVerticalCoverImageBytes,
                      imageType: ImageType.verticalCover,
                      aspectRatio: 2 / 3,
                      hintText: '이미지를 넣어주세요',
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: viewModel.liveStreamUrlController,
                        label: '쇼핑라이브 링크',
                        hintText: '예) www.naver.com/live/...'),
                    const SizedBox(height: 16),

                    _buildImagePicker(
                      context: context,
                      viewModel: viewModel,
                      label: '상품 썸네일 (정사각형)',
                      controller: viewModel.productThumbnailUrlController,
                      imageBytes: viewModel.tempProductThumbnailBytes,
                      imageType: ImageType.productThumbnail,
                      aspectRatio: 1 / 1,
                      hintText: '이미지를 넣어주세요',
                    ),

                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: viewModel.productNameController, label: '상품명', hintText: '예) 신제품 세럼 50ml'),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: viewModel.campaignProductUrlController,
                        label: '상품 링크',
                        hintText: 'www.naver.com/item/...'),

                    const SizedBox(height: 32),

                    _buildActionButtons(context, viewModel),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDateField(BuildContext context, {required TextEditingController controller, required String label}) {
    return CustomTextFormField(
      controller: controller,
      label: label,
      readOnly: true,
      hintText: '연도-월-일',
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today_outlined),
        onPressed: () async {
          final pickedDate = await showDialog<DateTime>(
            context: context,
            builder: (context) => CustomCalendarDialog(
              initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
            ),
          );

          // '확인' 버튼을 눌렀을 때만 (null이 아닐 때) 값을 업데이트합니다.
          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
      ),
      validator: (val) => (val == null || val.isEmpty) ? '날짜를 선택해주세요.' : null,
    );
  }

  Widget _buildTimeField(BuildContext context, {required TextEditingController controller, required String label}) {
    return CustomTextFormField(
      controller: controller,
      label: label,
      readOnly: true,
      hintText: '-- : --',
      suffixIcon: IconButton(
        icon: const Icon(Icons.access_time_outlined),
        onPressed: () async {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null && context.mounted) {
            controller.text = pickedTime.format(context);
          }
        },
      ),
      validator: (val) => (val == null || val.isEmpty) ? '시간을 선택해주세요.' : null,
    );
  }

  Widget _buildFeeField(CampaignFormViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          controller: viewModel.feeController,
          label: '출연료(원)',
          enabled: !viewModel.payNegotiable,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => viewModel.setPayNegotiable(!viewModel.payNegotiable),
          child: Row(
            children: [
              Checkbox(
                value: viewModel.payNegotiable,
                onChanged: (value) => viewModel.setPayNegotiable(value ?? false),
                activeColor: AppColors.primary,
              ),
              const Text('협의 가능 (체크 시 출연료 입력 비활성화)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker({
    required BuildContext context,
    required CampaignFormViewModel viewModel,
    required String label,
    required TextEditingController controller,
    required Uint8List? imageBytes,
    required ImageType imageType,
    required double aspectRatio,
    required String hintText,
  }) {
    final imageHandler = Provider.of<ImageHandlerProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            try {
              final bytes = await imageHandler.pickImage(context: context, aspectRatio: aspectRatio);
              if (bytes != null) {
                switch (imageType) {
                  case ImageType.cover:
                    viewModel.tempCoverImageBytes = bytes;
                    viewModel.coverImageUrlController.clear();
                    break;
                  case ImageType.verticalCover:
                    viewModel.tempVerticalCoverImageBytes = bytes;
                    viewModel.liveVerticalCoverUrlController.clear();
                    break;
                  case ImageType.productThumbnail:
                    viewModel.tempProductThumbnailBytes = bytes;
                    viewModel.productThumbnailUrlController.clear();
                    break;
                }
                // [추가] ViewModel의 상태 변경을 UI에 즉시 알립니다.
                viewModel.notifyListeners();
              }
            } catch (e) {
              if (context.mounted) {
                showCustomToast(context, '이미지 선택 실패: $e', type: ToastType.error);
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _buildImagePreview(controller, imageBytes, hintText),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 이미지 미리보기 내부 UI를 결정하는 헬퍼 위젯
  Widget _buildImagePreview(TextEditingController controller, Uint8List? imageBytes, String hintText) {
    // 1. 새로 선택한 임시 이미지가 있으면 보여줌
    if (imageBytes != null) {
      return Image.memory(imageBytes, fit: BoxFit.cover);
    }
    // 2. 기존에 업로드된 네트워크 이미지가 있으면 보여줌 (수정 모드)
    if (controller.text.isNotEmpty) {
      return Image.network(controller.text, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.error));
    }
    // 3. 아무 이미지도 없으면 힌트 텍스트를 보여줌
    return Center(
      child: Text(
        hintText,
        style: TextStyle(color: AppColors.textGrey),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CampaignFormViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () => context.pop(), child: const Text('취소')),
        const SizedBox(width: 8),
        PrimaryActionButton(
          text: viewModel.editingCampaign == null ? '공고 등록' : '수정 완료',
          isFullWidth: false,
          onPressed: () async {
            if (viewModel.formKey.currentState!.validate()) {
              try {
                await viewModel.submitForm();
                if (context.mounted) context.go('/campaigns');
              } catch (e) {
                // 에러 처리는 ViewModel 내부에서 토스트 등으로 처리하는 것이 더 좋습니다.
              }
            }
          },
        )
      ],
    );
  }
}
