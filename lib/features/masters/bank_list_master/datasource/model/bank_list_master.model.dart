// To parse this JSON data, do
//
//     final bankListMasterModel = bankListMasterModelFromJson(jsonString);

import 'dart:convert';

BankListMasterModel bankListMasterModelFromJson(String str) => BankListMasterModel.fromJson(json.decode(str));

String bankListMasterModelToJson(BankListMasterModel data) => json.encode(data.toJson());

class BankListMasterModel {
  int bankListMasterId;
  String bankNameWithCode;

  BankListMasterModel({
    required this.bankListMasterId,
    required this.bankNameWithCode,
  });

  factory BankListMasterModel.fromJson(Map<String, dynamic> json) => BankListMasterModel(
    bankListMasterId: json["BankListMasterId"],
    bankNameWithCode: json["BankNameWithCode"],
  );

  Map<String, dynamic> toJson() => {
    "BankListMasterId": bankListMasterId,
    "BankNameWithCode": bankNameWithCode,
  };
}
