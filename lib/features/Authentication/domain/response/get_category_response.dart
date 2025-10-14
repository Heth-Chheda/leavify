// models/leave_category_response.dart
class LeaveCategoryResponse {
  final List<LeaveCategory> categories;

  LeaveCategoryResponse({required this.categories});

  factory LeaveCategoryResponse.fromJson(Map<String, dynamic> json) {
    return LeaveCategoryResponse(
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => LeaveCategory.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'categories': categories.map((e) => e.toJson()).toList()};
  }
}

class LeaveCategory {
  final String name;
  final String description;

  LeaveCategory({required this.name, required this.description});

  factory LeaveCategory.fromJson(Map<String, dynamic> json) {
    return LeaveCategory(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}
