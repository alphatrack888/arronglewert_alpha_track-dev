import 'dart:convert';

class TodayBreakPeriodsModel {
    int? statusCode;
    bool? success;
    String? message;
    Data? data;

    TodayBreakPeriodsModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory TodayBreakPeriodsModel.fromRawJson(String str) => TodayBreakPeriodsModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory TodayBreakPeriodsModel.fromJson(Map<String, dynamic> json) => TodayBreakPeriodsModel(
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
    DateTime? date;
    int? totalBreakPeriods;
    int? totalBreakTime;
    List<BreakPeriod>? breakPeriods;

    Data({
        this.date,
        this.totalBreakPeriods,
        this.totalBreakTime,
        this.breakPeriods,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        totalBreakPeriods: json["totalBreakPeriods"],
        totalBreakTime: json["totalBreakTime"],
        breakPeriods: json["breakPeriods"] == null ? [] : List<BreakPeriod>.from(json["breakPeriods"]!.map((x) => BreakPeriod.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "totalBreakPeriods": totalBreakPeriods,
        "totalBreakTime": totalBreakTime,
        "breakPeriods": breakPeriods == null ? [] : List<dynamic>.from(breakPeriods!.map((x) => x.toJson())),
    };
}

class BreakPeriod {
    String? projectName;
    DateTime? startTime;
    DateTime? endTime;
    int? durationMinutes;
    double? durationHours;

    BreakPeriod({
        this.projectName,
        this.startTime,
        this.endTime,
        this.durationMinutes,
        this.durationHours,
    });

    factory BreakPeriod.fromRawJson(String str) => BreakPeriod.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory BreakPeriod.fromJson(Map<String, dynamic> json) => BreakPeriod(
        projectName: json["projectName"],
        startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
        durationMinutes: json["durationMinutes"],
        durationHours: json["durationHours"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "projectName": projectName,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "durationMinutes": durationMinutes,
        "durationHours": durationHours,
    };
}