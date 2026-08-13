import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TenantModel {
  int tenantId;
  String uniquekey;
  String systemGeneratedCode;
  int projectId;
  int buildingId;
  String unitAnnexureSurveyNumber;
  String applicantName;
  String unitType;
  String unitConfiguration;
  double unitCarpetAreaSqFt;
  String unitFacing;
  double extraFreeCarpetAreaOfferedPercent;
  double freeMOFACarpetAreaSqFt;
  double newEligibilityMOFACarpetAreaSqFt;
  double newEligibilityRERACarpetAreaSqFt;
  double mofaCarpetAreaPurchasedSqFt;
  double reraCarpetAreaPurchasedSqFt;
  double totalNewMOFACarpetAreaSqFt;
  double totalNewRERACarpetAreaSqFt;
  double deckAreaSqFt;
  double existingTerraceAreaSqFt;
  double areaAgainstTerraceSqFt;
  double totalNewRERACarpetAreaWithDeckSqFt;
  String remark;
  int inventoryFlatId;
  String buildingNumber;
  String wing;
  String floor;
  String flat;
  double reraCarpetAreaSqFt;
  String inventoryFlatType;
  String inventoryFlatConfiguration;
  String parkingNumber;
  String flatFacing;
  List<ParkingModel> parkingData;
  String parkingId;
  List<TenantApplicantData> tenantApplicantData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  int bookingId;
  TenantModel({
    required this.tenantId,
    required this.uniquekey,
    required this.systemGeneratedCode,
    required this.projectId,
    required this.buildingId,
    required this.unitAnnexureSurveyNumber,
    required this.applicantName,
    required this.unitType,
    required this.unitConfiguration,
    required this.unitCarpetAreaSqFt,
    required this.unitFacing,
    required this.extraFreeCarpetAreaOfferedPercent,
    required this.freeMOFACarpetAreaSqFt,
    required this.newEligibilityMOFACarpetAreaSqFt,
    required this.newEligibilityRERACarpetAreaSqFt,
    required this.mofaCarpetAreaPurchasedSqFt,
    required this.reraCarpetAreaPurchasedSqFt,
    required this.totalNewMOFACarpetAreaSqFt,
    required this.totalNewRERACarpetAreaSqFt,
    required this.deckAreaSqFt,
    required this.existingTerraceAreaSqFt,
    required this.areaAgainstTerraceSqFt,
    required this.totalNewRERACarpetAreaWithDeckSqFt,
    required this.remark,
    required this.inventoryFlatId,
    required this.buildingNumber,
    required this.wing,
    required this.floor,
    required this.flat,
    required this.reraCarpetAreaSqFt,
    required this.inventoryFlatType,
    required this.inventoryFlatConfiguration,
    required this.parkingNumber,
    required this.flatFacing,
    required this.parkingData,
    required this.parkingId,
    required this.tenantApplicantData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.bookingId,
  });
  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      tenantId: parseValue<int>(json, "TenantId"),
      uniquekey: parseValue<String>(json, "Uniquekey"),
      systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
      projectId: parseValue<int>(json, "ProjectId"),
      buildingId: parseValue<int>(json, "BuildingId"),
      unitAnnexureSurveyNumber: parseValue<String>(
        json,
        "UnitAnnexureSurveyNumber",
      ),
      applicantName: parseValue<String>(json, "ApplicantName"),
      unitType: parseValue<String>(json, "UnitType"),
      unitConfiguration: parseValue<String>(json, "UnitConfiguration"),
      unitCarpetAreaSqFt: parseValue<double>(json, "UnitCarpetAreaSqFt"),
      unitFacing: parseValue<String>(json, "UnitFacing"),
      extraFreeCarpetAreaOfferedPercent: parseValue<double>(
        json,
        "ExtraFreeCarpetAreaOfferedPercent",
      ),
      freeMOFACarpetAreaSqFt: parseValue<double>(
        json,
        "FreeMOFACarpetAreaSqFt",
      ),
      newEligibilityMOFACarpetAreaSqFt: parseValue<double>(
        json,
        "NewEligibilityMOFACarpetAreaSqFt",
      ),
      newEligibilityRERACarpetAreaSqFt: parseValue<double>(
        json,
        "NewEligibilityRERACarpetAreaSqFt",
      ),
      mofaCarpetAreaPurchasedSqFt: parseValue<double>(
        json,
        "MOFACarpetAreaPurchasedSqFt",
      ),
      reraCarpetAreaPurchasedSqFt: parseValue<double>(
        json,
        "RERACarpetAreaPurchasedSqFt",
      ),
      totalNewMOFACarpetAreaSqFt: parseValue<double>(
        json,
        "TotalNewMOFACarpetAreaSqFt",
      ),
      totalNewRERACarpetAreaSqFt: parseValue<double>(
        json,
        "TotalNewRERACarpetAreaSqFt",
      ),
      deckAreaSqFt: parseValue<double>(json, "DeckAreaSqFt"),
      existingTerraceAreaSqFt: parseValue<double>(
        json,
        "ExistingTerraceAreaSqFt",
      ),
      areaAgainstTerraceSqFt: parseValue<double>(
        json,
        "AreaAgainstTerraceSqFt",
      ),
      totalNewRERACarpetAreaWithDeckSqFt: parseValue<double>(
        json,
        "TotalNewRERACarpetAreaWithDeckSqFt",
      ),
      remark: parseValue<String>(json, "Remark"),
      inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
      buildingNumber: parseValue<String>(json, "BuildingNumber"),
      wing: parseValue<String>(json, "Wing"),
      floor: parseValue<String>(json, "Floor"),
      flat: parseValue<String>(json, "Flat"),
      reraCarpetAreaSqFt: parseValue<double>(json, "RERACarpetAreaSqFt"),
      inventoryFlatType: parseValue<String>(json, "InventoryFlatType"),
      inventoryFlatConfiguration: parseValue<String>(
        json,
        "InventoryFlatConfiguration",
      ),
      parkingNumber: parseValue<String>(json, "ParkingNumber"),
      flatFacing: parseValue<String>(json, "FlatFacing"),
      parkingData:
          json["ParkingData"] != null && json["ParkingData"] is List
              ? (json["ParkingData"] as List)
                  .map(
                    (e) => ParkingModel.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : [],
      parkingId: parseValue<String>(json, "ParkingId"),
      tenantApplicantData:
          json["TenantApplicantData"] != null &&
                  json["TenantApplicantData"] is List
              ? (json["TenantApplicantData"] as List)
                  .map(
                    (e) => TenantApplicantData.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList()
              : [],
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate: parseValue<DateTime>(json, "CreatedDate"),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate:
          json["ModifiedDate"] == null
              ? null
              : parseValue<DateTime>(json, "ModifiedDate"),
      bookingId: parseValue<int>(json, "BookingId"),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "TenantId": tenantId,
      "Uniquekey": uniquekey,
      "SystemGeneratedCode": systemGeneratedCode,
      "ProjectId": projectId,
      "BuildingId": buildingId,
      "UnitAnnexureSurveyNumber": unitAnnexureSurveyNumber,
      "ApplicantName": applicantName,
      "UnitType": unitType,
      "UnitConfiguration": unitConfiguration,
      "UnitCarpetAreaSqFt": unitCarpetAreaSqFt,
      "UnitFacing": unitFacing,
      "ExtraFreeCarpetAreaOfferedPercent": extraFreeCarpetAreaOfferedPercent,
      "FreeMOFACarpetAreaSqFt": freeMOFACarpetAreaSqFt,
      "NewEligibilityMOFACarpetAreaSqFt": newEligibilityMOFACarpetAreaSqFt,
      "NewEligibilityRERACarpetAreaSqFt": newEligibilityRERACarpetAreaSqFt,
      "MOFACarpetAreaPurchasedSqFt": mofaCarpetAreaPurchasedSqFt,
      "RERACarpetAreaPurchasedSqFt": reraCarpetAreaPurchasedSqFt,
      "TotalNewMOFACarpetAreaSqFt": totalNewMOFACarpetAreaSqFt,
      "TotalNewRERACarpetAreaSqFt": totalNewRERACarpetAreaSqFt,
      "DeckAreaSqFt": deckAreaSqFt,
      "ExistingTerraceAreaSqFt": existingTerraceAreaSqFt,
      "AreaAgainstTerraceSqFt": areaAgainstTerraceSqFt,
      "TotalNewRERACarpetAreaWithDeckSqFt": totalNewRERACarpetAreaWithDeckSqFt,
      "Remark": remark,
      "InventoryFlatId": inventoryFlatId,
      "BuildingNumber": buildingNumber,
      "Wing": wing,
      "Floor": floor,
      "Flat": flat,
      "RERACarpetAreaSqFt": reraCarpetAreaSqFt,
      "InventoryFlatType": inventoryFlatType,
      "InventoryFlatConfiguration": inventoryFlatConfiguration,
      "ParkingNumber": parkingNumber,
      "FlatFacing": flatFacing,
      "ParkingData": parkingData.map((e) => e.toJson()).toList(),
      "ParkingId": parkingId,
      "TenantApplicantData":
          tenantApplicantData.map((e) => e.toJson()).toList(),
      "CreatedById": createdById,
      "CreatedBy": createdBy,
      "CreatedDate": createdDate.toIso8601String(),
      "ModifiedById": modifiedById,
      "ModifiedBy": modifiedBy,
      "ModifiedDate": modifiedDate?.toIso8601String(),
      "BookingId": bookingId,
    };
  }
}

