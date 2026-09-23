import 'dart:convert';

class PayrollModel {
    int? statusCode;
    bool? success;
    String? message;
    List<Datum>? data;

    PayrollModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory PayrollModel.fromRawJson(String str) => PayrollModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PayrollModel.fromJson(Map<String, dynamic> json) => PayrollModel(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "success": success,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    String? id;
    String? company;
    Employee? employee;
    List<String>? files;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    Datum({
        this.id,
        this.company,
        this.employee,
        this.files,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        company: json["company"],
        employee: json["employee"] == null ? null : Employee.fromJson(json["employee"]),
        files: json["files"] == null ? [] : List<String>.from(json["files"]!.map((x) => x)),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "company": company,
        "employee": employee?.toJson(),
        "files": files == null ? [] : List<dynamic>.from(files!.map((x) => x)),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class Employee {
    String? id;
    String? name;
    String? email;

    Employee({
        this.id,
        this.name,
        this.email,
    });

    factory Employee.fromRawJson(String str) => Employee.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
    };
}