import 'package:leavify/features/Leave/models/general/my_leaves.dart';

/// Dummy JSON response for LeaveData
const Map<String, dynamic> dummyLeaveResponse = {
  "userId": "user123",
  "balanceLeaves": 10,
  "approvedLeaves": 5,
  "pendingLeaves": 2,
  "rejectedLeaves": 1,
  "cancelledLeaves": 0,
  "allLeaves": [
    {
      "id": "leave001",
      "type": "Annual Leave",
      "fromDate": "2025-09-25T00:00:00.000Z",
      "toDate": "2025-09-27T00:00:00.000Z",
      "reason": "Family function",
      "status": "APPROVED",
      "isHalfDay": false,
      "isCompOff": false,
      "compDates": [],
      "createdAt": "2025-09-20T00:00:00.000Z",
      "updatedAt": "2025-09-22T00:00:00.000Z",
    },
    {
      "id": "leave002",
      "type": "Sick Leave",
      "fromDate": "2025-09-29T00:00:00.000Z",
      "toDate": "2025-09-29T00:00:00.000Z",
      "reason": "Fever and cold",
      "status": "PENDING",
      "isHalfDay": true,
      "isCompOff": false,
      "compDates": [],
      "createdAt": "2025-09-28T00:00:00.000Z",
      "updatedAt": "2025-09-28T00:00:00.000Z",
    },
    {
      "id": "leave003",
      "type": "Comp Off",
      "fromDate": "2025-09-15T00:00:00.000Z",
      "toDate": "2025-09-15T00:00:00.000Z",
      "reason": "Worked on weekend",
      "status": "REJECTED",
      "isHalfDay": false,
      "isCompOff": true,
      "compDates": ["2025-09-14T00:00:00.000Z"],
      "createdAt": "2025-09-14T00:00:00.000Z",
      "updatedAt": "2025-09-16T00:00:00.000Z",
    },
  ],
};

/// Converts dummy JSON into a Dart object
final LeaveData dummyLeaveData = LeaveData.fromJson(dummyLeaveResponse);
