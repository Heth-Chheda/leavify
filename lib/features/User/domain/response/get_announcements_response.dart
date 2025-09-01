class GetAnnouncementsResponse {
  final String profileImage;
  final String senderName;
  final String title;
  final String body;
  final String timeAgo;

  GetAnnouncementsResponse({
    required this.profileImage,
    required this.senderName,
    required this.body,
    required this.timeAgo,
    required this.title
  });

  factory GetAnnouncementsResponse.fromJson(Map<String, dynamic> json) {
    return GetAnnouncementsResponse(
      profileImage: json['profileImage'] ?? '',
      senderName: json['senderName'] ?? '',
      body: json['body'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImage': profileImage,
      'senderName': senderName,
      'body': body,
      'timeAgo': timeAgo,
      'title' : title,
    };
  }
}
