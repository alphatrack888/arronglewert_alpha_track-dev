import 'dart:convert';

class LeaveBalanceModel {
  int? statusCode;
  bool? success;
  String? message;
  List<LeaveBalanceModelData>? data;

  LeaveBalanceModel({this.statusCode, this.success, this.message, this.data});

  factory LeaveBalanceModel.fromRawJson(String str) =>
      LeaveBalanceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) =>
      LeaveBalanceModel(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<LeaveBalanceModelData>.from(
                json["data"]!.map((x) => LeaveBalanceModelData.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class LeaveBalanceModelData {
  String? id;
  Company? company;
  int? casualLeave;
  int? sickLeave;
  int? earnLeave;
  int? wpLeave;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  LeaveBalanceModelData({
    this.id,
    this.company,
    this.casualLeave,
    this.sickLeave,
    this.earnLeave,
    this.wpLeave,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory LeaveBalanceModelData.fromRawJson(String str) =>
      LeaveBalanceModelData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeaveBalanceModelData.fromJson(Map<String, dynamic> json) =>
      LeaveBalanceModelData(
        id: json["_id"],
        company: json["company"] == null
            ? null
            : Company.fromJson(json["company"]),
        casualLeave: json["casualLeave"],
        sickLeave: json["sickLeave"],
        earnLeave: json["earnLeave"],
        wpLeave: json["wpLeave"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "company": company?.toJson(),
    "casualLeave": casualLeave,
    "sickLeave": sickLeave,
    "earnLeave": earnLeave,
    "wpLeave": wpLeave,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Company {
  String? id;
  String? name;
  String? email;

  Company({this.id, this.name, this.email});

  factory Company.fromRawJson(String str) => Company.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Company.fromJson(Map<String, dynamic> json) =>
      Company(id: json["_id"], name: json["name"], email: json["email"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "email": email};
}
