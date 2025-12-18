class UserReportee {
  final String userId;
  final String firstName;
  final String lastName;
  final String designation;
  final String? profileImagePath;

  UserReportee({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.designation,
    this.profileImagePath,
  });

  /// Create object from JSON
  factory UserReportee.fromJson(Map<String, dynamic> json) {
    return UserReportee(
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      designation: json['designation'] as String,
      profileImagePath: json['profileImagePath'],
    );
  }

  /// Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'designation': designation,
      'profileImagePath': profileImagePath,
    };
  }

  /// Convenience getter
  String get fullName => '$firstName $lastName';
}
