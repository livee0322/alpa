import 'package:flutter/material.dart';

// 탭 가능한 각 아이템 사이에 구분선이 있는 리스트를 생성하는 공통 위젯
class DividedListView extends StatelessWidget {
  final List<Widget> children;

  const DividedListView({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 0.3,
      ),
    );
  }
}

// DividedListView 내에서 사용될 개별 리스트 아이템
class DividedListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const DividedListItem({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: child,
      ),
    );
  }
}
