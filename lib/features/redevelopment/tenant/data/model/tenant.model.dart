import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

class TenantModel {
  int tenantId;
  String uniquekey;
  int projectId;
  int buildingId;
  String flatNumber;
  double flatCarpetAreaSqFt;
  String facing;
  String flatType;
  String flatConfiguration;
  int freeAreaOfferedPercentage;
  int extraAreaPurchasedSqFt;
  int totalAreaSqFt;
  int inventoryFlatId;
  String buildingNumber;
  String wing;
  String floor;
  int reraCarpetAreaSqFt;
  String inventoryFlatType;
  String inventoryFlatConfiguration;
  List<TenantApplicantData> tenantApplicantData;
  List<ParkingModel> parkingData;
  String parkingNumber;
  String parkingId;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  TenantModel({
    required this.tenantId,
    required this.uniquekey,
    required this.projectId,
    required this.buildingId,
    required this.flatNumber,
    required this.flatCarpetAreaSqFt,
    required this.facing,
    required this.flatType,
    required this.flatConfiguration,
    required this.freeAreaOfferedPercentage,
    required this.extraAreaPurchasedSqFt,
    required this.totalAreaSqFt,
    required this.inventoryFlatId,
    required this.buildingNumber,
    required this.wing,
    required this.floor,
    required this.reraCarpetAreaSqFt,
    required this.inventoryFlatType,
    required this.inventoryFlatConfiguration,
    required this.tenantApplicantData,
    required this.parkingData,
    required this.parkingNumber,
    required this.parkingId,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) => TenantModel(
    tenantId: parseValue<int>(json, "TenantId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    buildingId: parseValue<int>(json, "BuildingId"),
    flatNumber: parseValue<String>(json, "FlatNumber"),
    flatCarpetAreaSqFt: parseValue<double>(json, "FlatCarpetAreaSqFt"),
    facing: parseValue<String>(json, "Facing"),
    flatType: parseValue<String>(json, "FlatType"),
    flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
    freeAreaOfferedPercentage: parseValue<int>(json, "FreeAreaOfferedPercent"),
    extraAreaPurchasedSqFt: parseValue<int>(json, "ExtraAreaPurchasedSqFt"),
    totalAreaSqFt: parseValue<int>(json, "TotalAreaSqFt"),
    inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    wing: parseValue<String>(json, "Wing"),
    floor: parseValue<String>(json, "Floor"),
    reraCarpetAreaSqFt: parseValue<int>(json, "RERACarpetAreaSqFt"),
    inventoryFlatType: parseValue<String>(json, "InventoryFlatType"),
    inventoryFlatConfiguration: parseValue<String>(
      json,
      "InventoryFlatConfiguration",
    ),
    tenantApplicantData:
        json["TenantApplicantData"] != null
            ? List<TenantApplicantData>.from(
              json["TenantApplicantData"].map(
                (e) => TenantApplicantData.fromJson(e),
              ),
            )
            : [],
    parkingData:
        json["ParkingData"] != null
            ? List<ParkingModel>.from(
              json["ParkingData"].map((e) => ParkingModel.fromJson(e)),
            )
            : [],
    parkingNumber: parseValue<String>(json, "ParkingNumber"),
    parkingId: parseValue<String>(json, "ParkingId"),
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
    "TenantId": tenantId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "BuildingId": buildingId,
    "FlatNumber": flatNumber,
    "FlatCarpetAreaSqFt": flatCarpetAreaSqFt,
    "Facing": facing,
    "FlatType": flatType,
    "FlatConfiguration": flatConfiguration,
    "FreeAreaOfferedPercent": freeAreaOfferedPercentage,
    "ExtraAreaPurchasedSqFt": extraAreaPurchasedSqFt,
    "TotalAreaSqFt": totalAreaSqFt,
    "InventoryFlatId": inventoryFlatId,
    "BuildingNumber": buildingNumber,
    "Wing": wing,
    "Floor": floor,
    "RERACarpetAreaSqFt": reraCarpetAreaSqFt,
    "InventoryFlatType": inventoryFlatType,
    "InventoryFlatConfiguration": inventoryFlatConfiguration,
    "TenantApplicantData": tenantApplicantData.map((e) => e.toJson()).toList(),
    "ParkingData": parkingData.map((e) => e.toJson()).toList(),
    "ParkingNumber": parkingNumber,
    "ParkingId": parkingId,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class TenantApplicantData extends BookingApplicantData {
  int tenantApplicantId;
  int tenantId;
  int buildingId;
  int projectId;
  int bankListMasterId;
  String bankName;
  String accountNumber;
  String ifscCode;
  String chequeURL;

  // TENANT-SPECIFIC DOCUMENT VARIABLE
  MultiFilePickerModel chequeImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  MultiFilePickerModel statementOfSourceOfFundsImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  MultiFilePickerModel paymentProofImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  TenantApplicantData({
    required this.tenantApplicantId,
    required this.tenantId,
    required this.buildingId,
    required this.projectId,
    required super.bookingApplicantId,
    required super.applicantType,
    required super.applicantName,
    required super.applicantMobileNumber,
    required super.applicantEmailId,
    required super.photoURL,
    required super.aadharCardNumber,
    required super.aadharCardURL,
    required super.panNumber,
    required super.panCardURL,
    required super.passportNumber,
    required super.passportURL,
    required super.drivingLicenseNumber,
    required super.drivingLicenseURL,
    required super.votingIdNumber,
    required super.votingIdURL,
    required super.gstNumber,
    required super.gstNumberURL,
    required super.cancelledChequeUrl,
    required super.poaurl,
    required super.incomeForm16Itrurl,
    required super.nreNroBankDetailsUrl,
    required super.nomineeFormUrl,
    required this.bankListMasterId,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.chequeURL,
    required super.createdById,
    required super.createdBy,
    required super.createdDate,
    required super.modifiedById,
    required super.modifiedBy,
    required super.modifiedDate,
    required super.statementOfSourceOfFundsURL,
    required super.paymentProofURL,
  });

  factory TenantApplicantData.fromJson(Map<String, dynamic> json) =>
      TenantApplicantData(
        tenantApplicantId: parseValue<int>(json, "TenantApplicantId"),
        tenantId: parseValue<int>(json, "TenantId"),
        buildingId: parseValue<int>(json, "BuildingId"),
        projectId: parseValue<int>(json, "ProjectId"),
        bookingApplicantId: parseValue<int>(json, "BookingApplicantId"),
        applicantType: parseValue<String>(json, "ApplicantType"),
        applicantName: parseValue<String>(json, "ApplicantName"),
        applicantMobileNumber: parseValue<String>(
          json,
          "ApplicantMobileNumber",
        ),
        applicantEmailId: parseValue<String>(json, "ApplicantEmailId"),
        photoURL: parseValue<String>(json, "PhotoURL"),
        aadharCardNumber: parseValue<String>(json, "AadharCardNumber"),
        aadharCardURL: parseValue<String>(json, "AadharCardURL"),
        panNumber: parseValue<String>(json, "PanNumber"),
        panCardURL: parseValue<String>(json, "PanCardURL"),
        passportNumber: parseValue<String>(json, "PassportNumber"),
        passportURL: parseValue<String>(json, "PassportURL"),
        drivingLicenseNumber: parseValue<String>(json, "DrivingLicenseNumber"),
        drivingLicenseURL: parseValue<String>(json, "DrivingLicenseURL"),
        votingIdNumber: parseValue<String>(json, "VotingIdNumber"),
        votingIdURL: parseValue<String>(json, "VotingIdURL"),
        gstNumber: parseValue<String>(json, "GSTNumber"),
        gstNumberURL: parseValue<String>(json, "GSTNumberURL"),
        cancelledChequeUrl: parseValue<String>(json, "CancelledChequeURL"),
        poaurl: parseValue<String>(json, "POAURL"),
        incomeForm16Itrurl: parseValue<String>(json, "IncomeForm16ITRURL"),
        nreNroBankDetailsUrl: parseValue<String>(json, "NreNroBankDetailsURL"),
        nomineeFormUrl: parseValue(json, "NomineeFormURL"),
        bankListMasterId: parseValue<int>(json, "BankListMasterId"),
        bankName: parseValue<String>(json, "BankName"),
        accountNumber: parseValue<String>(json, "AccountNumber"),
        ifscCode: parseValue<String>(json, "IFSCCode"),
        chequeURL: parseValue<String>(json, "ChequeURL"),
        statementOfSourceOfFundsURL: parseValue<String>(
          json,
          "StatementOfSourceOfFundsURL",
        ),
        paymentProofURL: parseValue<String>(json, "PaymentProofURL"),
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

  @override
  Map<String, dynamic> toJson() => {
    "TenantApplicantId": tenantApplicantId,
    "TenantId": tenantId,
    "BuildingId": buildingId,
    "ProjectId": projectId,
    "BookingApplicantId": bookingApplicantId,
    "ApplicantType": applicantType,
    "ApplicantName": applicantName,
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
    "CancelledChequeURL": cancelledChequeUrl,
    "POAURL": poaurl,
    "IncomeForm16ITRURL": incomeForm16Itrurl,
    "NreNroBankDetailsURL": nreNroBankDetailsUrl,
    "NomineeFormURL": nomineeFormUrl,
    "StatementOfSourceOfFundsURL": statementOfSourceOfFundsURL,
    "PaymentProofURL": paymentProofURL,
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "AccountNumber": accountNumber,
    "IFSCCode": ifscCode,
    "ChequeURL": chequeURL,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
