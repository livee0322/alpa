import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/styles/app_colors.dart';

class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '모델 페이지 (구현 예정)',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).go('/model-edit'),
        backgroundColor: AppColors.primary, // '퍼스트 컬러' (기본색)를 배경색으로 지정합니다.
        child: const Icon(
          Icons.add,
          color: Colors.white, // 아이콘 색상은 흰색으로 지정합니다.
        ),
      ),
    );
  }
}
