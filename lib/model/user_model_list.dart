
import 'dart:convert';

import 'package:dio_lesson/model/user_model.dart';

UserModelList userModelListFromJson(String str) => UserModelList.fromJson(json.decode(str));

String userModelListToJson(UserModelList data) => json.encode(data.toJson());

class UserModelList {
  UserModelList({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.userList,
    required this.support,
  });

  int page;
  int perPage;
  int total;
  int totalPages;
  List<UserModel> userList;
  Support support;

  factory UserModelList.fromJson(Map<String, dynamic> json) => UserModelList(
    page: json["page"],
    perPage: json["per_page"],
    total: json["total"],
    totalPages: json["total_pages"],
    userList: List<UserModel>.from(json["data"].map((x) => UserModel.fromJson(x))),
    support: Support.fromJson(json["support"]),
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "per_page": perPage,
    "total": total,
    "total_pages": totalPages,
    "data": List<dynamic>.from(userList.map((x) => x.toJson())),
    "support": support.toJson(),
  };
}

class Support {
  Support({
    required this.url,
    required this.text,
  });

  String url;
  String text;

  factory Support.fromJson(Map<String, dynamic> json) => Support(
    url: json["url"],
    text: json["text"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "text": text,
  };
}
