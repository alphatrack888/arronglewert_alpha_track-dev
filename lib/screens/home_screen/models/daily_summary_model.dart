import 'dart:convert';

class DailySummaryModel {
    int? statusCode;
    bool? success;
    String? message;
    Data? data;

    DailySummaryModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory DailySummaryModel.fromRawJson(String str) => DailySummaryModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DailySummaryModel.fromJson(Map<String, dynamic> json) => DailySummaryModel(
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
    String? totalTime;
    String? overtime;
    String? totalBreakInHours;
    String? totalBreakInHoursFormatted;
    String? overtimeInHoursFormatted;
    List<Session>? sessions;

    Data({
        this.totalTime,
        this.overtime,
        this.totalBreakInHours,
        this.totalBreakInHoursFormatted,
        this.overtimeInHoursFormatted,
        this.sessions,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalTime: json["totalTime"],
        overtime: json["overtime"],
        totalBreakInHours: json["totalBreakInHours"],
        totalBreakInHoursFormatted: json["totalBreakInHoursFormatted"],
        overtimeInHoursFormatted: json["overtimeInHoursFormatted"],
        sessions: json["sessions"] == null ? [] : List<Session>.from(json["sessions"]!.map((x) => Session.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "totalTime": totalTime,
        "overtime": overtime,
        "totalBreakInHours": totalBreakInHours,
        "totalBreakInHoursFormatted": totalBreakInHoursFormatted,
        "overtimeInHoursFormatted": overtimeInHoursFormatted,
        "sessions": sessions == null ? [] : List<dynamic>.from(sessions!.map((x) => x.toJson())),
    };
}

class Session {
    String? id;
    String? user;
    Project? project;
    DateTime? startTime;
    List<Pause>? pauses;
    int? totalTime;
    String? status;
    List<Location>? locations;
    DateTime? date;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;
    DateTime? endTime;

    Session({
        this.id,
        this.user,
        this.project,
        this.startTime,
        this.pauses,
        this.totalTime,
        this.status,
        this.locations,
        this.date,
        this.createdAt,
        this.updatedAt,
        this.v,
        this.endTime,
    });

    factory Session.fromRawJson(String str) => Session.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json["_id"],
        user: json["user"],
        project: json["project"] == null ? null : Project.fromJson(json["project"]),
        startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
        pauses: json["pauses"] == null ? [] : List<Pause>.from(json["pauses"]!.map((x) => Pause.fromJson(x))),
        totalTime: json["totalTime"],
        status: json["status"],
        locations: json["locations"] == null ? [] : List<Location>.from(json["locations"]!.map((x) => Location.fromJson(x))),
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "user": user,
        "project": project?.toJson(),
        "startTime": startTime?.toIso8601String(),
        "pauses": pauses == null ? [] : List<dynamic>.from(pauses!.map((x) => x.toJson())),
        "totalTime": totalTime,
        "status": status,
        "locations": locations == null ? [] : List<dynamic>.from(locations!.map((x) => x.toJson())),
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "endTime": endTime?.toIso8601String(),
    };
}

class Location {
    DateTime? timestamp;
    List<double>? coordinates;
    String? action;

    Location({
        this.timestamp,
        this.coordinates,
        this.action,
    });

    factory Location.fromRawJson(String str) => Location.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
        coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
        action: json["action"],
    );

    Map<String, dynamic> toJson() => {
        "timestamp": timestamp?.toIso8601String(),
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
        "action": action,
    };
}

class Pause {
    DateTime? start;
    String? id;
    DateTime? end;

    Pause({
        this.start,
        this.id,
        this.end,
    });

    factory Pause.fromRawJson(String str) => Pause.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Pause.fromJson(Map<String, dynamic> json) => Pause(
        start: json["start"] == null ? null : DateTime.parse(json["start"]),
        id: json["_id"],
        end: json["end"] == null ? null : DateTime.parse(json["end"]),
    );

    Map<String, dynamic> toJson() => {
        "start": start?.toIso8601String(),
        "_id": id,
        "end": end?.toIso8601String(),
    };
}

class Project {
    String? id;

    Project({
        this.id,
    });

    factory Project.fromRawJson(String str) => Project.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
    };
}
