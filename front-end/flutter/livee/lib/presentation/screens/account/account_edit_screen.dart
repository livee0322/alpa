import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_bottom_nav_bar.dart';

// '내 정보 변경'을 위한 임시 화면
class AccountEditScreen extends StatelessWidget {
  const AccountEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보 변경'),
      ),
      body: const Center(
        child: Text(
          '내 정보 변경 화면 (구현 예정)',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: const CommonBottomNavBar(),
    );
  }
}
