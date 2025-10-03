class ApplyLeaveRequestModel {
  final String? requestedBy;
  final String userId;
  final String type;
  final String fromDate;
  final String toDate;
  final String reason;
  final String subType;
  final bool isCompOff;
  final bool isHalfDay;
  final List<String> compDates;
  final List<LeaveDocument> documents;

  ApplyLeaveRequestModel({
    this.requestedBy,
    required this.userId,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.subType,
    this.isCompOff = false,
    this.isHalfDay = false,
    this.compDates = const [],
    this.documents = const [],
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "type": type,
    "fromDate": fromDate,
    "toDate": toDate,
    "reason": reason,
    "subType": subType,
    "isCompOff": isCompOff,
    "isHalfDay": isHalfDay,
    "compDates": compDates,
    "documents": documents.map((doc) => doc.toJson()).toList(),
    if (requestedBy != null) "requestedBy": requestedBy,
  };
}

class LeaveDocument {
  final String docType;
  final String docBytes;

  LeaveDocument({required this.docType, required this.docBytes});

  Map<String, dynamic> toJson() => {'docType': docType, 'docBytes': docBytes};
}
