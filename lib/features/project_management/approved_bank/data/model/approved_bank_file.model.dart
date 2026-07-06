import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ApprovedBankFileModel {
  int approvedBankFileId;
  String uniquekey;
  int projectId;
  int approvedBankFolderId;
  int bankListMasterId;
  String bankName;
  String approvedBankFileName;
  String approvedBankFileUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  ApprovedBankFileModel({
    required this.approvedBankFileId,
    required this.uniquekey,
    required this.projectId,
    required this.approvedBankFolderId,
    required this.bankListMasterId,
    required this.bankName,
    required this.approvedBankFileName,
    required this.approvedBankFileUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ApprovedBankFileModel.fromJson(Map<String, dynamic> json) =>
      ApprovedBankFileModel(
        approvedBankFileId: parseValue<int>(json, "ApprovedBankFileId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        approvedBankFolderId: parseValue<int>(json, "ApprovedBankFolderId"),
        bankListMasterId: parseValue<int>(json, "BankListMasterId"),
        bankName: parseValue<String>(json, "BankName"),
        approvedBankFileName: parseValue<String>(json, "ApprovedBankFileName"),
        approvedBankFileUrl: parseValue<String>(json, "ApprovedBankFileURL"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: DateTime.parse(json["CreatedDate"]),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "ApprovedBankFileId": approvedBankFileId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ApprovedBankFolderId": approvedBankFolderId,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "ApprovedBankFileName": approvedBankFileName,
    "ApprovedBankFileURL": approvedBankFileUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}