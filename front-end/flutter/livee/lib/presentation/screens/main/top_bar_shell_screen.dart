// [파일경로/파일명] lib/presentation/screens/main/top_bar_shell_screen.dart 파일이 수정되었습니다.

import 'package:flutter/material.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:livee/presentation/widgets/common_header.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';
import 'package:provider/provider.dart';

class TopBarShellScreen extends StatelessWidget {
  final Widget child;
  final String location;

  const TopBarShellScreen({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CommonHeader(isLoggedIn: authProvider.isLoggedIn);
            },
          ),
          CommonTopTabBar(currentPath: location),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
