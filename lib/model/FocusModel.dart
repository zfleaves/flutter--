import 'dart:io';  
import 'dart:convert';

FocusModel focusModelFromJson(String str) =>
    FocusModel.fromJson(json.decode(str));

String focusModelToJson(FocusModel data) => json.encode(data.toJson());

class FocusModel {
  List<Result> result;

  FocusModel({
    required this.result,
  });

  factory FocusModel.fromJson(Map<String, dynamic> json) => FocusModel(
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class Result {
  String id;
  String title;
  String status;
  String pic;
  String? url;

  Result({
    required this.id,
    required this.title,
    required this.status,
    required this.pic,
    this.url,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["_id"],
        title: json["title"],
        status: json["status"],
        pic: json["pic"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "status": status,
        "pic": pic,
        "url": url,
      };
}
