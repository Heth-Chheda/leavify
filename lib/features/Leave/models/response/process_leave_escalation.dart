class ProcessEscalatedLeaveResponse {
  final String message;
  final String resolvedBy;
  final String comment;
  final bool success;

  ProcessEscalatedLeaveResponse({
    required this.message,
    required this.resolvedBy,
    required this.comment,
    required this.success,
  });

  factory ProcessEscalatedLeaveResponse.fromJson(Map<String, dynamic> json) {
    return ProcessEscalatedLeaveResponse(
      message: json['message'] ?? '',
      resolvedBy: json['resolvedBy'] ?? '',
      comment: json['comment'] ?? '',
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'resolvedBy': resolvedBy,
      'comment': comment,
      'success': success,
    };
  }
}
