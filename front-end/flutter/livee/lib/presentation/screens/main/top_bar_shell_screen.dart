import 'package:flutter/material.dart';
import 'package:livee/presentation/common/common_top_tab_bar.dart';

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
