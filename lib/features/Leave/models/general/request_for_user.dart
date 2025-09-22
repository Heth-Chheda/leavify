class RequestForUser {
  final String userId;
  final String name;
  final String? profileImageUrl;

  RequestForUser({
    required this.userId,
    required this.name,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "name": name,
    if (profileImageUrl != null) "profileImageUrl": profileImageUrl,
  };
}
