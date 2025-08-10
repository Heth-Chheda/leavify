class SendReminderResponse {
  final bool success;
  final String message;
  final ReminderDetails? reminderDetails;
  final String? error;

  SendReminderResponse({
    required this.success,
    required this.message,
    this.reminderDetails,
    this.error,
  });

  factory SendReminderResponse.fromJson(Map<String, dynamic> json) {
    return SendReminderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      reminderDetails: json['reminderDetails'] != null
          ? ReminderDetails.fromJson(json['reminderDetails'])
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'reminderDetails': reminderDetails?.toJson(),
      'error': error,
    };
  }
}

class ReminderDetails {
  final DateTime reminderSentAt;
  final int reminderCount;

  ReminderDetails({required this.reminderSentAt, required this.reminderCount});

  factory ReminderDetails.fromJson(Map<String, dynamic> json) {
    return ReminderDetails(
      reminderSentAt: DateTime.parse(json['reminderSentAt']),
      reminderCount: json['reminderCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderSentAt': reminderSentAt.toIso8601String(),
      'reminderCount': reminderCount,
    };
  }
}
