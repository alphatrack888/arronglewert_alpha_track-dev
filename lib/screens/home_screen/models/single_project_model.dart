import 'dart:convert';

class SingleProjectModel {
    int? statusCode;
    bool? success;
    String? message;
    SingleProjectModelData? data;

    SingleProjectModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory SingleProjectModel.fromRawJson(String str) => SingleProjectModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory SingleProjectModel.fromJson(Map<String, dynamic> json) => SingleProjectModel(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : SingleProjectModelData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class SingleProjectModelData {
    String? id;
    String? title;
    List<String>? employees;
    Company? company;
    int? duration;
    DateTime? startDate;
    DateTime? endDate;
    int? projectTime;
    List<String>? images;
    String? audio; // Added audio field
    String? status;
    String? description;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    SingleProjectModelData({
        this.id,
        this.title,
        this.employees,
        this.company,
        this.duration,
        this.startDate,
        this.endDate,
        this.projectTime,
        this.images,
        this.audio, // Added audio field
        this.status,
        this.description,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory SingleProjectModelData.fromRawJson(String str) => SingleProjectModelData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory SingleProjectModelData.fromJson(Map<String, dynamic> json) => SingleProjectModelData(
        id: json["_id"],
        title: json["title"],
        employees: json["employees"] == null ? [] : List<String>.from(json["employees"]!.map((x) => x)),
        company: json["company"] == null ? null : Company.fromJson(json["company"]),
        duration: json["duration"],
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        projectTime: json["projectTime"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        audio: json["audio"], // Added audio field
        status: json["status"],
        description: json["description"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "employees": employees == null ? [] : List<dynamic>.from(employees!.map((x) => x)),
        "company": company?.toJson(),
        "duration": duration,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "projectTime": projectTime,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "audio": audio, // Added audio field
        "status": status,
        "description": description,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class Company {
    String? id;
    String? name;

    Company({
        this.id,
        this.name,
    });

    factory Company.fromRawJson(String str) => Company.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json["_id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
    };
}