class TenantApplicantData {
  int? tenantApplicantId;
  int tenantId;
  int buildingId;
  int projectId;
  String applicantType;
  String applicantName;
  String applicantMobileNumberCountryCode;
  String applicantMobileNumber;
  String applicantEmailId;
  String photoURL;
  String aadharCardNumber;
  String aadharCardURL;
  String panNumber;
  String panCardURL;
  String passportNumber;
  String passportURL;
  String drivingLicenseNumber;
  String drivingLicenseURL;
  String votingIdNumber;
  String votingIdURL;
  String gstNumber;
  String gstNumberURL;
  int bankListMasterId;
  String bankName;
  String accountNumber;
  String ifscCode;
  String chequeURL;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  String lastModifiedBy;
  DateTime? lastModifiedDate;
  MultiFilePickerModel chequeImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel profilePhotoImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel aadhaarImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel panImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel passportImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel drivingLicenseImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel votingIdImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel gstImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  TenantApplicantData({
    required this.tenantApplicantId,
    required this.tenantId,
    required this.buildingId,
    required this.projectId,
    required this.applicantType,
    required this.applicantName,
    required this.applicantMobileNumberCountryCode,
    required this.applicantMobileNumber,
    required this.applicantEmailId,
    required this.photoURL,
    required this.aadharCardNumber,
    required this.aadharCardURL,
    required this.panNumber,
    required this.panCardURL,
    required this.passportNumber,
    required this.passportURL,
    required this.drivingLicenseNumber,
    required this.drivingLicenseURL,
    required this.votingIdNumber,
    required this.votingIdURL,
    required this.gstNumber,
    required this.gstNumberURL,
    required this.bankListMasterId,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.chequeURL,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.lastModifiedBy,
    required this.lastModifiedDate,
  });
  factory TenantApplicantData.fromJson(Map<String, dynamic> json) {
    return TenantApplicantData(
      tenantApplicantId:
          json["TenantApplicantId"] == null
              ? null
              : parseValue<int>(json, "TenantApplicantId"),
      tenantId: parseValue<int>(json, "TenantId"),
      buildingId: parseValue<int>(json, "BuildingId"),
      projectId: parseValue<int>(json, "ProjectId"),
      applicantType: parseValue<String>(json, "ApplicantType"),
      applicantName: parseValue<String>(json, "ApplicantName"),
      applicantMobileNumberCountryCode: parseValue<String>(
        json,
        "ApplicantMobileNumberCountryCode",
      ),
      applicantMobileNumber: parseValue<String>(json, "ApplicantMobileNumber"),
      applicantEmailId: parseValue<String>(json, "ApplicantEmailId"),
      photoURL: parseValue<String>(json, "PhotoURL"),
      aadharCardNumber: parseValue<String>(json, "AadharCardNumber"),
      aadharCardURL: parseValue<String>(json, "AadharCardURL"),
      panNumber: parseValue<String>(json, "PanNumber"),
      panCardURL: parseValue<String>(json, "PanCardURL"),
      passportNumber: parseValue<String>(json, "PassportNumber"),
      passportURL: parseValue<String>(json, "PassportURL"),
      drivingLicenseNumber: parseValue<String>(json, "DrivingLicenseNumber"),
      ifscCode: parseValue<String>(json, "IFSCCode"),
      chequeURL: parseValue<String>(json, "ChequeURL"),
      createdById: parseValue<int>(json, "CreatedById"),
      createdBy: parseValue<String>(json, "CreatedBy"),
      createdDate:
          json["CreatedDate"] == null
              ? null
              : parseValue<DateTime>(json, "CreatedDate"),
      modifiedById: parseValue<int>(json, "ModifiedById"),
      modifiedBy: parseValue<String>(json, "ModifiedBy"),
      modifiedDate:
          json["ModifiedDate"] == null
              ? null
              : parseValue<DateTime>(json, "ModifiedDate"),
      lastModifiedBy:
          json["LastModifiedBy"] == null
              ? ""
              : parseValue<String>(json, "LastModifiedBy"),
      lastModifiedDate:
          json["LastModifiedDate"] == null
              ? null
              : parseValue<DateTime>(json, "LastModifiedDate"),
      drivingLicenseURL: parseValue<String>(json, "DrivingLicenseURL"),
      votingIdNumber: parseValue<String>(json, "VotingIdNumber"),
      votingIdURL: parseValue<String>(json, "VotingIdURL"),
      gstNumber: parseValue<String>(json, "GSTNumber"),
      gstNumberURL: parseValue<String>(json, "GSTNumberURL"),
      bankListMasterId: parseValue<int>(json, "BankListMasterId"),
      bankName: parseValue<String>(json, "BankName"),
      accountNumber: parseValue<String>(json, "AccountNumber"),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "TenantApplicantId": tenantApplicantId,
      "TenantId": tenantId,
      "BuildingId": buildingId,
      "ProjectId": projectId,
      "ApplicantType": applicantType,
      "ApplicantName": applicantName,
      "ApplicantMobileNumberCountryCode": applicantMobileNumberCountryCode,
      "ApplicantMobileNumber": applicantMobileNumber,
      "ApplicantEmailId": applicantEmailId,
      "PhotoURL": photoURL,
      "AadharCardNumber": aadharCardNumber,
      "AadharCardURL": aadharCardURL,
      "PanNumber": panNumber,
      "PanCardURL": panCardURL,
      "PassportNumber": passportNumber,
      "PassportURL": passportURL,
      "DrivingLicenseNumber": drivingLicenseNumber,
      "DrivingLicenseURL": drivingLicenseURL,
      "VotingIdNumber": votingIdNumber,
      "VotingIdURL": votingIdURL,
      "GSTNumber": gstNumber,
      "GSTNumberURL": gstNumberURL,
      "BankListMasterId": bankListMasterId,
      "BankName": bankName,
      "AccountNumber": accountNumber,
      "IFSCCode": ifscCode,
      "ChequeURL": chequeURL,
      "CreatedById": createdById,
      "CreatedBy": createdBy,
      "CreatedDate": createdDate?.toIso8601String(),
      "ModifiedById": modifiedById,
      "ModifiedBy": modifiedBy,
      "ModifiedDate": modifiedDate?.toIso8601String(),
      "LastModifiedBy": lastModifiedBy,
      "LastModifiedDate": lastModifiedDate?.toIso8601String(),
    };
  }
}
