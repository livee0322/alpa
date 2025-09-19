import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/screens/model/vm/model_list_view_model.dart';
import 'package:livee/presentation/styles/app_colors.dart';
import 'package:livee/presentation/widgets/loading_overlay.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';
import 'package:provider/provider.dart';
import 'package:livee/domain/models/model.dart';

class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelListViewModel(),
      child: Consumer<ModelListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            // [수정] LoadingOverlay를 사용하여 전체 화면 로딩 상태를 표시
            body: LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: _buildModelList(context, viewModel),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => GoRouter.of(context).go('/model-edit'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  // 모델 목록과 '더 보기' 버튼을 포함한 화면의 본문을 구성
  Widget _buildModelList(BuildContext context, ModelListViewModel viewModel) {
    if (viewModel.models.isEmpty && !viewModel.isLoading) {
      return const Center(child: Text('등록된 모델이 없습니다.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        GridView.builder(
          shrinkWrap: true, // ListView 안에서 사용하기 위해 설정
          physics: const NeverScrollableScrollPhysics(), // 부모 스크롤과 충돌 방지
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2열 그리드
            crossAxisSpacing: 12, // 카드 좌우 간격
            mainAxisSpacing: 12, // 카드 상하 간격
            childAspectRatio: 0.65, // 카드의 가로세로 비율
          ),
          itemCount: viewModel.models.length,
          itemBuilder: (context, index) {
            final model = viewModel.models[index];
            return _buildModelCard(context, model);
          },
        ),
        const SizedBox(height: 24),
        // [추가] '더 보기' 버튼
        if (viewModel.hasMore) _buildLoadMoreButton(context, viewModel),
      ],
    );
  }

  // 개별 모델 정보를 표시하는 직각 모서리 카드
  Widget _buildModelCard(BuildContext context, Model model) {
    return StandardContentCard(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.zero, // 직각 모서리
      onTap: () {
        // TODO: 모델 상세 페이지로 이동
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1, // 1:1 비율 이미지
            child: Image.network(
              model.mainThumbnailUrl ?? 'https://picsum.photos/seed/${model.id}/200/200',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.disabled),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.nickname ?? '이름 없음',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    model.oneLineIntro ?? '소개 준비 중',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '프로필 상세보기 >',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // '더 보기' 버튼 UI
  Widget _buildLoadMoreButton(BuildContext context, ModelListViewModel viewModel) {
    return Center(
      child: viewModel.isLoadingMore
          ? const CircularProgressIndicator() // 추가 로딩 중일 때
          : OutlinedButton.icon(
              icon: const Icon(Icons.more_horiz),
              label: const Text('더 보기'),
              onPressed: viewModel.fetchNextPage, // ViewModel의 다음 페이지 로딩 함수 호출
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textGrey,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
    );
  }
}
