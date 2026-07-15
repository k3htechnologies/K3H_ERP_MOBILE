import 'package:k3h_erp_app/utils/functions/common_function.dart';

class DcrModel {
  int projectId;
  String projectName;
  double target;
  int ftd;
  double newBooking;
  double ftm;
  int regTarget;
  int regDoneFtd;
  int regDoneMtd;
  double balanceAgainstTarget;

  DcrModel({
    required this.projectId,
    required this.projectName,
    required this.target,
    required this.ftd,
    required this.newBooking,
    required this.ftm,
    required this.regTarget,
    required this.regDoneFtd,
    required this.regDoneMtd,
    required this.balanceAgainstTarget,
  });

  factory DcrModel.fromJson(Map<String, dynamic> json) => DcrModel(
    projectId: parseValue<int>(json, "ProjectId"),
    projectName: parseValue<String>(json, "ProjectName"),
    target: parseValue<double>(json, "Target"),
    ftd: parseValue<int>(json, "FTD"),
    newBooking: parseValue<double>(json, "NewBooking"),
    ftm: parseValue<double>(json, "FTM"),
    regTarget: parseValue<int>(json, "RegTarget"),
    regDoneFtd: parseValue<int>(json, "RegDoneFTD"),
    regDoneMtd: parseValue<int>(json, "RegDoneMTD"),
    balanceAgainstTarget: parseValue<double>(json, "BalanceAgainstTarget"),
  );

  Map<String, dynamic> toJson() => {
    "ProjectId": projectId,
    "ProjectName": projectName,
    "Target": target,
    "FTD": ftd,
    "NewBooking": newBooking,
    "FTM": ftm,
    "RegTarget": regTarget,
    "RegDoneFTD": regDoneFtd,
    "RegDoneMTD": regDoneMtd,
    "BalanceAgainstTarget": balanceAgainstTarget,
  };
}
