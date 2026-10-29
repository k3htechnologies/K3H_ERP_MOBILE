import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ConstructionAreaComparativeModel {
  int constructionAreaComparativeId;
  String uniqueKey;
  int projectId;
  String type;
  double areaByPlLineSqMt;
  double variationInPercentage;
  String remark;
  String annexureUrl;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ConstructionAreaComparativeModel({
    required this.constructionAreaComparativeId,
    required this.uniqueKey,
    required this.projectId,
    required this.type,
    required this.areaByPlLineSqMt,
    required this.variationInPercentage,
    required this.remark,
    required this.annexureUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ConstructionAreaComparativeModel.fromJson(
    Map<String, dynamic> json,
  ) => ConstructionAreaComparativeModel(
    constructionAreaComparativeId: parseValue<int>(
      json,
      "ConstructionAreaComparativeId",
    ),
    uniqueKey: parseValue<String>(json, "UniqueKey"),
    projectId: parseValue<int>(json, "ProjectId"),
    type: parseValue<String>(json, "Type"),
    areaByPlLineSqMt: parseValue<double>(json, "AreaByPLLineSqMt"),
    variationInPercentage: parseValue<double>(json, "VariationInPercentage"),
    remark: parseValue<String>(json, "Remark"),
    annexureUrl: parseValue<String>(json, "AnnexureURL"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : DateTime.parse(json["ModifiedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "ConstructionAreaComparativeId": constructionAreaComparativeId,
    "UniqueKey": uniqueKey,
    "ProjectId": projectId,
    "Type": type,
    "AreaByPLLineSqMt": areaByPlLineSqMt,
    "VariationInPercentage": variationInPercentage,
    "Remark": remark,
    "AnnexureURL": annexureUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
