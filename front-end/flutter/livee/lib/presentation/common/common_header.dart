import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/common/custom_toast.dart';
import 'package:remixicon/remixicon.dart';

class CommonHeader extends StatelessWidget {
  final bool isLoggedIn;

  const CommonHeader({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 60,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => GoRouter.of(context).go('/'),
            child: Image.asset(
              'assets/images/liveelogo.png',
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          // 오른쪽 부분을 아이콘 버튼 그룹으로 변경
          Row(
            children: [
              // 알림
              IconButton(
                icon: const Icon(RemixIcons.notification_3_line),
                onPressed: () => showCustomToast(
                  context,
                  '준비중인 기능입니다.',
                  type: ToastType.info,
                ),
              ),
              // 검색
              IconButton(
                icon: const Icon(RemixIcons.search_line),
                onPressed: () => showCustomToast(
                  context,
                  '준비중인 기능입니다.',
                  type: ToastType.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
