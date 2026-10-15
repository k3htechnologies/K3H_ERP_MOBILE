import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TermsAndConditionsModel {
  int termsAndConditionsMasterId;
  String uniquekey;
  String moduleName;
  String title;
  String description;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TermsAndConditionsModel({
    required this.termsAndConditionsMasterId,
    required this.uniquekey,
    required this.moduleName,
    required this.title,
    required this.description,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TermsAndConditionsModel.fromJson(Map<String, dynamic> json) =>
      TermsAndConditionsModel(
        termsAndConditionsMasterId: parseValue<int>(
          json,
          "TermsAndConditionsMasterId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        moduleName: parseValue<String>(json, "ModuleName"),
        title: parseValue<String>(json, "Title"),
        description: parseValue<String>(json, "Description"),
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
    "TermsAndConditionsMasterId": termsAndConditionsMasterId,
    "Uniquekey": uniquekey,
    "ModuleName": moduleName,
    "Title": title,
    "Description": description,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}