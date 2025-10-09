import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';

/// Dummy JSON response for a manager
const Map<String, dynamic> dummyManagerResponse = {
  "currentUser": {
    "id": "m001",
    "firstName": "Emma",
    "lastName": "Williams",
    "email": "emma.williams@example.com",
    "mobile": "9123456780",
    "role": "manager",
    "reportingTo": ["director1"],
    "projectList": ["Project X", "Project Y", "Project Z"],
    "isActive": true,
    "createdAt": "2021-08-15T09:30:00Z",
    "balance": 20,
    "approved": 15,
    "rejected": 2,
    "pending": 3,
    "organization": "Leavify Inc.",
    "empId": "MGR001",
    "joiningDate": "2019-09-01",
    "workingDays": 240,
    "profileImageUrl": "https://example.com/profile/emma_williams.jpg",
    "canSendAnnouncement": true,
    "designation": "Manager",
  },
  "myUpcomingLeaves": [
    {
      "userId": "m001",
      "employeeName": "Emma Williams",
      "startDate": "2025-10-20",
      "endDate": "2025-10-22",
      "reason": "Conference",
      "status": "approved",
    },
    {
      "userId": "m001",
      "employeeName": "Emma Williams",
      "startDate": "2025-11-10",
      "endDate": "2025-11-12",
      "reason": "Vacation",
      "status": "pending",
    },
  ],
  "teamUpcomingLeaves": [
    {
      "userId": "u201",
      "employeeName": "Alice Smith",
      "startDate": "2025-10-25",
      "endDate": "2025-10-27",
      "reason": "Medical",
      "status": "approved",
    },
    {
      "userId": "u202",
      "employeeName": "Bob Johnson",
      "startDate": "2025-11-01",
      "endDate": "2025-11-03",
      "reason": "Family Event",
      "status": "pending",
    },
    {
      "userId": "u203",
      "employeeName": "Charlie Brown",
      "startDate": "2025-11-05",
      "endDate": "2025-11-07",
      "reason": "Vacation",
      "status": "approved",
    },
  ],
};

/// Converts dummy JSON response into a Dart object
final GetUserSummaryResponse dummyManagerData = GetUserSummaryResponse.fromJson(
  dummyManagerResponse,
);
