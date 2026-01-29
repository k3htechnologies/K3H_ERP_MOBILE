import 'package:k3h_erp_app/utils/common_function.dart';

class ResignationModel {
  int employeeResignationId;
  String uniqueKey;
  int employeeId;
  String employeeName;
  DateTime resignationDate;
  String reasonOfLeaving;
  DateTime expectedRelievingDate;
  bool isAnyOfferInHand;
  String offerLetterUrl;
  int offerAmount;
  String approvalStatus;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ResignationModel({
    required this.employeeResignationId,
    required this.uniqueKey,
    required this.employeeId,
    required this.employeeName,
    required this.resignationDate,
    required this.reasonOfLeaving,
    required this.expectedRelievingDate,
    required this.isAnyOfferInHand,
    required this.offerLetterUrl,
    required this.offerAmount,
    required this.approvalStatus,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ResignationModel.fromJson(Map<String, dynamic> json) =>
      ResignationModel(
        employeeResignationId: parseValue<int>(json, "EmployeeResignationId"),
        uniqueKey: parseValue<String>(json, "UniqueKey"),

        employeeId: parseValue<int>(json, "EmployeeId"),

        employeeName: parseValue<String>(json, "EmployeeName"),
        resignationDate: parseValue<DateTime>(json, "ResignationDate"),
        reasonOfLeaving: parseValue<String>(json, "ReasonOfLeaving"),
        expectedRelievingDate: parseValue<DateTime>(
          json,
          "ExpectedRelievingDate",
        ),
        isAnyOfferInHand: parseValue<bool>(json, "IsAnyOfferInHand"),
        offerLetterUrl: parseValue<String>(json, "OfferLetterUrl"),
        offerAmount: parseValue<int>(json, "OfferAmount"),
        approvalStatus: parseValue<String>(json, "ApprovalStatus"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() {
    return {
      "EmployeeResignationId": employeeResignationId,
      "UniqueKey": uniqueKey,
      "EmployeeId": employeeId,
      "EmployeeName": employeeName,
      "ResignationDate": resignationDate.toIso8601String(),
      "ReasonOfLeaving": reasonOfLeaving,
      "ExpectedRelievingDate": expectedRelievingDate.toIso8601String(),
      "IsAnyOfferInHand": isAnyOfferInHand,
      "OfferLetterUrl": offerLetterUrl,
      "OfferAmount": offerAmount,
      "ApprovalStatus": approvalStatus,
      "CreatedById": createdById,
      "CreatedBy": createdBy,
      "CreatedDate": createdDate.toIso8601String(),
      "ModifiedById": modifiedById,
      "ModifiedBy": modifiedBy,
      "ModifiedDate": modifiedDate?.toIso8601String(),
    };
  }
}
