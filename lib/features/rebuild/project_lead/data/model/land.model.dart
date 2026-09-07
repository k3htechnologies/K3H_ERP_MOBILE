import 'package:k3h_erp_app/utils/functions/common_function.dart';

class LandModel {
  int projectLandId;
  String uniquekey;
  String landOwnerName;
  String landAddress;
  String countryName;
  int countryMasterId;
  String stateName;
  int stateMasterId;
  String districtName;
  int districtMasterId;
  String cityName;
  int cityMasterId;
  String pinCode;
  String plotNumberCtsNumberSurveyNumberSubdivisionNumber;
  String wardNumberZone;
  double totalPlotAreaSqM;
  String identificationLocation;
  String latitudeLongitude;
  String contactPersonName;
  String contactPersonMobile;
  String contactPersonEmail;
  String plotShape;
  int frontage;
  double plotDepth;
  String roadWidth;
  String soilType;
  String existingGroundCondition;
  bool isAnyPowerofAttorneyInvolved;
  bool isFencingBoundaryWallPresent;
  bool isLandConvertedToNonAgricultural;
  bool isAccessRoadAvailable;
  bool isElectricityConnectionNearby;
  bool isUnderLitigationOrStayOrder;
  bool is712Available;
  String anyPowerofAttorneyInvolved;
  String fencingBoundaryWallPresent;
  String landConvertedToNonAgricultural;
  String accessRoadAvailable;
  String electricityConnectionNearby;
  String underLitigationOrStayOrder;
  String available712;
  int fsiPermissible;
  String waterSupplyAvailable;
  String surroundingLandUse;
  String typeOfLandTenureType;
  String landOwnershipType;
  double distanceFromNearestTownKm;
  int distanceFromHighwayKm;
  int distanceFromRailwayStationKm;
  int distanceFromAirportKm;
  int totalNumberOfTreesonSite;
  String photoUrl;
  String remark;
  int clientRegistrationId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  LandModel({
    required this.projectLandId,
    required this.uniquekey,
    required this.landOwnerName,
    required this.landAddress,
    required this.countryName,
    required this.countryMasterId,
    required this.stateName,
    required this.stateMasterId,
    required this.districtName,
    required this.districtMasterId,
    required this.cityName,
    required this.cityMasterId,
    required this.pinCode,
    required this.plotNumberCtsNumberSurveyNumberSubdivisionNumber,
    required this.wardNumberZone,
    required this.totalPlotAreaSqM,
    required this.identificationLocation,
    required this.latitudeLongitude,
    required this.contactPersonName,
    required this.contactPersonMobile,
    required this.contactPersonEmail,
    required this.plotShape,
    required this.frontage,
    required this.plotDepth,
    required this.roadWidth,
    required this.soilType,
    required this.existingGroundCondition,
    required this.isAnyPowerofAttorneyInvolved,
    required this.isFencingBoundaryWallPresent,
    required this.isLandConvertedToNonAgricultural,
    required this.isAccessRoadAvailable,
    required this.isElectricityConnectionNearby,
    required this.isUnderLitigationOrStayOrder,
    required this.is712Available,
    required this.anyPowerofAttorneyInvolved,
    required this.fencingBoundaryWallPresent,
    required this.landConvertedToNonAgricultural,
    required this.accessRoadAvailable,
    required this.electricityConnectionNearby,
    required this.underLitigationOrStayOrder,
    required this.available712,
    required this.fsiPermissible,
    required this.waterSupplyAvailable,
    required this.surroundingLandUse,
    required this.typeOfLandTenureType,
    required this.landOwnershipType,
    required this.distanceFromNearestTownKm,
    required this.distanceFromHighwayKm,
    required this.distanceFromRailwayStationKm,
    required this.distanceFromAirportKm,
    required this.totalNumberOfTreesonSite,
    required this.photoUrl,
    required this.remark,
    required this.clientRegistrationId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory LandModel.fromJson(Map<String, dynamic> json) => LandModel(
    projectLandId: parseValue<int>(json, "ProjectLandId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    landOwnerName: parseValue<String>(json, "LandOwnerName"),
    landAddress: parseValue<String>(json, "LandAddress"),
    countryName: parseValue<String>(json, "CountryName"),
    countryMasterId: parseValue<int>(json, "CountryMasterId"),
    stateName: parseValue<String>(json, "StateName"),
    stateMasterId: parseValue<int>(json, "StateMasterId"),
    districtName: parseValue<String>(json, "DistrictName"),
    districtMasterId: parseValue<int>(json, "DistrictMasterId"),
    cityName: parseValue<String>(json, "CityName"),
    cityMasterId: parseValue<int>(json, "CityMasterId"),
    pinCode: parseValue<String>(json, "PinCode"),
    plotNumberCtsNumberSurveyNumberSubdivisionNumber: parseValue<String>(
      json,
      "PlotNumber_CTSNumber_SurveyNumber_SubdivisionNumber",
    ),
    wardNumberZone: parseValue<String>(json, "WardNumberZone"),
    totalPlotAreaSqM: parseValue<double>(json, "TotalPlotAreaSqM"),
    identificationLocation: parseValue<String>(json, "IdentificationLocation"),
    latitudeLongitude: parseValue<String>(json, "LatitudeLongitude"),
    contactPersonName: parseValue<String>(json, "ContactPersonName"),
    contactPersonMobile: parseValue<String>(json, "ContactPersonMobile"),
    contactPersonEmail: parseValue<String>(json, "ContactPersonEmail"),
    plotShape: parseValue<String>(json, "PlotShape"),
    frontage: parseValue<int>(json, "Frontage"),
    plotDepth: parseValue<double>(json, "PlotDepth"),
    roadWidth: parseValue<String>(json, "RoadWidth"),
    soilType: parseValue<String>(json, "SoilType"),
    existingGroundCondition: parseValue<String>(
      json,
      "ExistingGroundCondition",
    ),
    isAnyPowerofAttorneyInvolved: parseValue<bool>(
      json,
      "IsAnyPowerofAttorneyInvolved",
    ),
    isFencingBoundaryWallPresent: parseValue<bool>(
      json,
      "IsFencingBoundaryWallPresent",
    ),
    isLandConvertedToNonAgricultural: parseValue<bool>(
      json,
      "IsLandConvertedToNonAgricultural",
    ),
    isAccessRoadAvailable: parseValue<bool>(json, "IsAccessRoadAvailable"),
    isElectricityConnectionNearby: parseValue<bool>(
      json,
      "IsElectricityConnectionNearby",
    ),
    isUnderLitigationOrStayOrder: parseValue<bool>(
      json,
      "IsUnderLitigationOrStayOrder",
    ),
    is712Available: parseValue<bool>(json, "Is712Available"),
    anyPowerofAttorneyInvolved: parseValue<String>(
      json,
      "AnyPowerofAttorneyInvolved",
    ),
    fencingBoundaryWallPresent: parseValue<String>(
      json,
      "FencingBoundaryWallPresent",
    ),
    landConvertedToNonAgricultural: parseValue<String>(
      json,
      "LandConvertedToNonAgricultural",
    ),
    accessRoadAvailable: parseValue<String>(json, "AccessRoadAvailable"),
    electricityConnectionNearby: parseValue<String>(
      json,
      "ElectricityConnectionNearby",
    ),
    underLitigationOrStayOrder: parseValue<String>(
      json,
      "UnderLitigationOrStayOrder",
    ),
    available712: parseValue<String>(json, "Available712"),
    fsiPermissible: parseValue<int>(json, "FSIPermissible"),
    waterSupplyAvailable: parseValue<String>(json, "WaterSupplyAvailable"),
    surroundingLandUse: parseValue<String>(json, "SurroundingLandUse"),
    typeOfLandTenureType: parseValue<String>(json, "TypeOfLandTenureType"),
    landOwnershipType: parseValue<String>(json, "LandOwnershipType"),
    distanceFromNearestTownKm: parseValue<double>(
      json,
      "DistanceFromNearestTownKM",
    ),
    distanceFromHighwayKm: parseValue<int>(json, "DistanceFromHighwayKM"),
    distanceFromRailwayStationKm: parseValue<int>(
      json,
      "DistanceFromRailwayStationKM",
    ),
    distanceFromAirportKm: parseValue<int>(json, "DistanceFromAirportKM"),
    totalNumberOfTreesonSite: parseValue<int>(json, "TotalNumberOfTreesonSite"),
    photoUrl: parseValue<String>(json, "PhotoURL"),
    remark: parseValue<String>(json, "Remark"),
    clientRegistrationId: parseValue<int>(json, "ClientRegistrationId"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: DateTime.parse(json["CreatedDate"]),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : DateTime.parse(json["ModifiedDate"]),
  );

  Map<String, dynamic> toJson() => {
    "ProjectLandId": projectLandId,
    "Uniquekey": uniquekey,
    "LandOwnerName": landOwnerName,
    "LandAddress": landAddress,
    "CountryName": countryName,
    "CountryMasterId": countryMasterId,
    "StateName": stateName,
    "StateMasterId": stateMasterId,
    "DistrictName": districtName,
    "DistrictMasterId": districtMasterId,
    "CityName": cityName,
    "CityMasterId": cityMasterId,
    "PinCode": pinCode,
    "PlotNumber_CTSNumber_SurveyNumber_SubdivisionNumber":
        plotNumberCtsNumberSurveyNumberSubdivisionNumber,
    "WardNumberZone": wardNumberZone,
    "TotalPlotAreaSqM": totalPlotAreaSqM,
    "IdentificationLocation": identificationLocation,
    "LatitudeLongitude": latitudeLongitude,
    "ContactPersonName": contactPersonName,
    "ContactPersonMobile": contactPersonMobile,
    "ContactPersonEmail": contactPersonEmail,
    "PlotShape": plotShape,
    "Frontage": frontage,
    "PlotDepth": plotDepth,
    "RoadWidth": roadWidth,
    "SoilType": soilType,
    "ExistingGroundCondition": existingGroundCondition,
    "IsAnyPowerofAttorneyInvolved": isAnyPowerofAttorneyInvolved,
    "IsFencingBoundaryWallPresent": isFencingBoundaryWallPresent,
    "IsLandConvertedToNonAgricultural": isLandConvertedToNonAgricultural,
    "IsAccessRoadAvailable": isAccessRoadAvailable,
    "IsElectricityConnectionNearby": isElectricityConnectionNearby,
    "IsUnderLitigationOrStayOrder": isUnderLitigationOrStayOrder,
    "Is712Available": is712Available,
    "AnyPowerofAttorneyInvolved": anyPowerofAttorneyInvolved,
    "FencingBoundaryWallPresent": fencingBoundaryWallPresent,
    "LandConvertedToNonAgricultural": landConvertedToNonAgricultural,
    "AccessRoadAvailable": accessRoadAvailable,
    "ElectricityConnectionNearby": electricityConnectionNearby,
    "UnderLitigationOrStayOrder": underLitigationOrStayOrder,
    "Available712": available712,
    "FSIPermissible": fsiPermissible,
    "WaterSupplyAvailable": waterSupplyAvailable,
    "SurroundingLandUse": surroundingLandUse,
    "TypeOfLandTenureType": typeOfLandTenureType,
    "LandOwnershipType": landOwnershipType,
    "DistanceFromNearestTownKM": distanceFromNearestTownKm,
    "DistanceFromHighwayKM": distanceFromHighwayKm,
    "DistanceFromRailwayStationKM": distanceFromRailwayStationKm,
    "DistanceFromAirportKM": distanceFromAirportKm,
    "TotalNumberOfTreesonSite": totalNumberOfTreesonSite,
    "PhotoURL": photoUrl,
    "Remark": remark,
    "ClientRegistrationId": clientRegistrationId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
