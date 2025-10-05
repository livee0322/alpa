import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/image_provider.dart';
import 'package:livee/presentation/screens/portfolio/models/portfolio_image.dart';
import 'package:livee/presentation/screens/portfolio/sections/preview_section.dart';
import 'package:livee/presentation/screens/portfolio/sections/sub_thumbnail_section.dart';
import 'package:livee/presentation/screens/studio/vm/studio_edit_view_model.dart';
import 'package:livee/presentation/screens/studio/widgets/studio_description_section.dart';
import 'package:livee/presentation/screens/studio/widgets/weekly_schedule_section.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/buttons/primary_action_button.dart';
import 'package:livee/presentation/widgets/custom_text_form_field.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/presentation/widgets/section_title.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

/// '스튜디오' 정보를 등록하고 관리하는 페이지
class StudioEditScreen extends StatelessWidget {
  const StudioEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudioEditViewModel(context),
      child: Consumer<StudioEditViewModel>(
        builder: (context, viewModel, child) {
          final imageHandler = context.watch<ImageHandlerProvider>();
          return LoadingOverlay(
            isLoading: viewModel.isLoading || imageHandler.isLoading,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.back),
                  onPressed: () => html.window.history.go(-1),
                ),
                title: const Text('BYHEN・관리자'),
                centerTitle: true,
                backgroundColor: AppColors.white,
                actions: const [],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 1. 프리뷰 섹션 (재사용)
                    PreviewSection(
                      mainThumbnailSource: viewModel.mainThumbnailSource,
                      backgroundImageSource: viewModel.backgroundImageSource,
                      nicknameController: viewModel.brandNameController, // 브랜드명을 닉네임처럼 표시
                      onPickMainThumbnail: () async {
                        final bytes = await imageHandler.pickImage();
                        if (bytes != null) {
                          viewModel.setMainThumbnail(PortfolioImage(localBytes: bytes));
                        }
                      },
                      onPickBackgroundImage: () async {
                        final bytes = await imageHandler.pickImage();
                        if (bytes != null) {
                          viewModel.setBackgroundImage(PortfolioImage(localBytes: bytes));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. 서브 썸네일 섹션 (재사용)
                    StandardContentCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(title: '서브 썸네일(최대 5장)'),
                          const SizedBox(height: 12),
                          SubThumbnailSection(
                            sources: viewModel.subThumbnailSources,
                            // [수정] onAddImage 콜백에서 ImageHandlerProvider를 사용합니다.
                            onAddImage: () async {
                              final bytes = await imageHandler.pickImage(context: context, aspectRatio: 1.0);
                              if (bytes != null) {
                                viewModel.addSubThumbnail(PortfolioImage(localBytes: bytes));
                              }
                            },
                            onRemoveImage: viewModel.removeSubThumbnail,
                            maxImages: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. 스튜디오 정보 섹션 (새로운 구성)
                    _buildStudioInfoSection(viewModel),
                    const SizedBox(height: 16),

                    _buildContactSection(viewModel),
                    const SizedBox(height: 16),

                    // 3x3 갤러리 섹션
                    _buildGallerySection(context, viewModel),
                    const SizedBox(height: 16),

                    _buildScheduleSection(viewModel),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PrimaryActionButton(
                        text: '저장',
                        onPressed: viewModel.saveStudio,
                        isFullWidth: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 기본 정보 + 상세 소개를 포함하는 새로운 정보 섹션
  Widget _buildStudioInfoSection(StudioEditViewModel viewModel) {
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '기본 정보'),
          CustomTextFormField(controller: viewModel.brandNameController, label: '브랜드명 *', hintText: '예) BYHEN'),
          const SizedBox(height: 16),
          StudioDescriptionSection(viewModel: viewModel), // 새로 만든 상세 정보 섹션 위젯
        ],
      ),
    );
  }

  Widget _buildContactSection(StudioEditViewModel viewModel) {
    return StandardContentCard(
      child: Column(
        children: [
          CustomTextFormField(
            controller: viewModel.phoneController,
            label: '전화',
            hintText: '02-000-0000',
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            controller: viewModel.emailController,
            label: '이메일',
            hintText: 'hello@brand.com',
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            controller: viewModel.kakaoController,
            label: '카카오',
            hintText: 'https://pf.kakao.com/...',
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            controller: viewModel.addressController,
            label: '주소',
            hintText: '예) 서울 성수동 ...',
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            controller: viewModel.mapUrlController,
            label: '지도 링크',
            hintText: '네이버/카카오 지도 URL',
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context, StudioEditViewModel viewModel) {
    final imageHandler = Provider.of<ImageHandlerProvider>(context, listen: false);
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '갤러리(최대 9장)'),
          const SizedBox(height: 12),
          SubThumbnailSection(
            sources: viewModel.galleryImageSources,
            // [수정] onAddImage 콜백에서 ImageHandlerProvider를 사용합니다.
            onAddImage: () async {
              final bytes = await imageHandler.pickImage(context: context, aspectRatio: 1.0);
              if (bytes != null) {
                viewModel.addGalleryImage(PortfolioImage(localBytes: bytes));
              }
            },
            onRemoveImage: viewModel.removeGalleryImage,
            maxImages: 9,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(StudioEditViewModel viewModel) {
    return StandardContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '스케줄'),
          const SizedBox(height: 12),
          // WeeklyScheduleSection 위젯을 사용하고, viewModel을 전달
          WeeklyScheduleSection(viewModel: viewModel),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('안내\n・시간 버튼을 눌러 예약 가능한 시간을 설정하세요.\n・파란색은 예약 가능, 회색은 예약 불가능 상태입니다.'),
          ),
        ],
      ),
    );
  }
}
