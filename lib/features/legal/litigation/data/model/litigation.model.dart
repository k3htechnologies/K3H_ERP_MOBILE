import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_closure.model.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class LitigationModel {
  int litigationId;
  String uniquekey;
  int projectId;
  String projectName;
  String title;
  String caseNumber;
  String caseType;
  DateTime dateOfFilling;
  String courtName;
  String courtLocation;
  String courtType;
  String status;
  String plantiff;
  String defendant;
  String assignedRepresentative;
  String opposingRepresentative;
  String remark;
  String caseBrief;
  List<LitigationClosureModel> litigationClosureData;
  bool isDelete;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  DateTime? hearingDate;
  DateTime closureDate;

  LitigationModel({
    required this.litigationId,
    required this.uniquekey,
    required this.projectId,
    required this.projectName,
    required this.title,
    required this.caseNumber,
    required this.caseType,
    required this.dateOfFilling,
    required this.courtName,
    required this.courtLocation,
    required this.courtType,
    required this.status,
    required this.plantiff,
    required this.defendant,
    required this.assignedRepresentative,
    required this.opposingRepresentative,
    required this.remark,
    required this.caseBrief,
    required this.litigationClosureData,
    required this.isDelete,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.hearingDate,
    required this.closureDate,
  });

  factory LitigationModel.fromJson(
    Map<String, dynamic> json,
  ) => LitigationModel(
    litigationId: parseValue<int>(json, "LitigationId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    projectName: parseValue<String>(json, "ProjectName"),
    title: parseValue<String>(json, "Title"),
    caseNumber: parseValue<String>(json, "CaseNumber"),
    caseType: parseValue<String>(json, "CaseType"),
    dateOfFilling: parseValue<DateTime>(json, "DateOfFilling"),
    courtName: parseValue<String>(json, "CourtName"),
    courtLocation: parseValue<String>(json, "CourtLocation"),
    courtType: parseValue<String>(json, "CourtType"),
    status: parseValue<String>(json, "Status"),
    plantiff: parseValue<String>(json, "Plantiff"),
    defendant: parseValue<String>(json, "Defendant"),
    assignedRepresentative: parseValue<String>(json, "AssignedRepresentative"),
    opposingRepresentative: parseValue<String>(json, "OpposingRepresentative"),
    remark: parseValue<String>(json, "Remark"),
    caseBrief: parseValue<String>(json, "CaseBrief"),
    litigationClosureData:
        json["LitigationClosureData"] == null
            ? []
            : List<LitigationClosureModel>.from(
              json["LitigationClosureData"].map(
                (x) => LitigationClosureModel.fromJson(x),
              ),
            ),
    isDelete: parseValue<bool>(json, "IsDelete"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
    hearingDate:
        json["HearingDate"] == null
            ? null
            : parseValue<DateTime>(json, "HearingDate"),
    closureDate: parseValue<DateTime>(json, "ClosureDate"),
  );

  Map<String, dynamic> toJson() => {
    "LitigationId": litigationId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ProjectName": projectName,
    "Title": title,
    "CaseNumber": caseNumber,
    "CaseType": caseType,
    "DateOfFilling": dateOfFilling.toIso8601String(),
    "CourtName": courtName,
    "CourtLocation": courtLocation,
    "CourtType": courtType,
    "Status": status,
    "Plantiff": plantiff,
    "Defendant": defendant,
    "AssignedRepresentative": assignedRepresentative,
    "OpposingRepresentative": opposingRepresentative,
    "Remark": remark,
    "CaseBrief": caseBrief,
    "LitigationClosureData": List<dynamic>.from(
      litigationClosureData.map((x) => x.toJson()),
    ),
    "IsDelete": isDelete,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "HearingDate": hearingDate?.toIso8601String(),
    "ClosureDate": closureDate.toIso8601String(),
  };
  LitigationModel copyWith({
    String? status,
    List<LitigationClosureModel>? litigationClosureData,
    DateTime? closureDate,
  }) {
    return LitigationModel(
      litigationId: litigationId,
      uniquekey: uniquekey,
      projectId: projectId,
      projectName: projectName,
      title: title,
      caseNumber: caseNumber,
      caseType: caseType,
      dateOfFilling: dateOfFilling,
      courtName: courtName,
      courtLocation: courtLocation,
      courtType: courtType,
      status: status ?? this.status,
      plantiff: plantiff,
      defendant: defendant,
      assignedRepresentative: assignedRepresentative,
      opposingRepresentative: opposingRepresentative,
      remark: remark,
      caseBrief: caseBrief,
      litigationClosureData:
          litigationClosureData ?? this.litigationClosureData,
      isDelete: isDelete,
      createdById: createdById,
      createdBy: createdBy,
      createdDate: createdDate,
      modifiedById: modifiedById,
      modifiedBy: modifiedBy,
      modifiedDate: modifiedDate,
      hearingDate: hearingDate,
      closureDate: closureDate ?? this.closureDate,
    );
  }
}
