class VersionResponse {
  final String version;

  VersionResponse({
    required this.version,
  });

  factory VersionResponse.fromJson(Map<String, dynamic> json) {
    return VersionResponse(
      version: json['version']?.toString() ?? ""
    );
  }
}
