import 'package:k3h_erp_app/utils/functions/common_function.dart';

import 'buiilding_key_contact_details.model.dart';

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
