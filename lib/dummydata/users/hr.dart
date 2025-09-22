import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';

/// Dummy JSON response for HR
const Map<String, dynamic> dummyHRResponse = {
  "currentUser": {
    "id": "hr001",
    "firstName": "Sophia",
    "lastName": "Taylor",
    "email": "sophia.taylor@example.com",
    "mobile": "9012345678",
    "role": "hr",
    "reportingTo": ["director1"],
    "projectList": ["Recruitment", "Employee Engagement"],
    "isActive": true,
    "createdAt": "2020-05-10T08:45:00Z",
    "balance": 25,
    "approved": 18,
    "rejected": 1,
    "pending": 4,
    "organization": "Leavify Inc.",
    "empId": "HR001",
    "joiningDate": "2018-07-20",
    "workingDays": 230,
    "profileImageUrl": "https://example.com/profile/sophia_taylor.jpg",
    "canSendAnnouncement": true,
    "designation": "HR",
  },
  "myUpcomingLeaves": [
    {
      "userId": "hr001",
      "employeeName": "Sophia Taylor",
      "startDate": "2025-10-18",
      "endDate": "2025-10-19",
      "reason": "Medical Checkup",
      "status": "approved",
    },
    {
      "userId": "hr001",
      "employeeName": "Sophia Taylor",
      "startDate": "2025-11-15",
      "endDate": "2025-11-16",
      "reason": "Vacation",
      "status": "pending",
    },
  ],
  "teamUpcomingLeaves": [
    {
      "userId": "u301",
      "employeeName": "John Doe",
      "startDate": "2025-10-20",
      "endDate": "2025-10-22",
      "reason": "Vacation",
      "status": "approved",
    },
    {
      "userId": "u302",
      "employeeName": "Alice Smith",
      "startDate": "2025-10-25",
      "endDate": "2025-10-26",
      "reason": "Medical",
      "status": "approved",
    },
    {
      "userId": "u303",
      "employeeName": "Bob Johnson",
      "startDate": "2025-11-01",
      "endDate": "2025-11-03",
      "reason": "Family Event",
      "status": "approved",
    },
    {
      "userId": "u304",
      "employeeName": "Charlie Brown",
      "startDate": "2025-11-05",
      "endDate": "2025-11-06",
      "reason": "Vacation",
      "status": "approved",
    },
  ],
};

/// Converts dummy JSON response into a Dart object
final GetUserSummaryResponse dummyHRData = GetUserSummaryResponse.fromJson(
  dummyHRResponse,
);
