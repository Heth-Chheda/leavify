class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String role;
  final List<String> reportingTo;
  final List<String> projectList;
  final bool isActive;
  final String createdAt;
  final int balance;
  final int approved;
  final int rejected;
  final int pending;
  final String organization;
  final String empId;
  final String joiningDate;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.role,
    required this.reportingTo,
    required this.projectList,
    required this.isActive,
    required this.createdAt,
    required this.balance,
    required this.approved,
    required this.rejected,
    required this.pending,
    required this.organization,
    required this.empId,
    required this.joiningDate,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    email: json['email'] ?? '',
    mobile: json['mobile'] ?? '',
    role: json['role'] ?? '',
    reportingTo: List<String>.from(json['reportingTo'] ?? []),
    projectList: List<String>.from(json['projectList'] ?? []),
    isActive: json['isActive'] ?? false,
    createdAt: json['createdAt'] ?? '',
    balance: json['balance'] ?? 0,
    approved: json['approved'] ?? 0,
    rejected: json['rejected'] ?? 0,
    pending: json['pending'] ?? 0,
    organization: json['organization'] ?? '',
    empId: json['empId'] ?? '',
    joiningDate: json['joiningDate'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'mobile': mobile,
    'role': role,
    'reportingTo': reportingTo,
    'projectList': projectList,
    'isActive': isActive,
    'createdAt': createdAt,
    'balance': balance,
    'approved': approved,
    'rejected': rejected,
    'pending': pending,
    'organization': organization,
    'empId': empId,
    'joiningDate': joiningDate,
  };
}
