class ApplyLeaveRequestModel {
  final String userId;
  final String type;
  final String fromDate;
  final String toDate;
  final String reason;
  final bool isCompOff;
  final bool isHalfDay;
  final List<String> compDates;
  final List<String> documents;

  ApplyLeaveRequestModel({
    required this.userId,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.reason,
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
    "isCompOff": isCompOff,
    "isHalfDay": isHalfDay,
    "compDates": compDates,
    "documents": documents,
  };
}