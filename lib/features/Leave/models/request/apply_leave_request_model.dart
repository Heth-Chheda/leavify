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
  final List<LeaveDocumentForApply> documents;
  final String? category;

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
    this.category,
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
    if (category != null) "category": category,
  };
}

class LeaveDocumentForApply {
  final String? docType;
  final String? docBytes;

  LeaveDocumentForApply({this.docType, this.docBytes});

  Map<String, dynamic> toJson() => {'docType': docType, 'docBytes': docBytes};
}
