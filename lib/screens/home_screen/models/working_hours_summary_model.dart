import 'dart:convert';

class WorkingHoursSummaryModel {
  int? statusCode;
  bool? success;
  String? message;
  Data? data;

  WorkingHoursSummaryModel({
    this.statusCode,
    this.success,
    this.message,
    this.data,
  });

  factory WorkingHoursSummaryModel.fromRawJson(String str) =>
      WorkingHoursSummaryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WorkingHoursSummaryModel.fromJson(Map<String, dynamic> json) =>
      WorkingHoursSummaryModel(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  double? today;
  double? thisWeek;
  double? thisMonth;

  Data({this.today, this.thisWeek, this.thisMonth});

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    today: json["today"]?.toDouble(),
    thisWeek: json["thisWeek"]?.toDouble(),
    thisMonth: json["thisMonth"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "today": today,
    "thisWeek": thisWeek,
    "thisMonth": thisMonth,
  };
}
