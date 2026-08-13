import 'package:k3h_erp_app/utils/functions/common_function.dart';

class CollectionReportProjectWiseModel {
  int projectId;
  String projectName;
  String type;
  int totalUnit;
  double totalUnitReraCarpetAreaSqFt;
  int registrationCompleted;
  int registrationPending;
  int bookingCount;
  double totalReraCarpetAreaSqFt;
  double totalAgreementValue;
  double dueAmount;
  double receivedAmount;
  double outstandingAmount;
  double balanceAmount;

  CollectionReportProjectWiseModel({
    required this.projectId,
    required this.projectName,
    required this.type,
    required this.totalUnit,
    required this.totalUnitReraCarpetAreaSqFt,
    required this.registrationCompleted,
    required this.registrationPending,
    required this.bookingCount,
    required this.totalReraCarpetAreaSqFt,
    required this.totalAgreementValue,
    required this.dueAmount,
    required this.receivedAmount,
    required this.outstandingAmount,
    required this.balanceAmount,
  });

  factory CollectionReportProjectWiseModel.fromJson(
    Map<String, dynamic> json,
  ) => CollectionReportProjectWiseModel(
    projectId: parseValue<int>(json, "ProjectId"),
    projectName: parseValue<String>(json, "ProjectName"),
    type: parseValue<String>(json, "Type"),
    totalUnit: parseValue<int>(json, "TotalUnit"),
    totalUnitReraCarpetAreaSqFt: parseValue<double>(
      json,
      "TotalUnitRERACarpetAreaSqFt",
    ),
    registrationCompleted: parseValue<int>(json, "RegistrationCompleted"),
    registrationPending: parseValue<int>(json, "RegistrationPending"),
    bookingCount: parseValue<int>(json, "BookingCount"),
    totalReraCarpetAreaSqFt: parseValue<double>(
      json,
      "TotalRERACarpetAreaSqFt",
    ),
    totalAgreementValue: parseValue<double>(json, "TotalAgreementValue"),
    dueAmount: parseValue<double>(json, "DueAmount"),
    receivedAmount: parseValue<double>(json, "ReceivedAmount"),
    outstandingAmount: parseValue<double>(json, "OutstandingAmount"),
    balanceAmount: parseValue<double>(json, "BalanceAmount"),
  );

  Map<String, dynamic> toJson() => {
    "ProjectId": projectId,
    "ProjectName": projectName,
    "Type": type,
    "TotalUnit": totalUnit,
    "TotalUnitRERACarpetAreaSqFt": totalUnitReraCarpetAreaSqFt,
    "RegistrationCompleted": registrationCompleted,
    "RegistrationPending": registrationPending,
    "BookingCount": bookingCount,
    "TotalRERACarpetAreaSqFt": totalReraCarpetAreaSqFt,
    "TotalAgreementValue": totalAgreementValue,
    "DueAmount": dueAmount,
    "ReceivedAmount": receivedAmount,
    "OutstandingAmount": outstandingAmount,
    "BalanceAmount": balanceAmount,
  };
}
