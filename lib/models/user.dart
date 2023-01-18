// To parse this JSON data, do
//
//     final userInfo = userInfoFromJson(jsonString);

import 'dart:convert';

UserInfo userInfoFromJson(String str) => UserInfo.fromJson(json.decode(str));

String userInfoToJson(UserInfo data) => json.encode(data.toJson());

class UserInfo {
  UserInfo({
    this.name,
    this.tel,
    this.mcode,
    this.card,
    this.email,
  });

  String name;
  String tel;
  String mcode;
  String card;
  String email;

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    name: json["name"],
    tel: json["tel"],
    mcode: json["mcode"],
    card: json["card"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "tel": tel,
    "mcode": mcode,
    "card": card,
    "email": email,
  };
}
