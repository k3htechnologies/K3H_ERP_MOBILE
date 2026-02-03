// To parse this JSON data, do
//
//     final bankListMasterModel = bankListMasterModelFromJson(jsonString);

import 'dart:convert';

import 'package:k3h_erp_app/utils/common_function.dart';

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
    bankListMasterId: parseValue<int>(json,"BankListMasterId"),
    bankNameWithCode: parseValue<String>(json,"BankNameWithCode"),
  );

  Map<String, dynamic> toJson() => {
    "BankListMasterId": bankListMasterId,
    "BankNameWithCode": bankNameWithCode,
  };
}
