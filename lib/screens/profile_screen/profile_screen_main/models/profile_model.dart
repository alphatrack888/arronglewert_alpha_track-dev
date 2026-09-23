import 'dart:convert';

class ProfileModel {
    int? statusCode;
    bool? success;
    String? message;
    ProfileModelData? data;

    ProfileModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory ProfileModel.fromRawJson(String str) => ProfileModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : ProfileModelData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class ProfileModelData {
    String? id;
    String? name;
    String? email;
    String? phone;
    Company? company;
    String? status;
    bool? verified;
    String? profile;
    String? role;
    String? address;
    Location? location;
    dynamic stripeCustomerId;
    dynamic subscriptionStatus;
    dynamic subscriptionTier;
    bool? trialUsed;
    bool? manualBreak;
    dynamic subscriptionExpiresAt;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    ProfileModelData({
        this.id,
        this.name,
        this.email,
        this.phone,
        this.company,
        this.status,
        this.verified,
        this.profile,
        this.role,
        this.address,
        this.location,
        this.stripeCustomerId,
        this.subscriptionStatus,
        this.subscriptionTier,
        this.trialUsed,
        this.manualBreak,
        this.subscriptionExpiresAt,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory ProfileModelData.fromRawJson(String str) => ProfileModelData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ProfileModelData.fromJson(Map<String, dynamic> json) => ProfileModelData(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        company: json["company"] == null ? null : Company.fromJson(json["company"]),
        status: json["status"],
        verified: json["verified"],
        profile: json["profile"],
        role: json["role"],
        address: json["address"],
        location: json["location"] == null ? null : Location.fromJson(json["location"]),
        stripeCustomerId: json["stripeCustomerId"],
        subscriptionStatus: json["subscriptionStatus"],
        subscriptionTier: json["subscriptionTier"],
        trialUsed: json["trialUsed"],
        manualBreak: json["manualBreak"],
        subscriptionExpiresAt: json["subscriptionExpiresAt"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "company": company?.toJson(),
        "status": status,
        "verified": verified,
        "profile": profile,
        "role": role,
        "address": address,
        "location": location?.toJson(),
        "stripeCustomerId": stripeCustomerId,
        "subscriptionStatus": subscriptionStatus,
        "subscriptionTier": subscriptionTier,
        "trialUsed": trialUsed,
        "manualBreak": manualBreak,
        "subscriptionExpiresAt": subscriptionExpiresAt,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class Company {
    String? id;
    String? name;
    String? email;
    String? phone;
    String? profile;
    String? address;

    Company({
        this.id,
        this.name,
        this.email,
        this.phone,
        this.profile,
        this.address,
    });

    factory Company.fromRawJson(String str) => Company.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        profile: json["profile"],
        address: json["address"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "profile": profile,
        "address": address,
    };
}

class Location {
    String? type;
    List<int>? coordinates;

    Location({
        this.type,
        this.coordinates,
    });

    factory Location.fromRawJson(String str) => Location.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json["type"],
        coordinates: json["coordinates"] == null ? [] : List<int>.from(json["coordinates"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
    };
}
