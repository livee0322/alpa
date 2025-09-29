import 'package:flutter/material.dart';
import 'package:livee/domain/models/portfolio.dart';

/// '제안 보내기' UI를 담당하는 바텀시트 위젯
class ProposalBottomSheet extends StatelessWidget {
  final Portfolio portfolio; // 제안할 대상의 포트폴리오 정보

  const ProposalBottomSheet({
    super.key,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: 3단계에서 UI를 상세하게 구현할 예정입니다.
    return Container(
      height: MediaQuery.of(context).size.height * 0.8, // 화면의 80% 높이
      color: Colors.white,
      child: Center(
        child: Text('${portfolio.nickname ?? "쇼호스트"}님에게 제안하기'),
      ),
    );
  }
}
