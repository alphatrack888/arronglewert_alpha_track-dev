import 'dart:convert';

class AllProjectModel {
    int? statusCode;
    bool? success;
    String? message;
    AllProjectModelData? data;

    AllProjectModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory AllProjectModel.fromRawJson(String str) => AllProjectModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AllProjectModel.fromJson(Map<String, dynamic> json) => AllProjectModel(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : AllProjectModelData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class AllProjectModelData {
    Meta? meta;
    List<Datum>? data;

    AllProjectModelData({
        this.meta,
        this.data,
    });

    factory AllProjectModelData.fromRawJson(String str) => AllProjectModelData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AllProjectModelData.fromJson(Map<String, dynamic> json) => AllProjectModelData(
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "meta": meta?.toJson(),
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    String? id;
    String? title;
    List<String>? employees;
    Company? company;
    int? duration;
    DateTime? startDate;
    DateTime? endDate;
    int? projectTime;
    List<String>? images;
    String? status;
    String? description;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    Datum({
        this.id,
        this.title,
        this.employees,
        this.company,
        this.duration,
        this.startDate,
        this.endDate,
        this.projectTime,
        this.images,
        this.status,
        this.description,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        title: json["title"],
        employees: json["employees"] == null ? [] : List<String>.from(json["employees"]!.map((x) => x)),
        company: json["company"] == null ? null : Company.fromJson(json["company"]),
        duration: json["duration"],
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        projectTime: json["projectTime"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
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

class Meta {
    int? page;
    int? limit;
    int? total;
    int? totalPages;

    Meta({
        this.page,
        this.limit,
        this.total,
        this.totalPages,
    });

    factory Meta.fromRawJson(String str) => Meta.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
        totalPages: json["totalPages"],
    );

    Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "totalPages": totalPages,
    };
}
