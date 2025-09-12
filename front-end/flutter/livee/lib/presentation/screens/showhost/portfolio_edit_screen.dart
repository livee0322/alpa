import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/vm/portfolio_edit_view_model.dart';
// [수정] 새로 만든 섹션 위젯들을 모두 임포트합니다.
import 'package:livee/presentation/screens/showhost/sections/basic_info_section.dart';
import 'package:livee/presentation/screens/showhost/sections/link_settings_section.dart';
import 'package:livee/presentation/screens/showhost/sections/preview_section.dart';
import 'package:livee/presentation/screens/showhost/sections/recent_live_section.dart';
import 'package:livee/presentation/screens/showhost/sections/selection_info_section.dart';
import 'package:livee/presentation/screens/showhost/sections/shorts_section.dart';
import 'package:livee/presentation/screens/showhost/sections/sub_thumbnail_section.dart';
import 'package:livee/presentation/screens/showhost/widgets/portfolio_tags_section.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';

class PortfolioEditScreen extends StatelessWidget {
  final String? portfolioId;

  const PortfolioEditScreen({
    super.key,
    this.portfolioId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortfolioEditViewModel(context, portfolioId: portfolioId),
      child: Consumer<PortfolioEditViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            title: Text(viewModel.isEditing ? '포트폴리오 수정' : '포트폴리오 등록'),
            centerTitle: false,
            backgroundColor: const Color(0xFFF7F8FA),
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                children: [
                  // 각 섹션을 위젯으로 호출
                  PreviewSection(
                    mainThumbnailSource: viewModel.mainThumbnailSource,
                    backgroundImageSource: viewModel.backgroundImageSource,
                    nicknameController: viewModel.nicknameController,
                    onPickMainThumbnail: () => viewModel.pickImage(
                      onImageSelected: (source) =>
                          viewModel.mainThumbnailSource = source,
                    ),
                    onPickBackgroundImage: () => viewModel.pickImage(
                      onImageSelected: (source) =>
                          viewModel.backgroundImageSource = source,
                    ),
                  ),
                  const SizedBox(height: 32),

                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: SubThumbnailSection(
                      sources: viewModel.subThumbnailSources,
                      onAddImage: () => viewModel.pickImage(
                        onImageSelected: (source) =>
                            viewModel.subThumbnailSources.add(source),
                      ),
                      onRemoveImage: (index) =>
                          viewModel.removeSubThumbnail(index),
                    ),
                  ),
                  const SizedBox(height: 32),

                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: BasicInfoSection(viewModel: viewModel),
                  ),
                  const SizedBox(height: 32),

                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: SelectionInfoSection(viewModel: viewModel),
                  ),
                  const SizedBox(height: 32),

                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: const ShortsSection(),
                  ),
                  const SizedBox(height: 32),

                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: RecentLiveSection(
                      controllers: viewModel.recentLiveControllers,
                      onAdd: viewModel.addRecentLiveLink,
                      onRemove: viewModel.removeRecentLiveLink,
                    ),
                  ),
                  const SizedBox(height: 32),

                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: LinkSettingsSection(viewModel: viewModel),
                  ),
                  const SizedBox(height: 32),

                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: PortfolioTagsSection(
                      tagController: viewModel.tagController,
                      tags: viewModel.tags,
                      onAddTag: viewModel.addTag,
                      onRemoveTag: viewModel.removeTag,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildActionButtons(viewModel),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const CommonBottomNavBar(),
        ),
      ),
    );
  }

  /// 하단 액션 버튼 (임시저장, 발행)을 만드는 헬퍼 위젯
  Widget _buildActionButtons(PortfolioEditViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 48,
          child: TextButton(
            onPressed: viewModel.isLoading
                ? null
                : () => viewModel.savePortfolio('draft'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text('임시저장', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: PrimaryActionButton(
            text: '발행',
            isFullWidth: false,
            isLoading: viewModel.isLoading,
            onPressed: () => viewModel.savePortfolio('published'),
          ),
        ),
      ],
    );
  }
}
