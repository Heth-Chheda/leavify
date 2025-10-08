import 'package:leavify/features/Leave/models/response/get_leave_by_id_response.dart';

/// Dummy JSON response for GetLeaveByIdResponse
const Map<String, dynamic> dummyLeaveByIdResponse = {
  "userId": "user123",
  "leaveId": "leave456",
  "employeeName": "John Doe",
  "workingDaysCount": 20,
  "balanceLeaves": 12,
  "leaveDetails": {
    "type": "Casual",
    "createdAt": "2025-10-01T10:00:00Z",
    "fromDate": "2025-10-10T00:00:00Z",
    "toDate": "2025-10-12T00:00:00Z",
    "reason": "Family event",
    "documents": [
      {
        "id": "doc1",
        "name": "Medical_Certificate.pdf",
        "url": "https://example.com/docs/medical_certificate.pdf",
      },
    ],
    "isCompOff": false,
    "compDates": [],
    "isHalfDay": false,
    "status": "PENDING",
    "isEscalated": false,
    "reqStatusTracking": [
      {
        "status": "PENDING",
        "processedBy": "Manager A",
        "processedAt": "2025-10-01T12:00:00Z",
        "comment": "Waiting for approval",
      },
    ],
    "escalationDet": null,
    "updatedAt": "2025-10-01T12:00:00Z",
    "reminderDetails": {
      "reminderSentAt": "2025-10-01T11:00:00Z",
      "reminderCount": 1,
    },
  },
  "currentUserAction": {
    "managerId": "mgr789",
    "managerName": "Manager A",
    "profileImageUrl": "https://example.com/profiles/mgr789.png",
    "latestStatus": "PENDING",
    "lastActionAt": "2025-10-01T12:00:00Z",
    "isPending": true,
    "isCurrentUser": false,
  },
};

/// Converts dummy JSON into a Dart object
final GetLeaveByIdResponse dummyLeaveByIdData = GetLeaveByIdResponse.fromJson(
  dummyLeaveByIdResponse,
);
