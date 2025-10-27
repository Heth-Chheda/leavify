// pending_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/Leave/components/manager/pending_request_card.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';
import 'package:provider/provider.dart';

enum LeaveStatus { pending, approved, rejected, escalated }

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetching the pending leaves
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveViewModel>().fetchPendingLeaves();
    });
  }

  List<GetAllResponse> _getFilteredRequests(List<GetAllResponse> requests) {
    final homeViewModel = context.read<HomeViewModel>();
    final isHR = homeViewModel.userRole.toLowerCase() == 'hr';
    final filter = _selectedFilter.toLowerCase();
    final query = _searchQuery.toLowerCase();

    // Step 1: Apply search & filter
    final filtered = requests.where((r) {
      // Search filter
      final fullName = '${r.firstName} ${r.lastName}'.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          fullName.contains(query) ||
          r.role.toLowerCase().contains(query) ||
          r.reason.toLowerCase().contains(query);

      // Status filter
      final status = r.status.toLowerCase();
      bool matchesFilter;
      switch (filter) {
        case 'pending':
          matchesFilter = status == 'pending';
          break;
        case 'approved':
          matchesFilter = status == 'approved';
          break;
        case 'rejected':
        case 'denied':
          matchesFilter = status == 'rejected' || status == 'denied';
          break;
        case 'escalated':
          matchesFilter = isHR ? r.escalated == true : status == 'escalated';
          break;
        default:
          matchesFilter = true; // All
      }

      return matchesSearch && matchesFilter;
    }).toList();

    // Step 2: Sort by priority (HR: escalated on top)
    filtered.sort((a, b) {
      if (isHR) {
        // Escalated first
        final aEsc = a.escalated == true ? 0 : 1;
        final bEsc = b.escalated == true ? 0 : 1;
        if (aEsc != bEsc) return aEsc.compareTo(bEsc);
      }

      // Then normal status order
      final statusPriority = {
        'pending': 1,
        'approved': 2,
        'rejected': 3,
        'denied': 3,
        'escalated': 0, // already handled for HR
      };

      final aStatus = a.status.toLowerCase();
      final bStatus = b.status.toLowerCase();

      final aPriority = statusPriority[aStatus] ?? 999;
      final bPriority = statusPriority[bStatus] ?? 999;

      return aPriority.compareTo(bPriority);
    });

    return filtered;
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _onFilterSelected(String filter) {
    setState(() => _selectedFilter = filter);
  }

  void _navigateToDetail(GetAllResponse request) async {
    await AppNavigator.navigateTo(
      RouteNames.pendingRequestDetail,
      arguments: {'leaveId': request.leaveId, 'user': request},
    );

    // Refresh leaves when returning
    if (mounted) {
      context.read<LeaveViewModel>().fetchPendingLeaves();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<LeaveViewModel>().fetchPendingLeaves();
  }

  final statusPriority = {
    'escalated': 0,
    'pending': 1,
    'approved': 2,
    'rejected': 3,
  };

  // MARK: - BUILD SECTION
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Consumer<LeaveViewModel>(
          builder: (context, leaveViewModel, child) {
            final allRequests = leaveViewModel.getAllPendingLeaves;
            final filteredRequests = _getFilteredRequests(allRequests);
            final pendingCount = allRequests
                .where((r) => r.status.toLowerCase() == 'pending')
                .length;

            if (leaveViewModel.isLoading && allRequests.isEmpty) {
              return Column(
                children: [
                  _buildHeader(context, pendingCount),
                  const Expanded(
                    child: Center(
                      child: SpinKitSquareCircle(color: Colors.blue, size: 80),
                    ),
                  ),
                ],
              );
            }

            if (leaveViewModel.errorMessage != null && allRequests.isEmpty) {
              return Column(
                children: [
                  _buildHeader(context, pendingCount),
                  Expanded(
                    child: _buildErrorState(leaveViewModel.errorMessage!),
                  ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  _buildHeader(context, pendingCount),
                  Expanded(
                    child: SafeArea(
                      child: filteredRequests.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredRequests.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final request = filteredRequests[index];
                                return PendingRequestCard(
                                  request: request,
                                  onTap: () => _navigateToDetail(request),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // MARK: - HEADER
  Widget _buildHeader(BuildContext context, int pendingCount) {
    final homeViewModel = context.watch<HomeViewModel>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 12),
          _buildFilterChips(context, homeViewModel.userRole),
        ],
      ),
    );
  }

  // MARK: - SEARCH BAR
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      onChanged: _onSearchChanged,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Search by employee name, leave type, or department...',
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        prefixIcon: Icon(
          Icons.search,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // MARK: - FILTER CHIPS
  Widget _buildFilterChips(BuildContext context, String userRole) {
    final role = userRole.toLowerCase();
    final filters = [
      'All',
      if (role == 'hr') 'Escalated',
      'Pending',
      'Approved',
      'Rejected',
    ];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => _onFilterSelected(filter),
              showCheckmark: false,
              selectedColor: colorScheme.primary.withOpacity(0),
              backgroundColor: Colors.white,
              elevation: 0,
              pressElevation: 0,
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.primary.withOpacity(0);
                }
                return colorScheme.surface;
              }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.15),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.black
                    : colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  // MARK: - EMPTY STATE
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFilters = _searchQuery.isNotEmpty || _selectedFilter != 'All';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? "No requests match your filters"
                : "No pending requests",
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? "Try adjusting your search or filters"
                : "All caught up! No requests awaiting your review.",
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - ERROR STATE
  Widget _buildErrorState(String errorMessage) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: colorScheme.error.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
