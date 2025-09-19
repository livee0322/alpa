// [파일경로/파일명] lib/presentation/screens/main/top_bar_shell_screen.dart 파일이 수정되었습니다.

import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/common_top_tab_bar.dart';

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
    return Column(
      children: [
        CommonTopTabBar(currentPath: location),
        Expanded(
          child: child,
        ),
      ],
    );
  }
}
