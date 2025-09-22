class LeaveDocument {
  final String docType;
  final String docPath;

  LeaveDocument({required this.docType, required this.docPath});

  Map<String, dynamic> toJson() {
    return {'docType': docType, 'docPath': docPath};
  }

  factory LeaveDocument.fromJson(Map<String, dynamic> json) {
    return LeaveDocument(
      docType: json['docType'] ?? '',
      docPath: json['docPath'] ?? '',
    );
  }
}
