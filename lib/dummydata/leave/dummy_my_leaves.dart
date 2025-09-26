import 'package:leavify/features/Leave/models/general/my_leaves.dart';

final dummyLeaveDataJson = {
  "userId": "u101",
  "balanceLeaves": 12,
  "approvedLeaves": 5,
  "pendingLeaves": 2,
  "rejectedLeaves": 1,
  "cancelledLeaves": 1,
  "allLeaves": [
    {
      "id": "l001",
      "type": "Sick Leave",
      "fromDate": "2025-09-20T00:00:00.000Z",
      "toDate": "2025-09-21T00:00:00.000Z",
      "reason": "Fever and cold",
      "status": "Approved",
      "isHalfDay": false,
      "isCompOff": false,
      "compDates": [],
      "createdAt": "2025-09-15T10:30:00.000Z",
      "updatedAt": "2025-09-18T12:00:00.000Z",
    },
    {
      "id": "l002",
      "type": "Casual Leave",
      "fromDate": "2025-10-02T00:00:00.000Z",
      "toDate": "2025-10-02T00:00:00.000Z",
      "reason": "Family event",
      "status": "Pending",
      "isHalfDay": true,
      "isCompOff": false,
      "compDates": [],
      "createdAt": "2025-09-25T09:15:00.000Z",
      "updatedAt": "2025-09-25T09:15:00.000Z",
    },
    {
      "id": "l003",
      "type": "Comp Off",
      "fromDate": "2025-09-10T00:00:00.000Z",
      "toDate": "2025-09-10T00:00:00.000Z",
      "reason": "Worked on weekend",
      "status": "Approved",
      "isHalfDay": false,
      "isCompOff": true,
      "compDates": ["2025-09-07T00:00:00.000Z"],
      "createdAt": "2025-09-08T08:45:00.000Z",
      "updatedAt": "2025-09-09T14:20:00.000Z",
    },
  ],
};

final LeaveData dummyLeaveData = LeaveData.fromJson(dummyLeaveDataJson);
