import 'package:k3h_erp_app/utils/common_function.dart';

class RedevelopmentBuildingModel {
  int buildingId;
  String uniquekey;
  int projectId;
  String buildingName;
  String ctsNumber;
  double totalPlotAreaSqFt;
  String roadWidth;
  int countryMasterId;
  String countryName;
  int districtMasterId;
  String districtName;
  int stateMasterId;
  String stateName;
  int cityMasterId;
  String cityName;
  int villageMasterId;
  String villageName;
  int totalNumberOfUnits;
  double totalUnitsAreaUtilizedSqFt;
  bool isGarden;
  double totalGardenAreaSqFt;
  bool isReligiousStructure;
  double totalReligiousStructureAreaSqFt;
  int propertyAgeYears;
  int numberOfFloors;
  double fsiTdrUtilizationSqFt;
  String landOwnershipType;
  bool isLitigation;
  String litigationRemarks;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  RedevelopmentBuildingModel({
    required this.buildingId,
    required this.uniquekey,
    required this.projectId,
    required this.buildingName,
    required this.ctsNumber,
    required this.totalPlotAreaSqFt,
    required this.roadWidth,
    required this.countryMasterId,
    required this.countryName,
    required this.districtMasterId,
    required this.districtName,
    required this.stateMasterId,
    required this.stateName,
    required this.cityMasterId,
    required this.cityName,
    required this.villageMasterId,
    required this.villageName,
    required this.totalNumberOfUnits,
    required this.totalUnitsAreaUtilizedSqFt,
    required this.isGarden,
    required this.totalGardenAreaSqFt,
    required this.isReligiousStructure,
    required this.totalReligiousStructureAreaSqFt,
    required this.propertyAgeYears,
    required this.numberOfFloors,
    required this.fsiTdrUtilizationSqFt,
    required this.landOwnershipType,
    required this.isLitigation,
    required this.litigationRemarks,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory RedevelopmentBuildingModel.fromJson(Map<String, dynamic> json) => RedevelopmentBuildingModel(
    buildingId: parseValue<int>(json, "BuildingId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    buildingName: parseValue<String>(json, "BuildingName"),
    ctsNumber: parseValue<String>(json, "CTSNumber"),
    totalPlotAreaSqFt: parseValue<double>(json, "TotalPlotAreaSqFt"),
    roadWidth: parseValue<String>(json, "RoadWidth"),
    countryMasterId: parseValue<int>(json, "CountryMasterId"),
    countryName: parseValue<String>(json, "CountryName"),
    districtMasterId: parseValue<int>(json, "DistrictMasterId"),
    districtName: parseValue<String>(json, "DistrictName"),
    stateMasterId: parseValue<int>(json, "StateMasterId"),
    stateName: parseValue<String>(json, "StateName"),
    cityMasterId: parseValue<int>(json, "CityMasterId"),
    cityName: parseValue<String>(json, "CityName"),
    villageMasterId: parseValue<int>(json, "VillageMasterId"),
    villageName: parseValue<String>(json, "VillageName"),
    totalNumberOfUnits: parseValue<int>(json, "TotalNumberOfUnits"),
    totalUnitsAreaUtilizedSqFt: parseValue<double>(
      json,
      "TotalUnitsAreaUtilizedSqFt",
    ),
    isGarden: parseValue<bool>(json, "IsGarden"),
    totalGardenAreaSqFt: parseValue<double>(json, "TotalGardenAreaSqFt"),
    isReligiousStructure: parseValue<bool>(json, "IsReligiousStructure"),
    totalReligiousStructureAreaSqFt: parseValue<double>(
      json,
      "TotalReligiousStructureAreaSqFt",
    ),
    propertyAgeYears: parseValue<int>(json, "PropertyAgeYears"),
    numberOfFloors: parseValue<int>(json, "NumberOfFloors"),
    fsiTdrUtilizationSqFt: parseValue<double>(json, "FSI_TDR_UtilizationSqFt"),
    landOwnershipType: parseValue<String>(json, "LandOwnershipType"),
    isLitigation: parseValue<bool>(json, "IsLitigation"),
    litigationRemarks: parseValue<String>(json, "LitigationRemarks"),
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
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "BuildingName": buildingName,
    "CTSNumber": ctsNumber,
    "TotalPlotAreaSqFt": totalPlotAreaSqFt,
    "RoadWidth": roadWidth,
    "CountryMasterId": countryMasterId,
    "CountryName": countryName,
    "DistrictMasterId": districtMasterId,
    "DistrictName": districtName,
    "StateMasterId": stateMasterId,
    "StateName": stateName,
    "CityMasterId": cityMasterId,
    "CityName": cityName,
    "VillageMasterId": villageMasterId,
    "VillageName": villageName,
    "TotalNumberOfUnits": totalNumberOfUnits,
    "TotalUnitsAreaUtilizedSqFt": totalUnitsAreaUtilizedSqFt,
    "IsGarden": isGarden,
    "TotalGardenAreaSqFt": totalGardenAreaSqFt,
    "IsReligiousStructure": isReligiousStructure,
    "TotalReligiousStructureAreaSqFt": totalReligiousStructureAreaSqFt,
    "PropertyAgeYears": propertyAgeYears,
    "NumberOfFloors": numberOfFloors,
    "FSI_TDR_UtilizationSqFt": fsiTdrUtilizationSqFt,
    "LandOwnershipType": landOwnershipType,
    "IsLitigation": isLitigation,
    "LitigationRemarks": litigationRemarks,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}