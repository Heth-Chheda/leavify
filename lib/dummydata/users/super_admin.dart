import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';

/// Dummy JSON response for Super Admin (the boss)
const Map<String, dynamic> dummySuperAdminResponse = {
  "currentUser": {
    "id": "sa001",
    "firstName": "Michael",
    "lastName": "Anderson",
    "email": "michael.anderson@example.com",
    "mobile": "9001122334",
    "role": "super_admin",
    "reportingTo": [],
    "projectList": ["All Projects"],
    "isActive": true,
    "createdAt": "2015-01-01T08:00:00Z",
    "balance": 50,
    "approved": 40,
    "rejected": 2,
    "pending": 5,
    "organization": "Leavify Inc.",
    "empId": "SA001",
    "joiningDate": "2010-01-01",
    "workingDays": 250,
    "profileImageUrl": "https://example.com/profile/michael_anderson.jpg",
    "canSendAnnouncement": true,
    "designation": "superAdmin",
  },
  "myUpcomingLeaves": [
    {
      "userId": "sa001",
      "employeeName": "Michael Anderson",
      "startDate": "2025-12-20",
      "endDate": "2025-12-25",
      "reason": "Vacation",
      "status": "approved",
    },
  ],
  "teamUpcomingLeaves": [
    {
      "userId": "u401",
      "employeeName": "John Doe",
      "startDate": "2025-10-25",
      "endDate": "2025-10-27",
      "reason": "Vacation",
      "status": "approved",
    },
    {
      "userId": "u402",
      "employeeName": "Alice Smith",
      "startDate": "2025-11-01",
      "endDate": "2025-11-03",
      "reason": "Medical",
      "status": "approved",
    },
    {
      "userId": "u403",
      "employeeName": "Bob Johnson",
      "startDate": "2025-11-05",
      "endDate": "2025-11-07",
      "reason": "Family Event",
      "status": "approved",
    },
    {
      "userId": "u404",
      "employeeName": "Charlie Brown",
      "startDate": "2025-11-10",
      "endDate": "2025-11-12",
      "reason": "Vacation",
      "status": "approved",
    },
  ],
};

/// Converts dummy JSON response into a Dart object
final GetUserSummaryResponse dummySuperAdminData =
    GetUserSummaryResponse.fromJson(dummySuperAdminResponse);
