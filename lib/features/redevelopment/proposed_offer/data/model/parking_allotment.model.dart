import 'package:k3h_erp_app/utils/common_function.dart';

class ParkingAllotmentModel {
  int proposedOfferParkingAllotmentId;
  String uniquekey;
  int buildingId;
  int projectId;
  int numberOfParkingAllottedToMembers;
  double totalParkingPercentageAllottedToSociety;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  ParkingAllotmentModel({
    required this.proposedOfferParkingAllotmentId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.numberOfParkingAllottedToMembers,
    required this.totalParkingPercentageAllottedToSociety,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
  });


  factory ParkingAllotmentModel.fromJson(Map<String, dynamic> json) =>
      ParkingAllotmentModel(
        proposedOfferParkingAllotmentId: parseValue<int>(
          json,
          "ProposedOfferParkingAllotmentId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        numberOfParkingAllottedToMembers: parseValue<int>(
          json,
          "NumberOfParkingAllottedToMembers",
        ),
        totalParkingPercentageAllottedToSociety: parseValue<double>(
          json,
          "TotalParkingPercentageAllottedToSociety",
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
    "ProposedOfferParkingAllotmentId": proposedOfferParkingAllotmentId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "NumberOfParkingAllottedToMembers": numberOfParkingAllottedToMembers,
    "TotalParkingPercentageAllottedToSociety":
    totalParkingPercentageAllottedToSociety,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}