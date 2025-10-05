// [파일경로/파일명] lib/presentation/screens/showhost/sections/file_attachment_section.dart 파일이 수정되었습니다.
import 'package:flutter/material.dart';

class FileAttachmentSection extends StatelessWidget {
  // [수정] ViewModel 대신 필요한 속성과 콜백 함수를 직접 받도록 변경합니다.
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final String? fileName;

  const FileAttachmentSection({
    super.key,
    required this.onPickFile,
    required this.onRemoveFile,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '파일 첨부',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPickFile, // [수정] 전달받은 콜백 함수 사용
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.0),
            ),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: onPickFile, // [수정] 전달받은 콜백 함수 사용
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('파일 선택'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? '선택된 파일 없음', // [수정] 전달받은 파일 이름 사용
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fileName != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                if (fileName != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: onRemoveFile, // [수정] 전달받은 콜백 함수 사용
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
