// pending_requests_screen.dart
import 'package:flutter/material.dart';

enum LeaveStatus { pending, approved, rejected, escalated }

class LeaveRequest {
  final String id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final DateTime appliedDate;
  final String employeeName;
  final String employeeId;
  final String department;
  final String? employeeAvatar;
  final List<String>? attachments;
  final int priority; // 1 = High, 2 = Medium, 3 = Low
  final int daysSinceApplied;

  LeaveRequest({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.appliedDate,
    required this.employeeName,
    required this.employeeId,
    required this.department,
    this.employeeAvatar,
    this.attachments,
    required this.priority,
    required this.daysSinceApplied,
  });
}

class PendingRequestsScreen extends StatefulWidget {

  const PendingRequestsScreen({
    super.key,
  });

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  List<LeaveRequest> _pendingRequests = [];
  List<LeaveRequest> _filteredRequests = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _generateDummyData();
    _filteredRequests = _pendingRequests;
  }

  void _generateDummyData() {
    _pendingRequests = [
      LeaveRequest(
        id: "REQ001",
        leaveType: "Annual Leave",
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        reason: "Family vacation planned for summer holidays with extended family gathering",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 2)),
        employeeName: "Alice Johnson",
        employeeId: "EMP001",
        department: "Marketing",
        priority: 2,
        daysSinceApplied: 2,
        attachments: ["vacation_itinerary.pdf"],
      ),
      LeaveRequest(
        id: "REQ002",
        leaveType: "Sick Leave",
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        reason: "Medical procedure scheduled and recovery time needed as per doctor's advice",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 1)),
        employeeName: "Bob Smith",
        employeeId: "EMP002",
        department: "Engineering",
        priority: 1,
        daysSinceApplied: 1,
        attachments: ["medical_certificate.pdf", "doctor_recommendation.pdf"],
      ),
      LeaveRequest(
        id: "REQ003",
        leaveType: "Personal Leave",
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 8)),
        reason: "Personal legal matters requiring court appearance and documentation",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 3)),
        employeeName: "Carol Davis",
        employeeId: "EMP003",
        department: "Finance",
        priority: 2,
        daysSinceApplied: 3,
      ),
      LeaveRequest(
        id: "REQ004",
        leaveType: "Emergency Leave",
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 2)),
        reason: "Family emergency - immediate family member hospitalization requiring care",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(hours: 6)),
        employeeName: "David Wilson",
        employeeId: "EMP004",
        department: "Operations",
        priority: 1,
        daysSinceApplied: 0,
        attachments: ["hospital_admission.pdf"],
      ),
      LeaveRequest(
        id: "REQ005",
        leaveType: "Maternity Leave",
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 120)),
        reason: "Maternity leave for childbirth and postnatal care according to company policy",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 5)),
        employeeName: "Emma Brown",
        employeeId: "EMP005",
        department: "HR",
        priority: 1,
        daysSinceApplied: 5,
        attachments: ["maternity_certificate.pdf", "doctor_note.pdf"],
      ),
      LeaveRequest(
        id: "REQ006",
        leaveType: "Study Leave",
        startDate: DateTime.now().add(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 16)),
        reason: "Professional certification examination for advanced project management",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 4)),
        employeeName: "Frank Garcia",
        employeeId: "EMP006",
        department: "IT",
        priority: 3,
        daysSinceApplied: 4,
        attachments: ["exam_registration.pdf"],
      ),
      LeaveRequest(
        id: "REQ007",
        leaveType: "Casual Leave",
        startDate: DateTime.now().add(const Duration(days: 12)),
        endDate: DateTime.now().add(const Duration(days: 12)),
        reason: "House relocation and moving activities requiring full day attention",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 6)),
        employeeName: "Grace Lee",
        employeeId: "EMP007",
        department: "Sales",
        priority: 3,
        daysSinceApplied: 6,
      ),
      LeaveRequest(
        id: "REQ008",
        leaveType: "Annual Leave",
        startDate: DateTime.now().add(const Duration(days: 21)),
        endDate: DateTime.now().add(const Duration(days: 28)),
        reason: "Wedding anniversary celebration and honeymoon trip to Europe",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 7)),
        employeeName: "Henry Martinez",
        employeeId: "EMP008",
        department: "Design",
        priority: 2,
        daysSinceApplied: 7,
        attachments: ["travel_booking.pdf"],
      ),
    ];

    // Sort by priority and days since applied
    _pendingRequests.sort((a, b) {
      if (a.priority != b.priority) {
        return a.priority.compareTo(b.priority);
      }
      return b.daysSinceApplied.compareTo(a.daysSinceApplied);
    });
  }

  void _filterRequests() {
    setState(() {
      _filteredRequests = _pendingRequests.where((request) {
        final matchesSearch = _searchQuery.isEmpty ||
            request.employeeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            request.leaveType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            request.department.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesFilter = _selectedFilter == 'All' ||
            (_selectedFilter == 'High Priority' && request.priority == 1) ||
            (_selectedFilter == 'Urgent' && request.daysSinceApplied >= 3) ||
            (_selectedFilter == 'Today' && request.startDate.day == DateTime.now().day);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _onRequestApproved(LeaveRequest request) {
    setState(() {
      _pendingRequests.removeWhere((r) => r.id == request.id);
      _filterRequests();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request.employeeName}\'s leave request approved'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _pendingRequests.add(request);
              _filterRequests();
            });
          },
        ),
      ),
    );
  }

  void _onRequestRejected(LeaveRequest request) {
    setState(() {
      _pendingRequests.removeWhere((r) => r.id == request.id);
      _filterRequests();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request.employeeName}\'s leave request rejected'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _pendingRequests.add(request);
              _filterRequests();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with search and filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Title and count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Requests',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          '${_filteredRequests.length} request${_filteredRequests.length != 1 ? 's' : ''} awaiting review',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_pendingRequests.where((r) => r.priority == 1).length} Urgent',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search bar
                TextField(
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterRequests();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by employee name, leave type, or department...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'High Priority',
                      'Urgent',
                      'Today',
                    ].map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                            _filterRequests();
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                          fontWeight: _selectedFilter == filter
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Requests list
          Expanded(
            child: _filteredRequests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRequests.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PendingRequestCard(
                    request: _filteredRequests[index],
                    onTap: () => _navigateToDetail(_filteredRequests[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? "No requests match your filters"
                : "No pending requests",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? "Try adjusting your search or filters"
                : "All caught up! No requests awaiting your review.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(LeaveRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PendingRequestDetailScreen(
          request: request,
          onApprove: () => _onRequestApproved(request),
          onReject: () => _onRequestRejected(request),
        ),
      ),
    );
  }
}

// Reusable Pending Request Card
class PendingRequestCard extends StatelessWidget {
  final LeaveRequest request;
  final VoidCallback onTap;

  const PendingRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (request.priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
      default:
        return Colors.green;
    }
  }

  String _getPriorityText() {
    switch (request.priority) {
      case 1:
        return "High Priority";
      case 2:
        return "Medium Priority";
      case 3:
      default:
        return "Low Priority";
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  int _getDuration() {
    return request.endDate.difference(request.startDate).inDays + 1;
  }

  String _getUrgencyText() {
    if (request.daysSinceApplied == 0) return "Applied today";
    if (request.daysSinceApplied == 1) return "Applied yesterday";
    return "Applied ${request.daysSinceApplied} days ago";
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();
    final isUrgent = request.daysSinceApplied >= 3 || request.priority == 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? priorityColor.withOpacity(0.3) : Colors.grey[200]!,
            width: isUrgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with employee info and priority
              Row(
                children: [
                  // Employee avatar placeholder
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        request.employeeName.split(' ').map((n) => n[0]).join(''),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Employee details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.employeeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${request.employeeId} • ${request.department}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(),
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Leave type and duration
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.leaveType,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_getDuration()} day${_getDuration() > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date range
              Row(
                children: [
                  Icon(
                    Icons.date_range_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Reason (truncated)
              Text(
                request.reason.length > 80
                    ? "${request.reason.substring(0, 80)}..."
                    : request.reason,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 16),

              // Bottom row with urgency and attachments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: isUrgent ? Colors.red : Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getUrgencyText(),
                        style: TextStyle(
                          color: isUrgent ? Colors.red : Colors.grey[500],
                          fontSize: 12,
                          fontWeight: isUrgent ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (request.attachments != null && request.attachments!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.attach_file,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${request.attachments!.length}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Tap to review",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Detailed screen for pending request review
class PendingRequestDetailScreen extends StatefulWidget {
  final LeaveRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PendingRequestDetailScreen({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<PendingRequestDetailScreen> createState() => _PendingRequestDetailScreenState();
}

class _PendingRequestDetailScreenState extends State<PendingRequestDetailScreen> {
  final TextEditingController _commentsController = TextEditingController();
  bool _isProcessing = false;

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatDateTime(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  int _getDuration() {
    return widget.request.endDate.difference(widget.request.startDate).inDays + 1;
  }

  Future<void> _handleApprove() async {
    setState(() => _isProcessing = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
      widget.onApprove();
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

    setState(() => _isProcessing = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
      widget.onReject();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Review Request',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Employee avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        widget.request.employeeName.split(' ').map((n) => n[0]).join(''),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.request.employeeName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.request.employeeId} • ${widget.request.department}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Leave Request Details Card
            _buildInfoCard(
              title: 'Leave Request Details',
              children: [
                _buildInfoRow(
                  icon: Icons.work_outline,
                  label: 'Leave Type',
                  value: widget.request.leaveType,
                ),
                _buildInfoRow(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Request ID',
                  value: widget.request.id,
                ),
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Duration',
                  value: '${_getDuration()} day${_getDuration() > 1 ? 's' : ''}',
                ),
                _buildInfoRow(
                  icon: Icons.date_range_outlined,
                  label: 'Start Date',
                  value: _formatDate(widget.request.startDate),
                ),
                _buildInfoRow(
                  icon: Icons.date_range_outlined,
                  label: 'End Date',
                  value: _formatDate(widget.request.endDate),
                ),
                _buildInfoRow(
                  icon: Icons.access_time_outlined,
                  label: 'Applied On',
                  value: _formatDateTime(widget.request.appliedDate),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Priority Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPriorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getPriorityIcon(),
                      color: _getPriorityColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPriorityText(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getPriorityColor(),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getUrgencyMessage(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reason Card
            _buildInfoCard(
              title: 'Reason for Leave',
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.request.reason,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Attachments Card (if available)
            if (widget.request.attachments != null && widget.request.attachments!.isNotEmpty)
              _buildInfoCard(
                title: 'Attachments (${widget.request.attachments!.length})',
                children: [
                  ...widget.request.attachments!.map((attachment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              attachment,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.download_outlined,
                              color: Colors.blue[600],
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloading $attachment')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                ],
              ),

            if (widget.request.attachments != null && widget.request.attachments!.isNotEmpty)
              const SizedBox(height: 16),

            // Comments Section
            _buildInfoCard(
              title: 'Add Comments (Optional)',
              children: [
                TextField(
                  controller: _commentsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add any comments or feedback for the employee...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Note: Comments are required when rejecting a request',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _handleReject,
                icon: _isProcessing
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.close_rounded),
                label: Text(_isProcessing ? 'Processing...' : 'Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _handleApprove,
                icon: _isProcessing
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.check_rounded),
                label: Text(_isProcessing ? 'Processing...' : 'Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (widget.request.priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
      default:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon() {
    switch (widget.request.priority) {
      case 1:
        return Icons.priority_high;
      case 2:
        return Icons.schedule;
      case 3:
      default:
        return Icons.low_priority;
    }
  }

  String _getPriorityText() {
    switch (widget.request.priority) {
      case 1:
        return "High Priority";
      case 2:
        return "Medium Priority";
      case 3:
      default:
        return "Low Priority";
    }
  }

  String _getUrgencyMessage() {
    final days = widget.request.daysSinceApplied;
    if (days == 0) return "Request submitted today";
    if (days == 1) return "Request submitted yesterday";
    if (days >= 3) return "Urgent: Request submitted $days days ago";
    return "Request submitted $days days ago";
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
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

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }
}
