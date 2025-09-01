import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/Authentication/domain/models/user.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';

class DummyUserData {
  /// Creates a dummy user with realistic data
  static User createDummyUser() {
    final now = DateTime.now();
    final joiningDate = now.subtract(const Duration(days: 730)); // 2 years ago

    return User(
      id: 'usr_12345',
      firstName: 'Rajesh',
      lastName: 'Kumar',
      email: 'rajesh.kumar@company.com',
      mobile: '+91 9876543210',
      role: 'Senior Software Engineer',
      reportingTo: ['Priya Sharma', 'Amit Singh'],
      projectList: [
        'E-Commerce Platform',
        'Mobile Banking App',
        'Data Analytics Dashboard',
      ],
      isActive: true,
      createdAt: joiningDate.toIso8601String(),
      balance: 18, // Available leave balance
      approved: 12, // Approved leaves this year
      rejected: 1, // Rejected leaves
      pending: 2, // Pending leaves
      organization: 'TechCorp Solutions Pvt Ltd',
      empId: 'EMP001234',
      joiningDate: joiningDate.toIso8601String(),
      canSendAnnouncement: false,
    );
  }

  /// Creates dummy upcoming leaves for the current user
  static List<Leave> createMyUpcomingLeaves() {
    final now = DateTime.now();

    return [
      Leave(
        userId: 'usr_12345',
        employeeName: 'Rajesh Kumar',
        startDate: now
            .add(const Duration(days: 5))
            .toIso8601String()
            .split('T')[0],
        endDate: now
            .add(const Duration(days: 5))
            .toIso8601String()
            .split('T')[0],
        reason: 'Medical appointment and health checkup',
        status: 'APPROVED',
      ),
      Leave(
        userId: 'usr_12345',
        employeeName: 'Rajesh Kumar',
        startDate: now
            .add(const Duration(days: 15))
            .toIso8601String()
            .split('T')[0],
        endDate: now
            .add(const Duration(days: 17))
            .toIso8601String()
            .split('T')[0],
        reason: 'Family wedding in hometown',
        status: 'PENDING',
      ),
      Leave(
        userId: 'usr_12345',
        employeeName: 'Rajesh Kumar',
        startDate: now
            .add(const Duration(days: 30))
            .toIso8601String()
            .split('T')[0],
        endDate: now
            .add(const Duration(days: 32))
            .toIso8601String()
            .split('T')[0],
        reason: 'Planned vacation to Goa with family',
        status: 'PENDING',
      ),
    ];
  }

  /// Creates dummy upcoming leaves for team members
  static List<Leave> createTeamUpcomingLeaves() {
    final now = DateTime.now();

    return [
      Leave(
        userId: 'usr_67890',
        employeeName: 'Priya Patel',
        startDate: now
            .add(const Duration(days: 3))
            .toIso8601String()
            .split('T')[0],
        endDate: now
            .add(const Duration(days: 4))
            .toIso8601String()
            .split('T')[0],
        reason: 'Personal work - house shifting',
        status: 'APPROVED',
      ),
      Leave(
        userId: 'usr_54321',
        employeeName: 'Arjun Mehta',
        startDate: now
            .add(const Duration(days: 8))
            .toIso8601String()
            .split('T')[0],
        endDate: now
            .add(const Duration(days: 8))
            .toIso8601String()
            .split('T')[0],
        reason: 'Sick leave - fever and cold',
        status: 'APPROVED',
      ),
      Leave(
        userId: 'usr_98765',
        employeeName: 'Sneha Reddy',
        startDate: now
            .add(const Duration(days: 12))
            .toIso8601String()
            .split('T')[0],
        endDate: now
            .add(const Duration(days: 14))
            .toIso8601String()
            .split('T')[0],
        reason: 'Annual leave - visiting parents',
        status: 'APPROVED',
      ),
      Leave(
        userId: 'usr_11111',
        employeeName: 'Vikram Singh',
        startDate: now
            .add(const Duration(days: 20))
            .toIso8601String()
            .split('T')[0],
        endDate: now
            .add(const Duration(days: 22))
            .toIso8601String()
            .split('T')[0],
        reason: 'Comp off for weekend work',
        status: 'PENDING',
      ),
      Leave(
        userId: 'usr_22222',
        employeeName: 'Kavya Nair',
        startDate: now
            .add(const Duration(days: 25))
            .toIso8601String()
            .split('T')[0],
        endDate: now
            .add(const Duration(days: 25))
            .toIso8601String()
            .split('T')[0],
        reason: 'Half day for personal appointment',
        status: 'APPROVED',
      ),
    ];
  }

