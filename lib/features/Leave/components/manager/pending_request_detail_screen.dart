import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' hide Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide Uint8List;
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/features/Leave/models/general/leave_document.dart';
import 'package:leavify/features/Leave/models/response/get_leave_by_id_response.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PendingRequestDetailScreen extends StatefulWidget {
  final String leaveId;

  const PendingRequestDetailScreen({super.key, required this.leaveId});

  @override
  State<PendingRequestDetailScreen> createState() =>
      _PendingRequestDetailScreenState();
}

class _PendingRequestDetailScreenState
    extends State<PendingRequestDetailScreen> {
  final TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLeaveDetails();
    });
  }

  Future<void> _initializeLeaveDetails() async {
    final viewModel = Provider.of<LeaveViewModel>(context, listen: false);
    await viewModel.getLeaveById(leaveId: widget.leaveId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Consumer<LeaveViewModel>(
        builder: (context, leaveViewModel, child) {
          if (leaveViewModel.isLoading &&
              leaveViewModel.selectedLeaveById == null) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          // if (leaveViewModel.errorMessage != null) {
          //   return _buildErrorState(leaveViewModel.errorMessage!);
          // }

          if (leaveViewModel.selectedLeaveById == null) {
            return Center(
              child: Text(
                'No leave details found',
                style: TextStyle(color: colorScheme.onBackground),
              ),
            );
          }

          return _buildLeaveDetailsContent(leaveViewModel.selectedLeaveById!);
        },
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildLeaveDetailsContent(GetLeaveByIdResponse leaveData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _EmployeeHeaderCard(leaveData: leaveData),
          const SizedBox(height: 20),
          _LeaveRequestDetailsCard(leaveData: leaveData),
          const SizedBox(height: 16),
          if (leaveData.leaveDetails.reason.isNotEmpty)
            _ReasonCard(reason: leaveData.leaveDetails.reason),
          if (leaveData.leaveDetails.reason.isNotEmpty)
            const SizedBox(height: 16),
          if (leaveData.leaveDetails.isCompOff &&
              leaveData.leaveDetails.compDates.isNotEmpty)
            _CompOffDatesCard(compOffDates: leaveData.leaveDetails.compDates),
          if (leaveData.leaveDetails.isCompOff &&
              leaveData.leaveDetails.compDates.isNotEmpty)
            const SizedBox(height: 16),
          if (leaveData.leaveDetails.documents.isNotEmpty)
            DocumentsCard(documents: leaveData.leaveDetails.documents),
          if (leaveData.leaveDetails.documents.isNotEmpty)
            const SizedBox(height: 16),
          if (leaveData.leaveDetails.reqStatusTracking.isNotEmpty)
            StatusTrackingCard(
              statusTracking: leaveData.leaveDetails.reqStatusTracking,
            ),
          if (leaveData.leaveDetails.reqStatusTracking.isNotEmpty)
            const SizedBox(height: 16),
          if (leaveData.leaveDetails.isEscalated &&
              leaveData.leaveDetails.escalationDet != null)
            const SizedBox(height: 16),
          _CommentsCard(commentsController: _commentsController),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<LeaveViewModel>(
      builder: (context, leaveViewModel, child) {
        final homeViewModel = context.read<HomeViewModel>();
        final leave = leaveViewModel.selectedLeaveById;
        final latestStatus = leave?.currentUserAction?.latestStatus
            .toLowerCase();
        final userRole = homeViewModel.userRole.toLowerCase();

        Widget buttons;

        // If HR → only Resolve button
        if (userRole == 'hr') {
          buttons = Expanded(
            child: _ResolveButton(
              onPressed: leaveViewModel.isLoading
                  ? null
                  : _handleProcessEscalated,
              isLoading: leaveViewModel.isProcessEscalatedLeaveLoading,
            ),
          );
        } else {
          // Existing logic for managers
          switch (latestStatus) {
            case 'approved':
              buttons = Expanded(
                child: _RejectButton(
                  onPressed: leaveViewModel.isLoading ? null : _handleReject,
                  isLoading: leaveViewModel.isRejectLoading,
                ),
              );
              break;

            case 'rejected':
              buttons = Expanded(
                child: _ApproveButton(
                  onPressed: leaveViewModel.isLoading ? null : _handleApprove,
                  isLoading: leaveViewModel.isApproveLoading,
                ),
              );
              break;

            default:
              buttons = Row(
                children: [
                  Expanded(
                    child: _RejectButton(
                      onPressed: leaveViewModel.isLoading
                          ? null
                          : _handleReject,
                      isLoading: leaveViewModel.isRejectLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ApproveButton(
                      onPressed: leaveViewModel.isLoading
                          ? null
                          : _handleApprove,
                      isLoading: leaveViewModel.isApproveLoading,
                    ),
                  ),
                ],
              );
              break;
          }
        }

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: buttons,
          ),
        );
      },
    );
  }

  Future<void> _handleApprove() async {
    final leaveViewModel = context.read<LeaveViewModel>();

    final success = await leaveViewModel.processLeaveRequest(
      leaveId: widget.leaveId,
      status: 'APPROVED',
      context: context,
      comment: _commentsController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            leaveViewModel.processLeaveError ?? 'Failed to approve request',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleProcessEscalated() async {
    if (_commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for rejection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final leaveViewModel = context.read<LeaveViewModel>();

    final success = await leaveViewModel.processEscalatedLeaveRequest(
      leaveId: widget.leaveId,
      comment: _commentsController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            leaveViewModel.processLeaveError ?? 'Failed to reject request',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleReject() async {
    if (_commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for rejection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final leaveViewModel = context.read<LeaveViewModel>();

    final success = await leaveViewModel.processLeaveRequest(
      leaveId: widget.leaveId,
      status: 'REJECTED',
      context: context,
      comment: _commentsController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            leaveViewModel.processLeaveError ?? 'Failed to reject request',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }
}

// MARK: - Employee Header Card
class _EmployeeHeaderCard extends StatelessWidget {
  final GetLeaveByIdResponse leaveData;

  const _EmployeeHeaderCard({required this.leaveData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                _getInitials(leaveData.employeeName),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            leaveData.employeeName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildBalanceInfo(),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  Widget _buildBalanceInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Balance Leaves: ${leaveData.balanceLeaves}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}

// MARK: - Leave Request Details Card
class _LeaveRequestDetailsCard extends StatelessWidget {
  final GetLeaveByIdResponse leaveData;

  const _LeaveRequestDetailsCard({required this.leaveData});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Leave Request Details',
      children: [
        _InfoRow(
          icon: Icons.category_outlined,
          label: 'Leave Type',
          value: leaveData.leaveDetails.type,
        ),
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Duration',
          value: _calculateDuration(),
        ),
        _InfoRow(
          icon: Icons.date_range_outlined,
          label: 'From Date',
          value: _formatDate(leaveData.leaveDetails.fromDate),
        ),
        _InfoRow(
          icon: Icons.date_range_outlined,
          label: 'To Date',
          value: _formatDate(leaveData.leaveDetails.toDate),
        ),
        _InfoRow(
          icon: Icons.schedule_outlined,
          label: 'Duration Type',
          value: leaveData.leaveDetails.isHalfDay ? 'Half Day' : 'Full Day',
        ),
        _InfoRow(
          icon: Icons.access_time_outlined,
          label: 'Applied On',
          value: _formatDateTime(leaveData.leaveDetails.createdAt),
        ),
        _InfoRow(
          icon: Icons.update_outlined,
          label: 'Last Updated',
          value: _formatDateTime(leaveData.leaveDetails.updatedAt),
        ),
        if (leaveData.willComplete20Days)
          _InfoRow(
            icon: Icons.warning_amber_outlined,
            label: 'Will Complete 20 Days',
            value: 'Yes',
            valueColor: Colors.orange,
          ),
      ],
    );
  }

  String _calculateDuration() {
    final days =
        leaveData.leaveDetails.toDate
            .difference(leaveData.leaveDetails.fromDate)
            .inDays +
        1;
    return '$days day${days > 1 ? 's' : ''}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}

// MARK: - Reason Card
class _ReasonCard extends StatelessWidget {
  final String reason;

  const _ReasonCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _InfoCard(
      title: 'Reason for Leave',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            reason,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: - Comp Off Dates Card
class _CompOffDatesCard extends StatelessWidget {
  final List<String> compOffDates;

  const _CompOffDatesCard({required this.compOffDates});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Compensation Off Dates',
      children: [
        ...compOffDates.map((dateStr) {
          final date = DateTime.parse(dateStr);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_available,
                  size: 16,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// MARK: - Documents Card
class DocumentsCard extends StatelessWidget {
  final List<LeaveDocument> documents;

  const DocumentsCard({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Attached Documents',
      children: documents.map((doc) {
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
                  Icon(Icons.visibility, color: Colors.blue.shade700, size: 20),
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

  String _getFileName(String docPath) {
    return docPath.split('/').last;
  }

  void _showDocumentViewer(BuildContext context, LeaveDocument doc) {
    showDialog(
      context: context,
      builder: (context) => DocumentViewerDialog(document: doc),
    );
  }
}

// Document Viewer Dialog
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
  dynamic _documentBytes; // Using dynamic to avoid type conflicts
  String? _documentUrl;

  @override
  void initState() {
    super.initState();
    _initializeDocument();
  }

  Future<void> _initializeDocument() async {
    // Build the full URL
    final fileUrl = '${ApiEndpoints.baseUrl}/${widget.document.docPath}';
    _documentUrl = fileUrl;

    // For images and PDFs that can be loaded directly via URL,
    // we might not need to fetch bytes immediately
    final docType = widget.document.docType.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(docType)) {
      // For images, we can try to load directly via URL first
      setState(() {
        _isLoading = false;
      });
    } else {
      // For other document types, load the bytes
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

      final uri = Uri.parse(_documentUrl!);
      final httpClient = HttpClient();

      try {
        // Add timeout to prevent hanging
        httpClient.connectionTimeout = const Duration(seconds: 30);

        final request = await httpClient.getUrl(uri);
        request.headers.set('Accept', '*/*');

        final response = await request.close();

        if (response.statusCode == 200) {
          // Get bytes as List<int> and store directly
          final bytes = await consolidateHttpClientResponseBytes(response);

          setState(() {
            _documentBytes = bytes;
            _isLoading = false;
          });
        } else {
          throw HttpException(
            'HTTP ${response.statusCode}: Failed to load document',
          );
        }
      } finally {
        httpClient.close();
      }
    } catch (e) {
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
      // You can implement download functionality here
      // For now, we'll show a snackbar with the URL
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download URL: $_documentUrl'),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _documentUrl!));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to download: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileName = widget.document.docPath.split('/').last;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(colorScheme, fileName),
            // Content
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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(_getDocumentIcon(), color: colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.document.docType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: colorScheme.onSurface),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading document...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    // Handle different document types
    final docType = widget.document.docType.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(docType)) {
      return _buildImageViewer();
    } else if (docType == 'pdf') {
      return _buildPdfViewer();
    } else {
      return _buildGenericViewer();
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadDocumentBytes,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _downloadDocument,
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    final String? displayUrl =
        _documentUrl ??
        (_documentBytes != null
            ? "data:image/jpeg;base64,${base64Encode(_documentBytes!)}"
            : null);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 5.0,
          clipBehavior: Clip.none,
          child: displayUrl != null
              ? Image.network(
                  displayUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImageError(),
                )
              : _buildImageError(),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image, size: 64, color: Colors.grey.withOpacity(0.7)),
        const SizedBox(height: 16),
        Text(
          'Failed to load image',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _downloadDocument,
          child: const Text('Download to View'),
        ),
      ],
    );
  }

  Widget _buildPdfViewer() {
    return SfPdfViewer.network(
      _documentUrl!,
      canShowScrollStatus: true,
      canShowPaginationDialog: true,
      onDocumentLoadFailed: (details) {
        setState(() {
          _hasError = true;
          _errorMessage = details.description;
        });
      },
    );
  }

  Widget _buildGenericViewer() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getDocumentIcon(),
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'Document Preview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This document type cannot be previewed in the app.\nDownload the file to view it with the appropriate application.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _downloadDocument,
              icon: const Icon(Icons.download),
              label: const Text('Download File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
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
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}

// MARK: - Status Tracking Card
class StatusTrackingCard extends StatelessWidget {
  final List<ReqStatusTracking> statusTracking;

  const StatusTrackingCard({super.key, required this.statusTracking});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Status History',
      children: [
        ...statusTracking.asMap().entries.map((entry) {
          final index = entry.key;
          final tracking = entry.value;
          final isLast = index == statusTracking.length - 1;

          return _TimelineItem(tracking: tracking, isLast: isLast);
        }),
      ],
    );
  }
}

// MARK: - Timeline Item
class _TimelineItem extends StatelessWidget {
  final ReqStatusTracking tracking;
  final bool isLast;

  const _TimelineItem({required this.tracking, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(tracking.status),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: colorScheme.onSurface.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tracking.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(tracking.status),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'By: ${tracking.processedBy}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(tracking.processedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              if (tracking.comment.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tracking.comment,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade600;
      case 'approved':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade600;
      case 'escalated':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}

// MARK: - Comments Card
class _CommentsCard extends StatelessWidget {
  final TextEditingController commentsController;

  const _CommentsCard({required this.commentsController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _InfoCard(
      title: 'Add Comments',
      children: [
        TextField(
          controller: commentsController,
          maxLines: 4,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Add any comments or feedback for the employee...',
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            filled: true,
            fillColor: colorScheme.onSurface.withOpacity(0.05),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Note: Comments are required when rejecting a request',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// MARK: - Reusable Info Card
class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// MARK: - Info Row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Action Buttons
class _RejectButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _RejectButton({this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.close_rounded),
      label: Text(isLoading ? 'Processing...' : 'Reject'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ResolveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ResolveButton({this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.close_rounded),
      label: Text(isLoading ? 'Processing...' : 'Resolve'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        side: const BorderSide(color: Colors.blueAccent, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ApproveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ApproveButton({this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.check_rounded),
      label: Text(isLoading ? 'Processing...' : 'Approve'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
