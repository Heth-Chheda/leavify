class GetHolidayListResponse {
  final HolidayList? holidayList;

  GetHolidayListResponse({this.holidayList});

  factory GetHolidayListResponse.fromJson(Map<String, dynamic> json) {
    return GetHolidayListResponse(
      holidayList: json['holidayList'] != null
          ? HolidayList.fromJson(json['holidayList'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'holidayList': holidayList?.toJson()};
  }
}

class HolidayList {
  final String? id;
  final String? year;
  final List<HolidayDate> holidayDates;
  final String? organizationId;

  HolidayList({
    this.id,
    this.year,
    required this.holidayDates,
    this.organizationId,
  });

  factory HolidayList.fromJson(Map<String, dynamic> json) {
    return HolidayList(
      id: json['id'] ?? '',
      year: json['year'] ?? '',
      organizationId: json['organizationId'] ?? '',
      holidayDates:
          (json['holidayDates'] as List<dynamic>?)
              ?.map((e) => HolidayDate.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'organizationId': organizationId,
      'holidayDates': holidayDates.map((e) => e.toJson()).toList(),
    };
  }
}

class HolidayDate {
  final String? date;
  final String? description;
  final bool isOptional;
  final String? groupCode;
  final String? exchangedWith;

  HolidayDate({
    this.date,
    this.description,
    required this.isOptional,
    this.groupCode,
    this.exchangedWith,
  });

  factory HolidayDate.fromJson(Map<String, dynamic> json) {
    return HolidayDate(
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      isOptional: json['isOptional'] ?? false,
      groupCode: json['groupCode'],
      exchangedWith: json['exchangedWith'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'description': description,
      'isOptional': isOptional,
      'groupCode': groupCode,
      'exchangedWith': exchangedWith,
    };
  }
}
