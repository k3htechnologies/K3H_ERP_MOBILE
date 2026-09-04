import 'package:k3h_erp_app/utils/functions/common_function.dart';

class RedevelopmentModel {
  int projectRedevelopmentId;
  String uniquekey;
  String buildingName;
  String buildingAddress;
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
  int yearOfOriginalConstruction;
  String existingBuildingType;
  int numberOfExistingFloors;
  int totalNumberExistingFlatsUnits;
  String identificationLocation;
  String latitudeLongitude;
  String contactPersonName;
  String contactPersonMobile;
  String contactPersonEmail;
  int percentageMemberInFavor;
  String typeOfLandTenure;
  String plotShape;
  int frontage;
  int plotDepth;
  String roadWidth;
  int numberOfExistingBuildingsWings;
  int numberOfFloorsPerWing;
  int totalBuildUpArea;
  double totalCarpetArea;
  int totalCommonArea;
  bool isLiftAvailable;
  bool isFireSafetyProvisionPresent;
  bool isPlotUnderLitigationStay;
  String liftAvailable;
  String fireSafetyProvisionPresent;
  String plotUnderLitigationStay;
  String conveyanceDeed;
  String constructionType;
  String remarks;
  String photoUrl;
  bool isConveyanceDeed;
  int clientRegistrationId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  RedevelopmentModel({
    required this.projectRedevelopmentId,
    required this.uniquekey,
    required this.buildingName,
    required this.buildingAddress,
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
    required this.yearOfOriginalConstruction,
    required this.existingBuildingType,
    required this.numberOfExistingFloors,
    required this.totalNumberExistingFlatsUnits,
    required this.identificationLocation,
    required this.latitudeLongitude,
    required this.contactPersonName,
    required this.contactPersonMobile,
    required this.contactPersonEmail,
    required this.percentageMemberInFavor,
    required this.typeOfLandTenure,
    required this.plotShape,
    required this.frontage,
    required this.plotDepth,
    required this.roadWidth,
    required this.numberOfExistingBuildingsWings,
    required this.numberOfFloorsPerWing,
    required this.totalBuildUpArea,
    required this.totalCarpetArea,
    required this.totalCommonArea,
    required this.isLiftAvailable,
    required this.isFireSafetyProvisionPresent,
    required this.isPlotUnderLitigationStay,
    required this.liftAvailable,
    required this.fireSafetyProvisionPresent,
    required this.plotUnderLitigationStay,
    required this.conveyanceDeed,
    required this.constructionType,
    required this.remarks,
    required this.photoUrl,
    required this.isConveyanceDeed,
    required this.clientRegistrationId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory RedevelopmentModel.fromJson(
    Map<String, dynamic> json,
  ) => RedevelopmentModel(
    projectRedevelopmentId: parseValue<int>(json, "ProjectRedevelopmentId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    buildingName: parseValue<String>(json, "BuildingName"),
    buildingAddress: parseValue<String>(json, "BuildingAddress"),
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
    yearOfOriginalConstruction: parseValue<int>(
      json,
      "YearOfOriginalConstruction",
    ),
    existingBuildingType: parseValue<String>(json, "ExistingBuildingType"),
    numberOfExistingFloors: parseValue<int>(json, "NumberOfExistingFloors"),
    totalNumberExistingFlatsUnits: parseValue<int>(
      json,
      "TotalNumberExistingFlatsUnits",
    ),
    identificationLocation: parseValue<String>(json, "IdentificationLocation"),
    latitudeLongitude: parseValue<String>(json, "LatitudeLongitude"),
    contactPersonName: parseValue<String>(json, "ContactPersonName"),
    contactPersonMobile: parseValue<String>(json, "ContactPersonMobile"),
    contactPersonEmail: parseValue<String>(json, "ContactPersonEmail"),
    percentageMemberInFavor: parseValue<int>(json, "PercentageMemberInFavor"),
    typeOfLandTenure: parseValue<String>(json, "TypeOfLandTenure"),
    plotShape: parseValue<String>(json, "PlotShape"),
    frontage: parseValue<int>(json, "Frontage"),
    plotDepth: parseValue<int>(json, "PlotDepth"),
    roadWidth: parseValue<String>(json, "RoadWidth"),
    numberOfExistingBuildingsWings: parseValue<int>(
      json,
      "NumberOfExistingBuildingsWings",
    ),
    numberOfFloorsPerWing: parseValue<int>(json, "NumberOfFloorsPerWing"),
    totalBuildUpArea: parseValue<int>(json, "TotalBuildUpArea"),
    totalCarpetArea: parseValue<double>(json, "TotalCarpetArea"),
    totalCommonArea: parseValue<int>(json, "TotalCommonArea"),
    isLiftAvailable: parseValue<bool>(json, "IsLiftAvailable"),
    isFireSafetyProvisionPresent: parseValue<bool>(
      json,
      "IsFireSafetyProvisionPresent",
    ),
    isPlotUnderLitigationStay: parseValue<bool>(
      json,
      "IsPlotUnderLitigationStay",
    ),
    liftAvailable: parseValue<String>(json, "LiftAvailable"),
    fireSafetyProvisionPresent: parseValue<String>(
      json,
      "FireSafetyProvisionPresent",
    ),
    plotUnderLitigationStay: parseValue<String>(
      json,
      "PlotUnderLitigationStay",
    ),
    conveyanceDeed: parseValue<String>(json, "ConveyanceDeed"),
    constructionType: parseValue<String>(json, "ConstructionType"),
    remarks: parseValue<String>(json, "Remarks"),
    photoUrl: parseValue<String>(json, "PhotoURL"),
    isConveyanceDeed: parseValue<bool>(json, "IsConveyanceDeed"),
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
    "ProjectRedevelopmentId": projectRedevelopmentId,
    "Uniquekey": uniquekey,
    "BuildingName": buildingName,
    "BuildingAddress": buildingAddress,
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
    "YearOfOriginalConstruction": yearOfOriginalConstruction,
    "ExistingBuildingType": existingBuildingType,
    "NumberOfExistingFloors": numberOfExistingFloors,
    "TotalNumberExistingFlatsUnits": totalNumberExistingFlatsUnits,
    "IdentificationLocation": identificationLocation,
    "LatitudeLongitude": latitudeLongitude,
    "ContactPersonName": contactPersonName,
    "ContactPersonMobile": contactPersonMobile,
    "ContactPersonEmail": contactPersonEmail,
    "PercentageMemberInFavor": percentageMemberInFavor,
    "TypeOfLandTenure": typeOfLandTenure,
    "PlotShape": plotShape,
    "Frontage": frontage,
    "PlotDepth": plotDepth,
    "RoadWidth": roadWidth,
    "NumberOfExistingBuildingsWings": numberOfExistingBuildingsWings,
    "NumberOfFloorsPerWing": numberOfFloorsPerWing,
    "TotalBuildUpArea": totalBuildUpArea,
    "TotalCarpetArea": totalCarpetArea,
    "TotalCommonArea": totalCommonArea,
    "IsLiftAvailable": isLiftAvailable,
    "IsFireSafetyProvisionPresent": isFireSafetyProvisionPresent,
    "IsPlotUnderLitigationStay": isPlotUnderLitigationStay,
    "LiftAvailable": liftAvailable,
    "FireSafetyProvisionPresent": fireSafetyProvisionPresent,
    "PlotUnderLitigationStay": plotUnderLitigationStay,
    "ConveyanceDeed": conveyanceDeed,
    "ConstructionType": constructionType,
    "Remarks": remarks,
    "PhotoURL": photoUrl,
    "IsConveyanceDeed": isConveyanceDeed,
    "ClientRegistrationId": clientRegistrationId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
