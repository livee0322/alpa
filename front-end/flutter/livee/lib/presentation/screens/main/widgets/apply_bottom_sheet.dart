import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/domain/models/campaign.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/screens/main/vm/apply_view_model.dart';
import 'package:livee/presentation/widgets/common_prompt_dialog.dart';
import 'package:livee/presentation/widgets/custom_toast.dart';
import 'package:provider/provider.dart';

/// '지원하기' 버튼 클릭 시 나타나는 바텀 시트 위젯
class ApplyBottomSheet extends StatelessWidget {
  final Campaign campaign;

  const ApplyBottomSheet({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    return ChangeNotifierProvider(
      create: (_) => ApplyViewModel(),
      child: Consumer<ApplyViewModel>(
        builder: (context, viewModel, child) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 10),
                _buildWarningMessage(),
                const SizedBox(height: 20),
                _buildPortfolioSelector(context, viewModel),
                const SizedBox(height: 20),
                _buildMessageInput(messageController),
                const SizedBox(height: 20),
                _buildActionButtons(context, viewModel, messageController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 바텀 시트 헤더 (제목, 닫기 버튼)
  Widget _buildHeader(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '지원하기',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );

  /// 주의사항 메시지
  Widget _buildWarningMessage() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F5FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E5FF)),
        ),
        child: RichText(
          text: const TextSpan(
            // 기본 텍스트 스타일
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4338CA),
              fontFamily: 'SUIT', // 전체적인 폰트를 통일하기 위해 추가
            ),
            children: <TextSpan>[
              TextSpan(
                text:
                    '연락처·이메일 직접 기재는 금지됩니다. 라이비 외 채널(개인 메신저, 이메일 등)로 계약을 진행할 경우 ',
              ),
              TextSpan(
                text: '대금 미지급 등 불리한 문제가 발생',
                // 굵게(bold) 스타일 적용
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '할 수 있습니다. 모든 커뮤니케이션은 라이비 내에서 진행해주세요.',
                // 굵게(bold) 스타일 적용
              ),
            ],
          ),
        ),
      );

  /// 포트폴리오 선택 섹션
  Widget _buildPortfolioSelector(
          BuildContext context, ApplyViewModel viewModel) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 포트폴리오 선택',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.errorMessage != null)
            Center(child: Text(viewModel.errorMessage!))
          else if (viewModel.userPortfolios.isNotEmpty)
            Column(
              children: viewModel.userPortfolios.map(
                (portfolio) {
                  final isSelected =
                      viewModel.selectedPortfolioId == portfolio.id;
                  return GestureDetector(
                    onTap: () => viewModel.selectPortfolio(portfolio.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: portfolio.id,
                            groupValue: viewModel.selectedPortfolioId,
                            onChanged: (value) =>
                                viewModel.selectPortfolio(value),
                            activeColor: const Color(0xFF6C63FF),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              portfolio.mainThumbnailUrl ??
                                  'https://picsum.photos/seed/${portfolio.id}/60/60',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 48),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  portfolio.nickname ?? '무명',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  portfolio.oneLineIntro ?? '한 줄 소개가 없습니다.',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  '등록된 포트폴리오가 없습니다.\n마이페이지에서 먼저 포트폴리오를 등록해주세요.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );

  /// 메시지 입력 필드
  Widget _buildMessageInput(TextEditingController controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '메시지 (선택)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: controller,
            placeholder: '간단한 자기소개와 지원 이유를 남겨주세요. 연락처/이메일은 적지 마세요.',
            maxLines: 5,
            minLines: 3,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      );

  /// 하단 액션 버튼 (취소, 지원 보내기)
  Widget _buildActionButtons(BuildContext context, ApplyViewModel viewModel,
          TextEditingController messageController) =>
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('취소',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final errorMessage = await viewModel.submitApplication(
                    campaign.id!, messageController.text);
                if (context.mounted) {
                  if (errorMessage == null) {
                    print("✅ (A) 지원 성공! 바텀 시트에서 true를 반환합니다.");
                    // [수정] 성공 시 true 값을 반환하며 팝업 닫기
                    Navigator.pop(context, true);
                    showCustomToast(context, '지원이 완료되었습니다!',
                        type: ToastType.success);
                  } else {
                    showCustomToast(context, errorMessage,
                        type: ToastType.error);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('지원 보내기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
}

/// 전역에서 호출할 수 있는 바텀 시트 표시 함수
Future<bool?> showApplyBottomSheet(BuildContext context, Campaign campaign) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  if (!authProvider.isLoggedIn) {
    showCommonPromptDialog(
      context: context,
      title: '로그인이 필요합니다',
      content: '공고에 지원하려면 로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?',
      confirmText: '로그인',
    ).then((confirmed) {
      if (confirmed == true) {
        GoRouter.of(context).go('/login');
      }
    });
    return Future.value(null); // 비회원일 경우 null을 반환
  }

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ApplyBottomSheet(campaign: campaign),
  );
}
