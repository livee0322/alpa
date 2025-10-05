import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/studio/vm/studio_edit_view_model.dart';
import 'package:livee/presentation/common/custom_text_form_field.dart';

/// 스튜디오의 소개, 이용안내, 금액 등 상세 정보를 입력받는 섹션 위젯입니다.
class StudioDescriptionSection extends StatelessWidget {
  final StudioEditViewModel viewModel;

  const StudioDescriptionSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
            controller: viewModel.oneLineIntroController, label: '한 줄 소개', hintText: '예) 성수동 다목적 촬영 스튜디오'),
        const SizedBox(height: 16),
        CustomTextFormField(
            controller: viewModel.detailedIntroController, label: '상세 소개', hintText: '스튜디오 상세 설명', maxLines: 5),
        const SizedBox(height: 16),
        CustomTextFormField(
            controller: viewModel.usageInfoController, label: '이용 안내', hintText: '예약/환불/주의사항 등', maxLines: 5),
        const SizedBox(height: 16),
        CustomTextFormField(
            controller: viewModel.priceInfoController, label: '금액 안내', hintText: '패키지/옵션/부가세 등', maxLines: 5),
      ],
    );
  }
}
