import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:leavify/core/utils/components/container/my_app_container.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/features/Leave/models/general/leave_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// DOCUMENTS CARD -----------------------------------------
class DocumentsCard extends StatelessWidget {
  final List<LeaveDocument> documents;
  final bool enableDelete;
  final ValueChanged<int>? onDelete;
  final String title;

  const DocumentsCard({
    super.key,
    required this.documents,
    this.enableDelete = false,
    this.onDelete,
    this.title = 'Attached Documents',
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const SizedBox.shrink();

    return _InfoCard(
      title: title,
      children: documents.asMap().entries.map((entry) {
        final index = entry.key;
        final doc = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: InkWell(
            onTap: () => _showDocumentViewer(context, doc),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _getDocumentIcon(doc.docType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFileName(doc.docPath),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          doc.docType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (enableDelete)
                    GestureDetector(
                      onTap: () => onDelete?.call(index),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.visibility,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _getDocumentIcon(String docType) {
    IconData iconData;
    Color iconColor;
    switch (docType.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red.shade700;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        iconData = Icons.image;
        iconColor = Colors.green.shade700;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue.shade700;
        break;
      default:
        iconData = Icons.attach_file;
        iconColor = Colors.grey.shade700;
    }
    return Icon(iconData, size: 20, color: iconColor);
  }

  String _getFileName(String docPath) => docPath.split('/').last;

  void _showDocumentViewer(BuildContext context, LeaveDocument doc) {
    showDialog(
      context: context,
      builder: (context) => DocumentViewerDialog(document: doc),
    );
  }
}

// DOCUMENT VIEWER DIALOG ---------------------------------
class DocumentViewerDialog extends StatefulWidget {
  final LeaveDocument document;
  const DocumentViewerDialog({super.key, required this.document});

  @override
  State<DocumentViewerDialog> createState() => _DocumentViewerDialogState();
}

class _DocumentViewerDialogState extends State<DocumentViewerDialog> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  dynamic _documentBytes;
  String? _documentUrl;

  @override
  void initState() {
    super.initState();
    _initializeDocument();
  }

  Future<void> _initializeDocument() async {
    final fileUrl = '${ApiEndpoints.baseUrl}/${widget.document.docPath}';
    _documentUrl = fileUrl;

    final docType = widget.document.docType.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(docType)) {
      setState(() => _isLoading = false);
    } else {
      await _loadDocumentBytes();
    }
  }

  Future<void> _loadDocumentBytes() async {
    if (_documentUrl == null) return;
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      final response = await http.get(Uri.parse(_documentUrl!));

      if (response.statusCode == 200) {
        setState(() {
          _documentBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        throw HttpException('Failed to load document: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _downloadDocument() async {
    if (_documentUrl == null) return;
    try {
      final response = await http.get(Uri.parse(_documentUrl!));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = _documentUrl!.split('/').last;
        final filePath = '${dir.path}/$fileName';
        await File(filePath).writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Downloaded to: $filePath')));
        }

        await OpenFilex.open(filePath);
      } else {
        throw HttpException('Failed to download: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.document.docPath.split('/').last;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildHeader(colorScheme, fileName),
            Expanded(child: _buildDocumentContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, String fileName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(_getDocumentIcon(), color: colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load document'),
            const SizedBox(height: 8),
            Text(_errorMessage ?? ''),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDocumentBytes,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _downloadDocument,
              icon: const Icon(Icons.download),
              label: const Text('Download'),
            ),
          ],
        ),
      );
    }

    final docType = widget.document.docType.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(docType)) {
      return Image.network(_documentUrl!, fit: BoxFit.contain);
    } else if (docType == 'pdf') {
      return SfPdfViewer.network(_documentUrl!);
    } else {
      return _buildGenericViewer();
    }
  }

  Widget _buildGenericViewer() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _downloadDocument,
        icon: const Icon(Icons.download),
        label: const Text('Download File'),
      ),
    );
  }

  IconData _getDocumentIcon() {
    switch (widget.document.docType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// SIMPLE INFO CARD WRAPPER -------------------------------
class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return MyAppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
