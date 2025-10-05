import 'package:flutter/material.dart';

// '최근 라이브 링크' 입력 필드 그룹을 관리하는 컨트롤러 클래스
class RecentLiveControllers {
  final TextEditingController titleController;
  final TextEditingController urlController;
  final TextEditingController dateController;

  RecentLiveControllers()
      : titleController = TextEditingController(),
        urlController = TextEditingController(),
        dateController = TextEditingController();

  void dispose() {
    titleController.dispose();
    urlController.dispose();
    dateController.dispose();
  }
}
