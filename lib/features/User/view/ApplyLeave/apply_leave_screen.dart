import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';
import 'package:leavify/features/User/view/ApplyLeave/tabs/apply_leave_tab.dart';
import 'package:leavify/features/User/view/ApplyLeave/tabs/comp_off_tab.dart';
import 'package:leavify/features/User/view/ApplyLeave/tabs/half_day_tab.dart';
import 'package:leavify/features/User/view/ApplyLeave/tabs/work_from_home_tab.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';
import 'package:provider/provider.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<TabInfo> _tabs = const [
    TabInfo(
      title: 'Apply Leave',
      icon: Icons.event_busy_outlined,
      activeIcon: Icons.event_busy,
    ),
    TabInfo(
      title: 'Half Day',
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule,
    ),
    TabInfo(
      title: 'Comp Off',
      icon: Icons.swap_horiz_outlined,
      activeIcon: Icons.swap_horiz,
    ),
    TabInfo(
      title: 'Work From Home',
      icon: Icons.home_work_outlined,
      activeIcon: Icons.home_work,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Add listener to TabController to rebuild content when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          // This will trigger a rebuild when tab changes
        });
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaveViewModel = Provider.of<LeaveViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildTabSection(),
                _buildTabContent(leaveViewModel),
                // Add some bottom padding for better UX
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: AppTheme.buttonGradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentNavy.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: AppTheme.white,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
              tabs: _tabs.map((tab) => _buildCustomTab(tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab(TabInfo tabInfo) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final int currentIndex = _tabController.index;
        final int tabIndex = _tabs.indexOf(tabInfo);
        final bool isSelected = currentIndex == tabIndex;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? tabInfo.activeIcon : tabInfo.icon,
                size: 20,
                color: isSelected ? AppTheme.white : AppTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                tabInfo.title,
                style: TextStyle(
                  color: isSelected ? AppTheme.white : AppTheme.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(LeaveViewModel leaveViewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tab content that grows with its content
            _getCurrentTabContent(leaveViewModel),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentTabContent(LeaveViewModel leaveViewModel) {
    // Use AnimatedBuilder to listen to tab controller changes
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        switch (_tabController.index) {
          case 0:
            return _buildTabWrapper(ApplyLeaveTab(leaveViewModel: leaveViewModel));
          case 1:
            return _buildTabWrapper(HalfDayTab(leaveViewModel: leaveViewModel));
          case 2:
            return _buildTabWrapper(CompOffTab(leaveViewModel: leaveViewModel));
          case 3:
            return _buildTabWrapper(WorkFromHomeTab(leaveViewModel: leaveViewModel));
          default:
            return _buildTabWrapper(ApplyLeaveTab(leaveViewModel: leaveViewModel));
        }
      },
    );
  }

  Widget _buildTabWrapper(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class TabInfo {
  final String title;
  final IconData icon;
  final IconData activeIcon;

  const TabInfo({
    required this.title,
    required this.icon,
    required this.activeIcon,
  });
}