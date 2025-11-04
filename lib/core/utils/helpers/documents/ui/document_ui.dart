import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/container/my_app_container.dart';
import 'package:leavify/core/utils/helpers/documents/document_helper.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';

class DocumentUploadSection extends StatelessWidget {
  final LeaveViewModel leaveViewModel;
  final BuildContext parentContext; // needed for pickDocuments dialog

  const DocumentUploadSection({
    Key? key,
    required this.leaveViewModel,
    required this.parentContext,
  }) : super(key: key);

  Future<void> _pickDocuments() async {
    final updatedFiles = await DocumentHelper.pickDocuments(
      parentContext,
      leaveViewModel.selectedDocuments,
    );
    leaveViewModel.updateSelectedDocuments(updatedFiles);
  }

  void _removeDocument(int index) {
    final updatedFiles = DocumentHelper.removeDocument(
      leaveViewModel.selectedDocuments,
      index,
    );
    leaveViewModel.updateSelectedDocuments(updatedFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickDocuments,
          child: MyAppContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'PDF, DOC, JPG, PNG up to 10MB',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        if (leaveViewModel.selectedDocuments.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSelectedDocumentsList(),
        ],
      ],
    );
  }

  Widget _buildSelectedDocumentsList() {
    return MyAppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Selected Documents',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(leaveViewModel.selectedDocuments.length, (index) {
            final document = leaveViewModel.selectedDocuments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.highlightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      leaveViewModel.getFileIcon(document.extension ?? ''),
                      color: AppColors.highlightBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          leaveViewModel.formatFileSize(document.size),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeDocument(index),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
