import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/sections/file_attachment_section.dart';
import 'package:livee/presentation/screens/portfolio/vm/profile_edit_view_model_base.dart';
import 'package:livee/presentation/widgets/custom_dropdown.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';

class LinkSettingsSection extends StatelessWidget {
  final ProfileEditViewModelBase viewModel;
  const LinkSettingsSection({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          controller: viewModel.websiteUrlController,
          label: '웹사이트',
          hintText: 'https://...',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.instagramUrlController,
          label: 'Instagram',
          hintText: 'https://instagram.com/...',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.youtubeUrlController,
          label: 'YouTube',
          hintText: 'https://youtube.com/...',
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: viewModel.tiktokUrlController,
          label: 'TikTok',
          hintText: 'https://tiktok.com/...',
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          menuOffset: Offset(0, 54),
          label: '공개 범위',
          value: viewModel.publicScope,
          items: const ['전체공개', '링크 공개', '비공개'],
          onChanged: viewModel.setPublicScope,
        ),
        const SizedBox(height: 16),

        // FileAttachmentSection도 이제 viewModel을 그대로 전달받아 사용할 수 있습니다.
        FileAttachmentSection(
          onPickFile: viewModel.pickFileForCache,
          onRemoveFile: viewModel.removeAttachedFile,
          fileName: viewModel.attachedFileName,
        ),

        CheckboxListTile(
          title: const Text('제안 받기'),
          value: viewModel.isReceivingOffers,
          onChanged: viewModel.setIsReceivingOffers,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF6C63FF),
        ),
      ],
    );
  }
}
