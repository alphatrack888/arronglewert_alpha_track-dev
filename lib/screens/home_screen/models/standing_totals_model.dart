import 'dart:convert';

class StandingTotalsModel {
  int? statusCode;
  bool? success;
  String? message;
  StandingTotalsData? data;

  StandingTotalsModel({
    this.statusCode,
    this.success,
    this.message,
    this.data,
  });

  factory StandingTotalsModel.fromRawJson(String str) =>
      StandingTotalsModel.fromJson(json.decode(str));

  factory StandingTotalsModel.fromJson(Map<String, dynamic> json) =>
      StandingTotalsModel(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : StandingTotalsData.fromJson(json["data"]),
      );
}

class StandingTotalsData {
  double? workedHours;
  double? allocatedHours;
  double? overtimeHours;
  double? breakHours;
  int? projectCount;

  StandingTotalsData({
    this.workedHours,
    this.allocatedHours,
    this.overtimeHours,
    this.breakHours,
    this.projectCount,
  });

  factory StandingTotalsData.fromJson(Map<String, dynamic> json) =>
      StandingTotalsData(
        workedHours: (json["workedHours"] as num?)?.toDouble(),
        allocatedHours: (json["allocatedHours"] as num?)?.toDouble(),
        overtimeHours: (json["overtimeHours"] as num?)?.toDouble(),
        breakHours: (json["breakHours"] as num?)?.toDouble(),
        projectCount: (json["projectCount"] as num?)?.toInt(),
      );
}
