import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProposedPlanBuilding {
  int proposedOfferProposedPlanId;
  String uniquekey;
  int projectId;
  int totalNumberOfBuilding;
  List<BuildingProposedPlanDataModel> buildingProposedPlanData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ProposedPlanBuilding({
    required this.proposedOfferProposedPlanId,
    required this.uniquekey,
    required this.projectId,
    required this.totalNumberOfBuilding,
    required this.buildingProposedPlanData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ProposedPlanBuilding.fromJson(Map<String, dynamic> json) =>
      ProposedPlanBuilding(
        proposedOfferProposedPlanId: parseValue<int>(
          json,
          "ProposedOfferProposedPlanId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        projectId: parseValue<int>(json, "ProjectId"),
        totalNumberOfBuilding: parseValue<int>(json, "TotalNumberOfBuilding"),
        buildingProposedPlanData:
            (json["BuildingProposedPlanData"] as List<dynamic>?)
                ?.map(
                  (e) => BuildingProposedPlanDataModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
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
    "ProposedOfferProposedPlanId": proposedOfferProposedPlanId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "TotalNumberOfBuilding": totalNumberOfBuilding,
    "BuildingProposedPlanData": buildingProposedPlanData,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class BuildingProposedPlanDataModel {
  int buildingProposedPlanId;
  String uniquekey;
  int proposedOfferProposedPlanId;
  int projectId;
  String buildingName;
  int totalNumberOfWing;
  int totalPodium;
  int totalUnits;
  int totalParking;
  int salesResidentialParking;
  int salesCommercialParking;
  int salesVisitorsParking;
  int memberResidentialParking;
  int memberCommercialParking;
  int memberVisitorsParking;
  String planDocumentURL;
  String threeDViewURL;
  String walkthroughViewURL;
  String salesPlanURL;
  String amenities;
  List<WingProposedPlanDataModel> wingProposedPlanData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BuildingProposedPlanDataModel({
    required this.buildingProposedPlanId,
    required this.uniquekey,
    required this.proposedOfferProposedPlanId,
    required this.projectId,
    required this.buildingName,
    required this.totalNumberOfWing,
    required this.totalPodium,
    required this.totalUnits,
    required this.totalParking,
    required this.salesResidentialParking,
    required this.salesCommercialParking,
    required this.salesVisitorsParking,
    required this.memberResidentialParking,
    required this.memberCommercialParking,
    required this.memberVisitorsParking,
    required this.planDocumentURL,
    required this.threeDViewURL,
    required this.walkthroughViewURL,
    required this.salesPlanURL,
    required this.amenities,
    required this.wingProposedPlanData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BuildingProposedPlanDataModel.fromJson(
    Map<String, dynamic> json,
  ) => BuildingProposedPlanDataModel(
    buildingProposedPlanId: parseValue<int>(json, "BuildingProposedPlanId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    proposedOfferProposedPlanId: parseValue<int>(
      json,
      "ProposedOfferProposedPlanId",
    ),
    projectId: parseValue<int>(json, "ProjectId"),
    buildingName: parseValue<String>(json, "BuildingName"),
    totalNumberOfWing: parseValue<int>(json, "TotalNumberOfWing"),
    totalPodium: parseValue<int>(json, "TotalPodium"),
    totalUnits: parseValue<int>(json, "TotalUnits"),
    totalParking: parseValue<int>(json, "TotalParking"),
    salesResidentialParking: parseValue<int>(json, "SalesResidentialParking"),
    salesCommercialParking: parseValue<int>(json, "SalesCommercialParking"),
    salesVisitorsParking: parseValue<int>(json, "SalesVisitorsParking"),
    memberResidentialParking: parseValue<int>(json, "MemberResidentialParking"),
    memberCommercialParking: parseValue<int>(json, "MemberCommercialParking"),
    memberVisitorsParking: parseValue<int>(json, "MemberVisitorsParking"),
    planDocumentURL: parseValue<String>(json, "PlanDocumentURL"),
    threeDViewURL: parseValue<String>(json, "ThreeDViewURL"),
    walkthroughViewURL: parseValue<String>(json, "WalkthroughViewURL"),
    salesPlanURL: parseValue<String>(json, "SalesPlanURL"),
    amenities: parseValue<String>(json, "Amenities"),
    wingProposedPlanData:
        (json["WingProposedPlanData"] as List<dynamic>?)
            ?.map(
              (e) =>
                  WingProposedPlanDataModel.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
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
    "BuildingProposedPlanId": buildingProposedPlanId,
    "Uniquekey": uniquekey,
    "ProposedOfferProposedPlanId": proposedOfferProposedPlanId,
    "ProjectId": projectId,
    "BuildingName": buildingName,
    "TotalNumberOfWing": totalNumberOfWing,
    "TotalPodium": totalPodium,
    "TotalUnits": totalUnits,
    "TotalParking": totalParking,
    "SalesResidentialParking": salesResidentialParking,
    "SalesCommercialParking": salesCommercialParking,
    "SalesVisitorsParking": salesVisitorsParking,
    "MemberResidentialParking": memberResidentialParking,
    "MemberCommercialParking": memberCommercialParking,
    "MemberVisitorsParking": memberVisitorsParking,
    "PlanDocumentURL": planDocumentURL,
    "ThreeDViewURL": threeDViewURL,
    "WalkthroughViewURL": walkthroughViewURL,
    "SalesPlanURL": salesPlanURL,
    "Amenities": amenities,
    "WingProposedPlanData":
        wingProposedPlanData.map((e) => e.toJson()).toList(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}

class WingProposedPlanDataModel {
  int wingProposedPlanId;
  int proposedOfferProposedPlanId;
  int buildingProposedPlanId;
  String buildingName;
  String wings;
  double mainEntranceLobbyAreaSqFt;
  int totalNumberOfLifts;
  int totalNumberOfUnits;
  int totalNumberOfUnitsForMember;
  int totalNumberOfUnitsForSale;
  double totalNumberOfAreaForMemberSqFt;
  double totalNumberOfAreaForSaleSqFt;

  WingProposedPlanDataModel({
    required this.wingProposedPlanId,
    required this.proposedOfferProposedPlanId,
    required this.buildingProposedPlanId,
    required this.buildingName,
    required this.wings,
    required this.mainEntranceLobbyAreaSqFt,
    required this.totalNumberOfLifts,
    required this.totalNumberOfUnits,
    required this.totalNumberOfUnitsForMember,
    required this.totalNumberOfUnitsForSale,
    required this.totalNumberOfAreaForMemberSqFt,
    required this.totalNumberOfAreaForSaleSqFt,
  });

  factory WingProposedPlanDataModel.fromJson(Map<String, dynamic> json) {
    return WingProposedPlanDataModel(
      wingProposedPlanId: parseValue<int>(json, "WingProposedPlanId"),
      proposedOfferProposedPlanId: parseValue<int>(
        json,
        "ProposedOfferProposedPlanId",
      ),
      buildingProposedPlanId: parseValue<int>(json, "BuildingProposedPlanId"),
      buildingName: parseValue<String>(json, "BuildingName"),
      wings: parseValue<String>(json, "Wings"),
      mainEntranceLobbyAreaSqFt:
          (json["MainEntranceLobbyAreaSqFt"] as num).toDouble(),
      totalNumberOfLifts: parseValue<int>(json, "TotalNumberOfLifts"),
      totalNumberOfUnits: parseValue<int>(json, "TotalNumberOfUnits"),
      totalNumberOfUnitsForMember: parseValue<int>(
        json,
        "TotalNumberOfUnitsForMember",
      ),
      totalNumberOfUnitsForSale: parseValue<int>(
        json,
        "TotalNumberOfUnitsForSale",
      ),
      totalNumberOfAreaForMemberSqFt:
          (json["TotalNumberOfAreaForMemberSqFt"] as num).toDouble(),
      totalNumberOfAreaForSaleSqFt:
          (json["TotalNumberOfAreaForSaleSqFt"] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "WingProposedPlanId": wingProposedPlanId,
    "ProposedOfferProposedPlanId": proposedOfferProposedPlanId,
    "BuildingProposedPlanId": buildingProposedPlanId,
    "BuildingName": buildingName,
    "Wings": wings,
    "MainEntranceLobbyAreaSqFt": mainEntranceLobbyAreaSqFt,
    "TotalNumberOfLifts": totalNumberOfLifts,
    "TotalNumberOfUnits": totalNumberOfUnits,
    "TotalNumberOfUnitsForMember": totalNumberOfUnitsForMember,
    "TotalNumberOfUnitsForSale": totalNumberOfUnitsForSale,
    "TotalNumberOfAreaForMemberSqFt": totalNumberOfAreaForMemberSqFt,
    "TotalNumberOfAreaForSaleSqFt": totalNumberOfAreaForSaleSqFt,
  };
}
