import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:livee/presentation/screens/campaign/vm/campaigns_form_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class CampaignsFormScreen extends StatefulWidget {
  final String? campaignId;

  const CampaignsFormScreen({
    super.key,
    this.campaignId,
  });

  @override
  State<CampaignsFormScreen> createState() => _CampaignsFormScreenState();
}

class _CampaignsFormScreenState extends State<CampaignsFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.campaignId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Provider.of<CampaignFormViewModel>(context, listen: false).loadCampaignForEdit(widget.campaignId!));
    }
  }

  // --- 이미지 선택 로직 ---
  Future<void> _pickImage(CampaignFormViewModel viewModel, Function(String) onUrlReady) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // TODO: 이미지 업로드 로직을 ViewModel로 이동하는 것을 고려해볼 수 있습니다.
    // final url = await viewModel.uploadImage(await pickedFile.readAsBytes());
    // onUrlReady(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공고 등록'),
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
      ),
      body: Consumer<CampaignFormViewModel>(
        builder: (context, viewModel, child) {
          return LoadingOverlay(
            isLoading: viewModel.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 기본 정보 ---
                    _buildSectionTitle('기본 정보'),
                    CustomTextFormField(controller: viewModel.brandController, label: '브랜드명', isRequired: true),
                    const SizedBox(height: 16),
                    CustomDropdown(label: '말머리 (선택)', value: '선택 안 함', items: const ['선택 안 함'], onChanged: (val) {}),
                    const SizedBox(height: 16),
                    CustomTextFormField(controller: viewModel.titleController, label: '제목', isRequired: true),
                    const SizedBox(height: 16),
                    CustomTextFormField(controller: viewModel.descController, label: '내용', maxLines: 5),
                    const SizedBox(height: 16),
                    CustomDropdown(
                        label: '카테고리',
                        value: '선택',
                        items: const ['선택', '뷰티', '패션'],
                        onChanged: (val) {},
                        isRequired: true),
                    const SizedBox(height: 16),
                    CustomTextFormField(controller: viewModel.locationController, label: '장소(선택)'),

                    const SizedBox(height: 32),

                    // --- 일정 및 출연료 ---
                    _buildSectionTitle('일정 및 출연료'),
                    _buildDateField(context, controller: viewModel.shootDateController, label: '촬영일 *'),
                    const SizedBox(height: 16),
                    _buildDateField(context, controller: viewModel.deadlineController, label: '공고 마감일 *'),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                        controller: viewModel.durationInHoursController,
                        label: '촬영 시간(시간 기준)',
                        isRequired: true,
                        keyboardType: TextInputType.number),
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
                        label: '대표 이미지 (16:9)', controller: viewModel.coverImageUrlController, aspectRatio: 16 / 9),
                    const SizedBox(height: 16),
                    _buildImagePicker(
                        label: '쇼핑라이브 세로 커버 (9:16)',
                        controller: viewModel.liveVerticalCoverUrlController,
                        aspectRatio: 9 / 16),
                    const SizedBox(height: 16),
                    CustomTextFormField(controller: viewModel.liveStreamUrlController, label: '쇼핑라이브 링크'),
                    const SizedBox(height: 16),
                    _buildImagePicker(
                        label: '상품 썸네일 (정사각형)',
                        controller: viewModel.productThumbnailUrlController,
                        aspectRatio: 1 / 1),
                    const SizedBox(height: 16),
                    CustomTextFormField(controller: viewModel.productNameController, label: '상품명'),
                    const SizedBox(height: 16),
                    CustomTextFormField(controller: viewModel.campaignProductUrlController, label: '상품 링크'),

                    const SizedBox(height: 32),

                    // --- 하단 액션 버튼 ---
                    _buildActionButtons(viewModel),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2101),
          );
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

  Widget _buildImagePicker(
      {required String label, required TextEditingController controller, required double aspectRatio}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Container(
                width: 100, // 너비 고정
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: controller.text.isNotEmpty
                    ? Image.network(controller.text,
                        fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.error))
                    : const Center(child: Text('미리보기')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('파일 선택'),
                onPressed: () => _pickImage(context.read<CampaignFormViewModel>(), (url) {
                  setState(() => controller.text = url);
                }),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textBlack,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActionButtons(CampaignFormViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () => GoRouter.of(context).pop(), child: const Text('취소')),
        const SizedBox(width: 8),
        PrimaryActionButton(
          text: viewModel.editingCampaign == null ? '공고 등록' : '수정 완료',
          isFullWidth: false,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await viewModel.submitForm();
                if (context.mounted) GoRouter.of(context).go('/campaigns');
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
