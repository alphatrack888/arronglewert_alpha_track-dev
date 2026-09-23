import 'dart:convert';

class AllNoteModel {
    int? statusCode;
    bool? success;
    String? message;
    List<Datum>? data;

    AllNoteModel({
        this.statusCode,
        this.success,
        this.message,
        this.data,
    });

    factory AllNoteModel.fromRawJson(String str) => AllNoteModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AllNoteModel.fromJson(Map<String, dynamic> json) => AllNoteModel(
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
    String? project;
    CreatedBy? createdBy;
    List<String>? audio;
    String? content;
    List<String>? images;
    List<dynamic>? files;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    Datum({
        this.id,
        this.project,
        this.createdBy,
        this.audio,
        this.content,
        this.images,
        this.files,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        project: json["project"],
        createdBy: json["createdBy"] == null ? null : CreatedBy.fromJson(json["createdBy"]),
        audio: json["audio"] == null ? [] : List<String>.from(json["audio"]!.map((x) => x)),
        content: json["content"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        files: json["files"] == null ? [] : List<dynamic>.from(json["files"]!.map((x) => x)),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "project": project,
        "createdBy": createdBy?.toJson(),
        "audio": audio == null ? [] : List<dynamic>.from(audio!.map((x) => x)),
        "content": content,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "files": files == null ? [] : List<dynamic>.from(files!.map((x) => x)),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class CreatedBy {
    String? id;
    String? name;
    String? profile;

    CreatedBy({
        this.id,
        this.name,
        this.profile,
    });

    factory CreatedBy.fromRawJson(String str) => CreatedBy.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["_id"],
        name: json["name"],
        profile: json["profile"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "profile": profile,
    };
}