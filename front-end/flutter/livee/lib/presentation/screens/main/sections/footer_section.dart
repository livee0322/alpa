import 'package:flutter/material.dart';
import 'package:livee/presentation/styles/app_colors.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      color: AppColors.footerColor,
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/liveelogo.png',
                height: 24,
              ),
              Text('브랜드와 쇼호스트(모델)를 원스톱으로 연결하는 플랫폼'),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text(
                '이용약관',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 16),
              Text(
                '개인정보처리방침',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 16),
              Text(
                '환불/취소정책',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 16),
              Text(
                '고객센터',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  text: '상호',
                  children: [
                    const TextSpan(
                      text: ' 라이비',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 16),
              Text.rich(
                TextSpan(
                  text: '대표',
                  children: [
                    const TextSpan(
                      text: ' 이태웅',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 16),
              Text.rich(
                TextSpan(
                  text: '사업자등록번호',
                  children: [
                    const TextSpan(
                      text: ' 701-31-01824',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  text: '통신판매업 신고',
                  children: [
                    const TextSpan(
                      text: ' 미대상(간이과세자)',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text.rich(
                TextSpan(
                  text: '대표 이메일',
                  children: [
                    const TextSpan(
                      text: ' livee0720@naver.com',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 16),
              Text.rich(
                TextSpan(
                  text: '연락처',
                  children: [
                    const TextSpan(
                      text: ' 010-7561-6564',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
