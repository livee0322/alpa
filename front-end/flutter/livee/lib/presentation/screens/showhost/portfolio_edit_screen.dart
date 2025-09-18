import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/vm/portfolio_edit_view_model.dart';
import 'package:livee/presentation/screens/showhost/sections/basic_info_section.dart';
import 'package:livee/presentation/screens/showhost/sections/link_settings_section.dart';
import 'package:livee/presentation/screens/showhost/sections/preview_section.dart';
import 'package:livee/presentation/screens/showhost/sections/recent_live_section.dart';
import 'package:livee/presentation/screens/showhost/sections/selection_info_section.dart';
import 'package:livee/presentation/screens/showhost/sections/sub_thumbnail_section.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';
import 'package:livee/presentation/widgets/section_title.dart';
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
          body: _buildBody(context, viewModel),
        ),
      ),
    );
  }

  /// 화면의 본문(Body) UI를 구성하는 헬퍼 위젯
  Widget _buildBody(BuildContext context, PortfolioEditViewModel viewModel) =>
      Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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

                  // 서브 썸네일
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

                  // 기본 정보 섹션
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

                  // 선택 정보 섹션
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

                  // 최근 라이브 링크 섹션
                  StandardContentCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: '최근 라이브 링크'),
                        RecentLiveSection(
                          controllers: viewModel.recentLiveControllers,
                          onAdd: viewModel.addRecentLiveLink,
                          onRemove: viewModel.removeRecentLiveLink,
                        ),
                      ],
                    ),
                  ),

                  // 링크 & 공개설정 섹션
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
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      );

  /// 하단 액션 버튼 (임시저장, 발행)을 만드는 헬퍼 위젯
  Widget _buildActionButtons(PortfolioEditViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: PrimaryActionButton(
            text: '저장',
            isFullWidth: false,
            isLoading: viewModel.isLoading,
            onPressed: () => viewModel.savePortfolio(),
          ),
        ),
      ],
    );
  }
}
