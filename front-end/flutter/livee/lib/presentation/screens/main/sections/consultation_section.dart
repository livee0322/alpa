import 'package:flutter/material.dart';
import 'package:livee/presentation/widgets/standard_content_card.dart';

class ConsultationSection extends StatelessWidget {
  const ConsultationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StandardContentCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '무료 상담',
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '지금 바로 라이브 커머스 시작해보세요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '기획 · 섭외 · 계약 · 결제까지 도와드립니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  icon: Icons.campaign_outlined,
                  label: '공고 올리기',
                  onPressed: () {
                    // TODO: 공고 올리기 페이지로 이동
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildButton(
                  icon: Icons.chat_bubble_outline,
                  label: '빠른 문의',
                  onPressed: () {
                    // TODO: 빠른 문의 기능 구현
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF374151),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
