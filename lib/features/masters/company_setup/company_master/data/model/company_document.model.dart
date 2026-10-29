import 'package:k3h_erp_app/utils/functions/common_function.dart';

class CompanyDocumentModel {
  int companyDocumentId;
  String uniquekey;
  int companyId;
  String financialYear;
  String documentName;
  String documentURL;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  CompanyDocumentModel({
    required this.companyDocumentId,
    required this.uniquekey,
    required this.companyId,
    required this.financialYear,
    required this.documentName,
    required this.documentURL,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory CompanyDocumentModel.fromJson(Map<String, dynamic> json) =>
      CompanyDocumentModel(
        companyDocumentId: parseValue<int>(json, "CompanyDocumentId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        companyId: parseValue<int>(json, "CompanyId"),
        financialYear: parseValue<String>(json, "FinancialYear"),
        documentName: parseValue<String>(json, "DocumentName"),
        documentURL: parseValue<String>(json, "DocumentURL"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate:
            json["CreatedDate"] == null
                ? null
                : parseValue<DateTime>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate:
            json["ModifiedDate"] == null
                ? null
                : parseValue<DateTime>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "CompanyDocumentId": companyDocumentId,
    "Uniquekey": uniquekey,
    "CompanyId": companyId,
    "FinancialYear": financialYear,
    "DocumentName": documentName,
    "DocumentURL": documentURL,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
