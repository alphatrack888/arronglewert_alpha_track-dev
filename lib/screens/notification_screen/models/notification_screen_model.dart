import 'dart:convert';

class NotificationGetModel {
    int? statusCode;
    bool? success;
    String? message;
    Data? data;

    NotificationGetModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory NotificationGetModel.fromRawJson(String str) => NotificationGetModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory NotificationGetModel.fromJson(Map<String, dynamic> json) => NotificationGetModel(
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
    Meta? meta;
    List<Datum>? data;

    Data({
        this.meta,
        this.data,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
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
    From? to;
    From? from;
    String? title;
    String? body;
    bool? isRead;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    Datum({
        this.id,
        this.to,
        this.from,
        this.title,
        this.body,
        this.isRead,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) {
        try {
            return Datum(
                id: json["_id"] ?? json["id"],
                to: json["to"] == null ? null : _parseFromSafely(json["to"]),
                from: json["from"] == null ? null : _parseFromSafely(json["from"]),
                title: json["title"],
                body: json["body"],
                isRead: json["isRead"] ?? false,
                createdAt: json["createdAt"] == null ? null : DateTime.tryParse(json["createdAt"]),
                updatedAt: json["updatedAt"] == null ? null : DateTime.tryParse(json["updatedAt"]),
                v: json["__v"],
            );
        } catch (e) {
            print("Error parsing Datum: $e");
            print("JSON data: $json");
            rethrow;
        }
    }

    static From? _parseFromSafely(Map<String, dynamic>? json) {
        if (json == null) return null;
        try {
            return From.fromJson(json);
        } catch (e) {
            print("Error parsing From object: $e");
            return null;
        }
    }

    Map<String, dynamic> toJson() => {
        "_id": id,
        "to": to?.toJson(),
        "from": from?.toJson(),
        "title": title,
        "body": body,
        "isRead": isRead,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class From {
    String? id;
    String? name;
    String? email;
    String? phone;
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
    String? company;

    From({
        this.id,
        this.name,
        this.email,
        this.phone,
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
        this.company,
    });

    factory From.fromRawJson(String str) => From.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory From.fromJson(Map<String, dynamic> json) => From(
        id: json["_id"] ?? json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
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
        createdAt: json["createdAt"] == null ? null : DateTime.tryParse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.tryParse(json["updatedAt"]),
        v: json["__v"],
        company: json["company"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "phone": phone,
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
        "company": company,
    };
}

// Removed enum classes and mapping values - using direct string parsing instead

class Location {
    Type? type;
    List<int>? coordinates;

    Location({
        this.type,
        this.coordinates,
    });

    factory Location.fromRawJson(String str) => Location.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json["type"] == "Point" ? Type.POINT : null,
        coordinates: json["coordinates"] == null ? [] : List<int>.from(json["coordinates"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "type": type == Type.POINT ? "Point" : null,
        "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
    };
}

enum Type {
    POINT
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