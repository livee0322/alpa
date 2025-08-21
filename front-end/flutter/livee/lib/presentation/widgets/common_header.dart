import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:livee/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CommonHeader extends StatelessWidget {
  final bool isLoggedIn;

  const CommonHeader({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 60,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => GoRouter.of(context).go('/'),
            child: Image.asset(
              'assets/images/liveelogo.png',
            ),
          ),
          isLoggedIn
              ? TextButton(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    GoRouter.of(context).go('/login');
                  },
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () => GoRouter.of(context).go('/login'),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
