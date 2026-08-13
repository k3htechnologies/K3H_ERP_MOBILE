import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BuildingDetailsModel {
  int buildingId;
  int projectId;
  double grossPlotAreaSqFt;
  double plotAreaPhysicalSurveySqFt;
  double plotAreaOldApprovedPlanSqFt;
  double plotAreaConveyanceSqFt;
  double plotAreaPRCardSqFt;
  double totalCarpetAreaSqFt;
  int totalResidentialUnits;
  double totalResidentialCarpetAreaSqFt;
  double garageCarpetAreaSqFt;
  double terraceCarpetAreaSqFt;
  int totalCommercialUnits;
  double totalCommercialCarpetAreaSqFt;
  List<BuildingKeyContactDetailsModel> buildingKeyContactDetailsData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BuildingDetailsModel({
    required this.buildingId,
    required this.projectId,
    required this.grossPlotAreaSqFt,
    required this.plotAreaPhysicalSurveySqFt,
    required this.plotAreaOldApprovedPlanSqFt,
    required this.plotAreaConveyanceSqFt,
    required this.plotAreaPRCardSqFt,
    required this.totalCarpetAreaSqFt,
    required this.totalResidentialUnits,
    required this.totalResidentialCarpetAreaSqFt,
    required this.totalCommercialUnits,
    required this.totalCommercialCarpetAreaSqFt,
    required this.garageCarpetAreaSqFt,
    required this.terraceCarpetAreaSqFt,
    required this.buildingKeyContactDetailsData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BuildingDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => BuildingDetailsModel(
    buildingId: parseValue<int>(json, "BuildingId"),
    projectId: parseValue<int>(json, "ProjectId"),
    grossPlotAreaSqFt: parseValue<double>(json, "GrossPlotAreaSqFt"),
    plotAreaPhysicalSurveySqFt: parseValue<double>(
      json,
      "PlotAreaPhysicalSurveySqFt",
    ),
    plotAreaOldApprovedPlanSqFt: parseValue<double>(
      json,
      "PlotAreaOldApprovedPlanSqFt",
    ),
    plotAreaConveyanceSqFt: parseValue<double>(json, "PlotAreaConveyanceSqFt"),
    plotAreaPRCardSqFt: parseValue<double>(json, "PlotAreaPRCardSqFt"),
    totalCarpetAreaSqFt: parseValue<double>(json, "TotalCarpetAreaSqFt"),
    totalResidentialUnits: parseValue<int>(json, "TotalResidentialUnits"),
    totalResidentialCarpetAreaSqFt: parseValue<double>(
      json,
      "TotalResidentialCarpetAreaSqFt",
    ),
    totalCommercialUnits: parseValue<int>(json, "TotalCommercialUnits"),
    totalCommercialCarpetAreaSqFt: parseValue<double>(
      json,
      "TotalCommercialCarpetAreaSqFt",
    ),
    garageCarpetAreaSqFt: parseValue<double>(json, "TotalGarageCarpetAreaSqFt"),
    terraceCarpetAreaSqFt: parseValue<double>(
      json,
      "TotalTerraceCarpetAreaSqFt",
    ),
    buildingKeyContactDetailsData: List<BuildingKeyContactDetailsModel>.from(
      (json["BuildingKeyContactDetailsData"] as List<dynamic>? ?? []).map(
        (x) => BuildingKeyContactDetailsModel.fromJson(x),
      ),
    ),
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

  Map<String, dynamic> toJson() => {
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "GrossPlotAreaSqFt": grossPlotAreaSqFt,
    "PlotAreaPhysicalSurveySqFt": plotAreaPhysicalSurveySqFt,
    "PlotAreaOldApprovedPlanSqFt": plotAreaOldApprovedPlanSqFt,
    "PlotAreaConveyanceSqFt": plotAreaConveyanceSqFt,
    "PlotAreaPRCardSqFt": plotAreaPRCardSqFt,
    "TotalCarpetAreaSqFt": totalCarpetAreaSqFt,
    "TotalResidentialUnits": totalResidentialUnits,
    "TotalResidentialCarpetAreaSqFt": totalResidentialCarpetAreaSqFt,
    "TotalCommercialUnits": totalCommercialUnits,
    "TotalCommercialCarpetAreaSqFt": totalCommercialCarpetAreaSqFt,
    "TotalGarageCarpetAreaSqFt": garageCarpetAreaSqFt,
    "TotalTerraceCarpetAreaSqFt": terraceCarpetAreaSqFt,
    "BuildingKeyContactDetailsData":
        buildingKeyContactDetailsData.map((x) => x.toJson()).toList(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class BuildingKeyContactDetailsModel {
  int buildingKeyContactDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  String contactType;
  String contactName;
  String mobileNumber;
  String emailId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BuildingKeyContactDetailsModel({
    required this.buildingKeyContactDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.contactType,
    required this.contactName,
    required this.mobileNumber,
    required this.emailId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BuildingKeyContactDetailsModel.fromJson(Map<String, dynamic> json) =>
      BuildingKeyContactDetailsModel(
        buildingKeyContactDetailsId: parseValue<int>(
          json,
          "BuildingKeyContactDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        contactType: parseValue<String>(json, "ContactType"),
        contactName: parseValue<String>(json, "ContactName"),
        mobileNumber: parseValue<String>(json, "MobileNumber"),
        emailId: parseValue<String>(json, "EmailId"),
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

  Map<String, dynamic> toJson() => {
    "BuildingKeyContactDetailsId": buildingKeyContactDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "ContactType": contactType,
    "ContactName": contactName,
    "MobileNumber": mobileNumber,
    "EmailId": emailId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
