class ReporteesResponse {
  final List<Reportee> reportees;

  ReporteesResponse({required this.reportees});

  factory ReporteesResponse.fromJson(Map<String, dynamic> json) {
    return ReporteesResponse(
      reportees: (json['reportees'] as List<dynamic>)
          .map((item) => Reportee.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'reportees': reportees.map((e) => e.toJson()).toList()};
  }
}

class Reportee {
  final String fName;
  final String lName;
  final String profileImagePath;
  final String id;

  Reportee({
    required this.fName,
    required this.lName,
    required this.profileImagePath,
    required this.id,
  });

  factory Reportee.fromJson(Map<String, dynamic> json) {
    return Reportee(
      fName: json['fName'] ?? '',
      lName: json['lName'] ?? '',
      profileImagePath: json['profileImagePath'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fName': fName,
      'lName': lName,
      'profileImagePath': profileImagePath,
      '_id': id,
    };
  }
}
