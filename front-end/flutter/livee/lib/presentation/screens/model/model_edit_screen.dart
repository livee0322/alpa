import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/model/vm/model_edit_view_model.dart';
import 'package:livee/presentation/screens/showhost/sections/basic_info_section.dart';
import 'package:livee/presentation/screens/showhost/sections/link_settings_section.dart';
import 'package:livee/presentation/screens/showhost/sections/preview_section.dart';
import 'package:livee/presentation/screens/showhost/sections/selection_info_section.dart';
import 'package:livee/presentation/screens/showhost/sections/sub_thumbnail_section.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/section_title.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';

/// '모델 등록' 또는 '수정'을 위한 UI
class ModelEditScreen extends StatelessWidget {
  final String? modelId;

  const ModelEditScreen({
    super.key,
    this.modelId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelEditViewModel(context, modelId: modelId),
      child: Consumer<ModelEditViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            title: Text(viewModel.isEditing ? '모델 프로필 수정' : '모델 프로필 등록'),
            centerTitle: false,
            backgroundColor: const Color(0xFFF7F8FA),
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: _buildBody(context, viewModel),
        ),
      ),
    );
  }

  /// 화면의 본문(Body) UI
  Widget _buildBody(BuildContext context, ModelEditViewModel viewModel) => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                children: [
                  PreviewSection(
                    mainThumbnailSource: viewModel.mainThumbnailSource,
                    backgroundImageSource: viewModel.backgroundImageSource,
                    nicknameController: viewModel.nicknameController,
                    onPickMainThumbnail: () => viewModel.pickImage(
                      onImageSelected: (source) => viewModel.mainThumbnailSource = source,
                    ),
                    onPickBackgroundImage: () => viewModel.pickImage(
                      onImageSelected: (source) => viewModel.backgroundImageSource = source,
                    ),
                  ),
                  const SizedBox(height: 32),
                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: SubThumbnailSection(
                      sources: viewModel.subThumbnailSources,
                      onAddImage: () => viewModel.pickImage(
                        onImageSelected: (source) => viewModel.subThumbnailSources.add(source),
                      ),
                      onRemoveImage: (index) => viewModel.removeSubThumbnail(index),
                    ),
                  ),
                  // 리팩토링된 공통 섹션 위젯들을 사용합니다.
                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: '기본 정보'),
                        BasicInfoSection(viewModel: viewModel),
                      ],
                    ),
                  ),
                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: '선택 정보'),
                        SelectionInfoSection(viewModel: viewModel),
                      ],
                    ),
                  ),
                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: '링크 & 공개 설정'),
                        LinkSettingsSection(viewModel: viewModel),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildActionButtons(viewModel),
                ],
              ),
            ),
          ),
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      );

  Widget _buildActionButtons(ModelEditViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 48,
          child: PrimaryActionButton(
            text: '저장',
            isFullWidth: false,
            isLoading: viewModel.isLoading,
            onPressed: () => viewModel.saveModel(),
          ),
        ),
      ],
    );
  }
}
