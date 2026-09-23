import 'dart:convert';

class BreakHoursModel {
    int? statusCode;
    bool? success;
    String? message;
    Data? data;

    BreakHoursModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory BreakHoursModel.fromRawJson(String str) => BreakHoursModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory BreakHoursModel.fromJson(Map<String, dynamic> json) => BreakHoursModel(
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
    int? sun;
    double? mon;
    double? tue;
    double? wed;
    int? thu;
    int? fri;
    int? sat;

    Data({
        this.sun,
        this.mon,
        this.tue,
        this.wed,
        this.thu,
        this.fri,
        this.sat,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        sun: json["Sun"],
        mon: json["Mon"]?.toDouble(),
        tue: json["Tue"]?.toDouble(),
        wed: json["Wed"]?.toDouble(),
        thu: json["Thu"],
        fri: json["Fri"],
        sat: json["Sat"],
    );

    Map<String, dynamic> toJson() => {
        "Sun": sun,
        "Mon": mon,
        "Tue": tue,
        "Wed": wed,
        "Thu": thu,
        "Fri": fri,
        "Sat": sat,
    };
}