class AddAnnouncementRequest {
  final String? title;
  final String? body;
  final String? screen;
  final String? type;
  final String? persistTill;
  final String? userId;
  final String? leaveId;
  final String? sentBy;

  AddAnnouncementRequest({
    this.title,
    this.body,
    this.screen,
    this.type,
    this.persistTill,
    this.userId,
    this.leaveId,
    this.sentBy,
  });

  factory AddAnnouncementRequest.fromJson(Map<String, dynamic> json) {
    return AddAnnouncementRequest(
      title: json['title'] as String?,
      body: json['body'] as String?,
      screen: json['screen'] as String?,
      type: json['type'] as String?,
      persistTill: json['persistTill'] as String?,
      userId: json['userId'] as String?,
      leaveId: json['leaveId'] as String?,
      sentBy: json['sentBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (screen != null) 'screen': screen,
      if (type != null) 'type': type,
      if (persistTill != null) 'persistTill': persistTill,
      if (userId != null) 'userId': userId,
      if (leaveId != null) 'leaveId': leaveId,
      if (sentBy != null) 'sentBy': sentBy,
    };
  }
}
