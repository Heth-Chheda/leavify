// history_screen.dart
import 'package:flutter/material.dart';
import 'package:leavify/features/User/components/leaveHistory/leave_card.dart';
import 'package:leavify/features/User/domain/models/leave_application_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LeaveApplication> _allLeaves = [];
  List<LeaveApplication> _filteredLeaves = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _generateDummyData();
    _filteredLeaves = _allLeaves;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _filterLeaves(_tabController.index);
      }
    });
  }

  void _generateDummyData() {
    _allLeaves = [
      LeaveApplication(
        id: "L001",
        leaveType: "Annual Leave",
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 8)),
        reason: "Family vacation",
        status: LeaveStatus.approved,
        appliedDate: DateTime.now().subtract(const Duration(days: 15)),
        approverName: "John Manager",
        comments: "Approved for well-deserved break",
      ),
      LeaveApplication(
        id: "L002",
        leaveType: "Sick Leave",
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().subtract(const Duration(days: 3)),
        reason: "Flu symptoms",
        status: LeaveStatus.rejected,
        appliedDate: DateTime.now().subtract(const Duration(days: 7)),
        approverName: "Sarah HR",
        comments: "Medical certificate required",
      ),
      LeaveApplication(
        id: "L003",
        leaveType: "Personal Leave",
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        reason: "Personal matters",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      LeaveApplication(
        id: "L004",
        leaveType: "Emergency Leave",
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now(),
        reason: "Family emergency",
        status: LeaveStatus.escalated,
        appliedDate: DateTime.now().subtract(const Duration(days: 2)),
        comments: "Escalated to senior management",
      ),
      LeaveApplication(
        id: "L005",
        leaveType: "Annual Leave",
        startDate: DateTime.now().add(const Duration(days: 20)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        reason: "Wedding anniversary celebration",
        status: LeaveStatus.approved,
        appliedDate: DateTime.now().subtract(const Duration(days: 30)),
        approverName: "Mike Director",
        comments: "Congratulations! Approved",
      ),
      LeaveApplication(
        id: "L006",
        leaveType: "Maternity Leave",
        startDate: DateTime.now().add(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 150)),
        reason: "Maternity leave",
        status: LeaveStatus.pending,
        appliedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LeaveApplication(
        id: "L007",
        leaveType: "Sick Leave",
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        endDate: DateTime.now().subtract(const Duration(days: 18)),
        reason: "Medical checkup",
        status: LeaveStatus.approved,
        appliedDate: DateTime.now().subtract(const Duration(days: 25)),
        approverName: "Lisa Manager",
      ),
      LeaveApplication(
        id: "L008",
        leaveType: "Casual Leave",
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        reason: "House moving",
        status: LeaveStatus.rejected,
        appliedDate: DateTime.now().subtract(const Duration(days: 3)),
        approverName: "Tom HR",
        comments: "Insufficient notice period",
      ),
      LeaveApplication(
        id: "L009",
        leaveType: "Study Leave",
        startDate: DateTime.now().add(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 16)),
        reason: "Professional certification exam",
        status: LeaveStatus.escalated,
        appliedDate: DateTime.now().subtract(const Duration(days: 5)),
        comments: "Needs CEO approval for study leave",
      ),
      LeaveApplication(
        id: "L010",
        leaveType: "Annual Leave",
        startDate: DateTime.now().subtract(const Duration(days: 40)),
        endDate: DateTime.now().subtract(const Duration(days: 35)),
        reason: "International trip",
        status: LeaveStatus.approved,
        appliedDate: DateTime.now().subtract(const Duration(days: 50)),
        approverName: "Rachel Director",
        comments: "Have a great trip!",
      ),
    ];
  }

  void _filterLeaves(int tabIndex) {
    setState(() {
      switch (tabIndex) {
        case 0: // All
          _filteredLeaves = _allLeaves;
          break;
        case 1: // Pending
          _filteredLeaves = _allLeaves
              .where((leave) => leave.status == LeaveStatus.pending)
              .toList();
          break;
        case 2: // Approved
          _filteredLeaves = _allLeaves
              .where((leave) => leave.status == LeaveStatus.approved)
              .toList();
          break;
        case 3: // Rejected
          _filteredLeaves = _allLeaves
              .where((leave) => leave.status == LeaveStatus.rejected)
              .toList();
          break;
        case 4: // Escalated
          _filteredLeaves = _allLeaves
              .where((leave) => leave.status == LeaveStatus.escalated)
              .toList();
          break;
      }
    });
  }

  List<LeaveApplication> _getFilteredLeaves(int tabIndex) {
    switch (tabIndex) {
      case 0: // All
        return _allLeaves;
      case 1: // Pending
        return _allLeaves
            .where((leave) => leave.status == LeaveStatus.pending)
            .toList();
      case 2: // Approved
        return _allLeaves
            .where((leave) => leave.status == LeaveStatus.approved)
            .toList();
      case 3: // Rejected
        return _allLeaves
            .where((leave) => leave.status == LeaveStatus.rejected)
            .toList();
      case 4: // Escalated
        return _allLeaves
            .where((leave) => leave.status == LeaveStatus.escalated)
            .toList();
      default:
        return _allLeaves;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Pending"),
                Tab(text: "Approved"),
                Tab(text: "Rejected"),
                Tab(text: "Escalated"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaveListForTab(0), // All
                _buildLeaveListForTab(1), // Pending
                _buildLeaveListForTab(2), // Approved
                _buildLeaveListForTab(3), // Rejected
                _buildLeaveListForTab(4), // Escalated
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveListForTab(int tabIndex) {
    final leavesForTab = _getFilteredLeaves(tabIndex);

    if (leavesForTab.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No leave applications found",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leavesForTab.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LeaveCard(leave: leavesForTab[index]),
        );
      },
    );
  }
}