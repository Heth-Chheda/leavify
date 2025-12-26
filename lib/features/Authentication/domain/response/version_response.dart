class VersionResponse {
  final String version;
  final bool isMaintenanceMode;

  VersionResponse({required this.version, required this.isMaintenanceMode});

  factory VersionResponse.fromJson(Map<String, dynamic> json) {
    return VersionResponse(
      version: json['version']?.toString() ?? "",
      isMaintenanceMode: json['maintenanceMode'] == true,
    );
  }
}
