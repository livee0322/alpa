import 'package:flutter/material.dart';

// 캠페인 상세 화면 하단에 고정되는 액션 버튼 바
class DetailStickyBottomBar extends StatelessWidget {
  final String priceLabel;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const DetailStickyBottomBar({
    super.key,
    required this.priceLabel,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Container를 사용하여 그림자와 경계선을 추가
    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        10,
        14,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            offset: Offset(0, -8),
            blurRadius: 22,
          )
        ],
      ),
      child: Row(
        children: [
          // 가격 정보
          Expanded(
            child: Text(
              priceLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          // 메인 액션 버튼
          ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(148, 48),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
