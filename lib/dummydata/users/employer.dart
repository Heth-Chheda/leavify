// employer.dart
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';

/// Dummy JSON response for an employee
const Map<String, dynamic> dummyEmployeeResponse = {
  "currentUser": {
    "id": "u123",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "mobile": "9876543210",
    "role": "employee",
    "reportingTo": ["manager1", "manager2"],
    "projectList": ["Project A", "Project B"],
    "isActive": true,
    "createdAt": "2023-01-10T10:00:00Z",
    "balance": 12,
    "approved": 5,
    "rejected": 1,
    "pending": 2,
    "organization": "Leavify Inc.",
    "empId": "EMP123",
    "joiningDate": "2022-06-15",
    "workingDays": 220,
    "profileImageUrl": "https://picsum.photos/id/237/200/300",
    "canSendAnnouncement": false,
    "designation": "Software Engineer",
  },
  "myUpcomingLeaves": [
    {
      "userId": "u123",
      "employeeName": "John Doe",
      "startDate": "2025-10-25",
      "endDate": "2025-10-27",
      "reason": "Vacation",
      "status": "approved",
    },
    {
      "userId": "u123",
      "employeeName": "John Doe",
      "startDate": "2025-11-05",
      "endDate": "2025-11-06",
      "reason": "Medical",
      "status": "pending",
    },
  ],
  "teamUpcomingLeaves": [
    {
      "userId": "u124",
      "employeeName": "Alice Smith",
      "startDate": "2025-10-28",
      "endDate": "2025-10-30",
      "reason": "Conference",
      "status": "approved",
    },
    {
      "userId": "u125",
      "employeeName": "Bob Johnson",
      "startDate": "2025-11-01",
      "endDate": "2025-11-03",
      "reason": "Family Event",
      "status": "approved",
    },
    {
      "userId": "u126",
      "employeeName": "Charlie Brown",
      "startDate": "2025-11-05",
      "endDate": "2025-11-07",
      "reason": "Vacation",
      "status": "approved",
    },
    {
      "userId": "u127",
      "employeeName": "Diana Prince",
      "startDate": "2025-11-10",
      "endDate": "2025-11-12",
      "reason": "Medical",
      "status": "approved",
    },
    {
      "userId": "u128",
      "employeeName": "Ethan Hunt",
      "startDate": "2025-11-15",
      "endDate": "2025-11-18",
      "reason": "Vacation",
      "status": "approved",
    },
    {
      "userId": "u129",
      "employeeName": "Fiona Gallagher",
      "startDate": "2025-11-20",
      "endDate": "2025-11-22",
      "reason": "Family Event",
      "status": "approved",
    },
    {
      "userId": "u130",
      "employeeName": "George Martin",
      "startDate": "2025-11-25",
      "endDate": "2025-11-27",
      "reason": "Conference",
      "status": "approved",
    },
  ],
};

/// Converts dummy JSON response into a Dart object
final GetUserSummaryResponse dummyEmployeeData =
    GetUserSummaryResponse.fromJson(dummyEmployeeResponse);