  /// Creates complete dummy user summary response
  static GetUserSummaryResponse createDummyUserSummary() {
    return GetUserSummaryResponse(
      currentUser: createDummyUser(),
      myUpcomingLeaves: createMyUpcomingLeaves(),
      teamUpcomingLeaves: createTeamUpcomingLeaves(),
    );
  }

  /// Saves dummy user data to app storage (for testing purposes)
  static Future<void> saveDummyUserToStorage() async {
    final dummyUserSummary = createDummyUserSummary();
    await AppStorage.saveObject('user_details', dummyUserSummary.toJson());
  }

  /// Creates multiple dummy user profiles for variety in testing
  static List<User> createMultipleDummyUsers() {
    final now = DateTime.now();

    return [
      // User 1 - Senior Developer
      User(
        id: 'usr_12345',
        firstName: 'Rajesh',
        lastName: 'Kumar',
        email: 'rajesh.kumar@company.com',
        mobile: '+91 9876543210',
        role: 'Senior Software Engineer',
        reportingTo: ['Priya Sharma'],
        projectList: ['E-Commerce Platform', 'Mobile Banking App'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 730)).toIso8601String(),
        balance: 18,
        approved: 12,
        rejected: 1,
        pending: 2,
        organization: 'TechCorp Solutions Pvt Ltd',
        empId: 'EMP001234',
        joiningDate: now.subtract(const Duration(days: 730)).toIso8601String(),
        canSendAnnouncement: false,
      ),

      // User 2 - Team Lead
      User(
        id: 'usr_67890',
        firstName: 'Priya',
        lastName: 'Sharma',
        email: 'priya.sharma@company.com',
        mobile: '+91 8765432109',
        role: 'Team Lead',
        reportingTo: ['Amit Singh'],
        projectList: [
          'Data Analytics Dashboard',
          'AI/ML Platform',
          'Cloud Migration',
        ],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 1095)).toIso8601String(),
        balance: 22,
        approved: 8,
        rejected: 0,
        pending: 1,
        organization: 'TechCorp Solutions Pvt Ltd',
        empId: 'EMP005678',
        joiningDate: now.subtract(const Duration(days: 1095)).toIso8601String(),
        canSendAnnouncement: false,
      ),

      // User 3 - Junior Developer
      User(
        id: 'usr_54321',
        firstName: 'Arjun',
        lastName: 'Mehta',
        email: 'arjun.mehta@company.com',
        mobile: '+91 7654321098',
        role: 'Software Engineer',
        reportingTo: ['Rajesh Kumar', 'Priya Sharma'],
        projectList: ['Mobile Banking App'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 365)).toIso8601String(),
        balance: 25,
        approved: 5,
        rejected: 0,
        pending: 0,
        organization: 'TechCorp Solutions Pvt Ltd',
        empId: 'EMP009876',
        joiningDate: now.subtract(const Duration(days: 365)).toIso8601String(),
        canSendAnnouncement: false,
      ),
    ];
  }

  /// Creates a custom dummy user with specified parameters
  static User createCustomDummyUser({
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    List<String>? projects,
    int? balance,
    int? approved,
    int? pending,
    int? rejected,
  }) {
    final now = DateTime.now();
    final joiningDate = now.subtract(const Duration(days: 500));

    return User(
      id: 'usr_custom_${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName ?? 'John',
      lastName: lastName ?? 'Doe',
      email: email ?? 'john.doe@company.com',
      mobile: '+91 9999999999',
      role: role ?? 'Software Engineer',
      reportingTo: ['Manager Name'],
      projectList: projects ?? ['Default Project'],
      isActive: true,
      createdAt: joiningDate.toIso8601String(),
      balance: balance ?? 20,
      approved: approved ?? 10,
      rejected: rejected ?? 0,
      pending: pending ?? 1,
      organization: 'TechCorp Solutions Pvt Ltd',
      empId:
          'EMP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      joiningDate: joiningDate.toIso8601String(),
      canSendAnnouncement: false,
    );
  }

  /// Utility method to clear dummy data from storage
  static Future<void> clearDummyData() async {
    // Note: Implement this based on your AppStorage.remove method
    // await AppStorage.remove('user_details');
  }

  /// Check if dummy data exists in storage
  static Future<bool> hasDummyData() async {
    try {
      final userSummary = await AppStorage.getObject<GetUserSummaryResponse>(
        'user_details',
        (json) => GetUserSummaryResponse.fromJson(json),
      );
      return userSummary?.currentUser != null;
    } catch (e) {
      return false;
    }
  }
}
