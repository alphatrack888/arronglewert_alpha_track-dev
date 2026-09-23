import 'dart:convert';

class LeaveBalanceLeftModel {
    int? statusCode;
    bool? success;
    String? message;
    Data? data;

    LeaveBalanceLeftModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory LeaveBalanceLeftModel.fromRawJson(String str) => LeaveBalanceLeftModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory LeaveBalanceLeftModel.fromJson(Map<String, dynamic> json) => LeaveBalanceLeftModel(
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
    List<Leavemanagement>? leavemanagements;
    List<CompanyLeaveBalance>? companyLeaveBalance;

    Data({
        this.leavemanagements,
        this.companyLeaveBalance,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        leavemanagements: json["leavemanagements"] == null ? [] : List<Leavemanagement>.from(json["leavemanagements"]!.map((x) => Leavemanagement.fromJson(x))),
        companyLeaveBalance: json["companyLeaveBalance"] == null ? [] : List<CompanyLeaveBalance>.from(json["companyLeaveBalance"]!.map((x) => CompanyLeaveBalance.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "leavemanagements": leavemanagements == null ? [] : List<dynamic>.from(leavemanagements!.map((x) => x.toJson())),
        "companyLeaveBalance": companyLeaveBalance == null ? [] : List<dynamic>.from(companyLeaveBalance!.map((x) => x.toJson())),
    };
}

class CompanyLeaveBalance {
    String? type;
    int? taken;
    int? balance;
    String? status;

    CompanyLeaveBalance({
        this.type,
        this.taken,
        this.balance,
        this.status,
    });

    factory CompanyLeaveBalance.fromRawJson(String str) => CompanyLeaveBalance.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CompanyLeaveBalance.fromJson(Map<String, dynamic> json) => CompanyLeaveBalance(
        type: json["type"],
        taken: json["taken"],
        balance: json["balance"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "taken": taken,
        "balance": balance,
        "status": status,
    };
}

class Leavemanagement {
    String? id;
    String? user;
    Company? company;
    int? totalDays;
    String? type;
    String? status;
    DateTime? from;
    DateTime? to;
    String? reason;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    Leavemanagement({
        this.id,
        this.user,
        this.company,
        this.totalDays,
        this.type,
        this.status,
        this.from,
        this.to,
        this.reason,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Leavemanagement.fromRawJson(String str) => Leavemanagement.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Leavemanagement.fromJson(Map<String, dynamic> json) => Leavemanagement(
        id: json["_id"],
        user: json["user"],
        company: json["company"] == null ? null : Company.fromJson(json["company"]),
        totalDays: json["totalDays"],
        type: json["type"],
        status: json["status"],
        from: json["from"] == null ? null : DateTime.parse(json["from"]),
        to: json["to"] == null ? null : DateTime.parse(json["to"]),
        reason: json["reason"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "user": user,
        "company": company?.toJson(),
        "totalDays": totalDays,
        "type": type,
        "status": status,
        "from": from?.toIso8601String(),
        "to": to?.toIso8601String(),
        "reason": reason,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class Company {
    String? id;
    String? name;
    String? email;

    Company({
        this.id,
        this.name,
        this.email,
    });

    factory Company.fromRawJson(String str) => Company.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Company.fromJson(Map<String, dynamic> json) => Company(
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