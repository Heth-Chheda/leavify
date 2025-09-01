// pending_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/User/components/manager/pending_request_card.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';
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

    final filtered = requests.where((r) {
      // For HR → Escalated means escalated flag true
      // For others → Escalated means status == 'escalated'
      final isEscalated = isHR
          ? r.escalated == true
          : r.status.toLowerCase() == 'escalated';

      // If current filter is NOT "Escalated" and leave is escalated → exclude
      if (_selectedFilter.toLowerCase() != 'escalated' && isEscalated) {
        return false;
      }

      // Search filter
      final query = _searchQuery.toLowerCase();
      final fullName = '${r.firstName} ${r.lastName}'.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          fullName.contains(query) ||
          r.role.toLowerCase().contains(query) ||
          r.reason.toLowerCase().contains(query);

      // Status filter
      final matchesFilter = switch (_selectedFilter.toLowerCase()) {
        'pending' => r.status.toLowerCase() == 'pending',
        'approved' => r.status.toLowerCase() == 'approved',
        'rejected' || 'denied' =>
          r.status.toLowerCase() == 'rejected' ||
              r.status.toLowerCase() == 'denied',
        'escalated' => isEscalated,
        _ => true, // "All"
      };

      return matchesSearch && matchesFilter;
    }).toList();

    // Define status priority for sorting
    final statusPriority = {
      'escalated': 0,
      'pending': 1,
      'approved': 2,
      'rejected': 3,
      'denied': 3, // treat denied same as rejected
    };

    // Sort the filtered list by status priority
    filtered.sort((a, b) {
      final aStatus = isHR && a.escalated == true
          ? 'escalated'
          : a.status.toLowerCase();
      final bStatus = isHR && b.escalated == true
          ? 'escalated'
          : b.status.toLowerCase();

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

  void _navigateToDetail(GetAllResponse request) {
    Navigator.pushNamed(
      context,
      '/pending-leave-detail',
      arguments: {'leaveId': request.leaveId},
    );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Consumer<LeaveViewModel>(
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
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (leaveViewModel.errorMessage != null && allRequests.isEmpty) {
            return Column(
              children: [
                _buildHeader(context, pendingCount),
                Expanded(child: _buildErrorState(leaveViewModel.errorMessage!)),
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
                            padding: const EdgeInsets.all(16),
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
    );
  }

  // MARK: - HEADER
  Widget _buildHeader(BuildContext context, int pendingCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final homeViewModel = context.watch<HomeViewModel>();

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
    final isDarkMode = theme.brightness == Brightness.dark;

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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        filled: true,
        fillColor: isDarkMode
            ? colorScheme.surface
            : colorScheme.onSurface.withOpacity(0.05),
      ),
    );
  }

  // MARK: - FILTER CHIPS
  Widget _buildFilterChips(BuildContext context, String userRole) {
    final role = userRole.toLowerCase();
    final filters = [
      'All',
      'Pending',
      'Approved',
      'Rejected',
      if (role == 'hr') 'Escalated',
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
              selectedColor: colorScheme.primary.withOpacity(0.2),
              backgroundColor: colorScheme.surface,
              checkmarkColor: colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.2),
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.8),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
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
