class LeaveDocument {
  final String docType;
  final String docPath;
  final String docBytes;

  LeaveDocument({
    required this.docType,
    required this.docPath,
    required this.docBytes,
  });

  Map<String, dynamic> toJson() {
    return {'docType': docType, 'docPath': docPath, 'docBytes': docBytes};
  }

  factory LeaveDocument.fromJson(Map<String, dynamic> json) {
    return LeaveDocument(
      docType: json['docType'] ?? '',
      docPath: json['docPath'] ?? '',
      docBytes: json['docBytes'] ?? '',
    );
  }
}
