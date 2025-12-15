import 'package:k3h_erp_app/utils/common_function.dart';

class ApprovedBankFolderModel {
  int approvedBankFolderId;
  String uniquekey;
  int projectId;
  int bankListMasterId;
  String bankName;
  int numberOfApprovedBankFile;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  ApprovedBankFolderModel({
    required this.approvedBankFolderId,
    required this.uniquekey,
    required this.projectId,
    required this.bankListMasterId,
    required this.bankName,
    required this.numberOfApprovedBankFile,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ApprovedBankFolderModel.fromJson(Map<String, dynamic> json) =>
      ApprovedBankFolderModel(
        approvedBankFolderId: parseValue<int>(json, "ApprovedBankFolderId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        bankListMasterId: parseValue<int>(json, "BankListMasterId"),
        bankName: parseValue<String>(json, "BankName"),
        numberOfApprovedBankFile: parseValue<int>(
          json,
          "NumberOfApprovedBankFile",
        ),
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
    "ApprovedBankFolderId": approvedBankFolderId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "NumberOfApprovedBankFile": numberOfApprovedBankFile,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
