import 'dart:convert';

class GalleryModel {
  int? statusCode;
  bool? success;
  String? message;
  List<Datum>? data;

  GalleryModel({this.statusCode, this.success, this.message, this.data});

  factory GalleryModel.fromRawJson(String str) =>
      GalleryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GalleryModel.fromJson(Map<String, dynamic> json) => GalleryModel(
    statusCode: json["statusCode"],
    success: json["success"],
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
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

class Datum {
  String? id;
  String? image;

  Datum({this.id, this.image});

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) =>
      Datum(id: json["_id"], image: json["image"]);

  Map<String, dynamic> toJson() => {"_id": id, "image": image};
}
