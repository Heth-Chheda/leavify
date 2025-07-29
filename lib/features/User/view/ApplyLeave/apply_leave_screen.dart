import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';
import 'package:leavify/features/User/view/ApplyLeave/tabs/apply_leave_tab.dart';
import 'package:leavify/features/User/view/ApplyLeave/tabs/extra_tab.dart';
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;

  // MARK: TAB LIST
  final List<TabInfo> _tabs = const [
    TabInfo(title: 'Leave', type: TabType.leave),
    TabInfo(title: 'Extra', type: TabType.extra),
    TabInfo(title: 'WFH', type: TabType.wfh),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // MARK: BUILD SECTION
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
                _buildStatsHeaderSection(),
                _buildTabSection(),
                _buildTabContent(leaveViewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: BUILD HEADER SECTION
  Widget _buildStatsHeaderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leave Balance Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Leave Balance',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '8',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Working Days Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Working Days',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '22',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: BUILD TAB SECTION
  Widget _buildTabSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _tabs.asMap().entries.map((entry) {
          int index = entry.key;
          TabInfo tab = entry.value;
          return _buildModernTab(tab, index);
        }).toList(),
      ),
    );
  }

  // MARK: BUILD MODERN TAB
  Widget _buildModernTab(TabInfo tabInfo, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isSelected ? 1.08 : 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: _getTabGradient(tabInfo.type, isSelected),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _getTabGradient(
                            tabInfo.type,
                            isSelected,
                          ).colors.first.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: _buildStackedIcons(tabInfo.type, isSelected),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tabInfo.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppTheme.accentNavy : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: isSelected ? 14 : 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // MARK: GET TAB GRADIENT
  LinearGradient _getTabGradient(TabType type, bool isSelected) {
    final double opacity = isSelected ? 1.0 : 0.9;

    switch (type) {
      case TabType.leave:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4ECDC4).withOpacity(opacity),
            const Color(0xFF44A08D).withOpacity(opacity),
          ],
        );
      case TabType.extra:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFB74D).withOpacity(opacity),
            const Color(0xFFF57C00).withOpacity(opacity),
          ],
        );
      case TabType.wfh:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7986CB).withOpacity(opacity),
            const Color(0xFF3F51B5).withOpacity(opacity),
          ],
        );
    }
  }

  // MARK: BUILD STACKED ICONS
  List<Widget> _buildStackedIcons(TabType type, bool isSelected) {
    final double baseIconSize = isSelected ? 32 : 28;
    final double overlayIconSize = isSelected ? 20 : 16;
    const Color iconColor = Colors.white;
    const Color overlayColor = Colors.white;

    switch (type) {
      case TabType.leave:
        return [
          // Calendar icon (base)
          Positioned(
            child: Icon(
              Icons.calendar_month_rounded,
              size: baseIconSize,
              color: iconColor,
            ),
          ),
          // Form/document icon (overlay)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.description_rounded,
                size: overlayIconSize,
                color: overlayColor,
              ),
            ),
          ),
        ];

      case TabType.extra:
        return [
          // PC/Computer icon (base)
          Positioned(
            child: Icon(
              Icons.computer_rounded,
              size: baseIconSize,
              color: iconColor,
            ),
          ),
          // Plus icon (overlay)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add_circle_rounded,
                size: overlayIconSize,
                color: overlayColor,
              ),
            ),
          ),
        ];

      case TabType.wfh:
        return [
          // Home icon (base)
          Positioned(
            child: Icon(
              Icons.home_rounded,
              size: baseIconSize,
              color: iconColor,
            ),
          ),
          // PC icon (overlay)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.laptop_mac_rounded,
                size: overlayIconSize,
                color: overlayColor,
              ),
            ),
          ),
        ];
    }
  }

  // MARK: BUILD TAB CONTENT
  Widget _buildTabContent(LeaveViewModel leaveViewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          topLeft: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.2),
            blurRadius: 1,
            offset: const Offset(0, -1),
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

  // MARK: GET CURRENT TAB CONTENT
  Widget _getCurrentTabContent(LeaveViewModel leaveViewModel) {
    switch (_selectedIndex) {
      case 0:
        return _buildTabWrapper(ApplyLeaveTab(leaveViewModel: leaveViewModel));
      case 1:
        return _buildTabWrapper(ExtraDayTab(leaveViewModel: leaveViewModel));
      case 2:
        return _buildTabWrapper(
          WorkFromHomeTab(leaveViewModel: leaveViewModel),
        );
      default:
        return _buildTabWrapper(ApplyLeaveTab(leaveViewModel: leaveViewModel));
    }
  }

  // MARK: TAB WRAPPER
  Widget _buildTabWrapper(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

enum TabType { leave, extra, wfh }

class TabInfo {
  final String title;
  final TabType type;

  const TabInfo({required this.title, required this.type});
}
