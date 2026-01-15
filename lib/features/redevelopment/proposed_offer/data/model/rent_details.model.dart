import 'package:k3h_erp_app/utils/common_function.dart';

class RentDetailsModel {
  int proposedOfferRentDetailsId;
  String uniquekey;
  int buildingId;
  int projectId;
  bool isAdditionalRent;
  String type;
  String tenure;
  double amount;
  String unitSqFtLumsum;
  double carpetAreaSqFt;
  DateTime rentStartDate;
  DateTime rentEndDate;
  bool isPayBrokerage;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  RentDetailsModel({
    required this.proposedOfferRentDetailsId,
    required this.uniquekey,
    required this.buildingId,
    required this.projectId,
    required this.isAdditionalRent,
    required this.type,
    required this.tenure,
    required this.amount,
    required this.unitSqFtLumsum,
    required this.carpetAreaSqFt,
    required this.rentStartDate,
    required this.rentEndDate,
    required this.isPayBrokerage,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory RentDetailsModel.fromJson(Map<String, dynamic> json) =>
      RentDetailsModel(
        proposedOfferRentDetailsId: parseValue<int>(
          json,
          "ProposedOfferRentDetailsId",
        ),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        isAdditionalRent: parseValue<bool>(json, "IsAdditionalRent"),
        type: parseValue<String>(json, "Type"),
        tenure: parseValue<String>(json, "Tenure"),
        amount: parseValue<double>(json, "Amount"),
        unitSqFtLumsum: parseValue<String>(json, "UnitSqFtLumsum"),
        carpetAreaSqFt: parseValue<double>(json, "CarpetAreaSqFt"),
        rentStartDate: parseValue<DateTime>(json, "RentStartDate"),
        rentEndDate: parseValue<DateTime>(json, "RentEndDate"),
        isPayBrokerage: parseValue<bool>(json, "IsPayBrokerage"),
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
    "ProposedOfferRentDetailsId": proposedOfferRentDetailsId,
    "Uniquekey": uniquekey,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "IsAdditionalRent": isAdditionalRent,
    "Type": type,
    "Tenure": tenure,
    "Amount": amount,
    "UnitSqFtLumsum": unitSqFtLumsum,
    "CarpetAreaSqFt": carpetAreaSqFt,
    "RentStartDate": rentStartDate.toIso8601String(),
    "RentEndDate": rentEndDate.toIso8601String(),
    "IsPayBrokerage": isPayBrokerage,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
