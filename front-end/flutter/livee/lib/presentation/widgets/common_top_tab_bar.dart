import 'package:flutter/material.dart';

class CommonTopTabBar extends StatelessWidget {
  const CommonTopTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F3F5),
            width: 1.0,
          ),
        ),
      ),
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          children: [
            _buildTab('숏클립', true),
            _buildTab('쇼핑라이브', false),
            _buildTab('뉴스', false),
            _buildTab('이벤트', false),
            _buildTab('서비스', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Colors.transparent : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF6C63FF) : const Color(0xFF374151),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
