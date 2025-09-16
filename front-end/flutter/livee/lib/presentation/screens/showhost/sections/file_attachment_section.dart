import 'package:flutter/material.dart';
import 'package:livee/presentation/screens/showhost/vm/portfolio_edit_view_model.dart';

class FileAttachmentSection extends StatelessWidget {
  final PortfolioEditViewModel viewModel;
  const FileAttachmentSection({super.key, required this.viewModel});

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
          onTap: viewModel.pickFileForCache,
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
                  onPressed: viewModel.pickFileForCache,
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
                    viewModel.attachedFileName ?? '선택된 파일 없음',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: viewModel.attachedFileName != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
                if (viewModel.attachedFileName != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: viewModel.removeAttachedFile,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
