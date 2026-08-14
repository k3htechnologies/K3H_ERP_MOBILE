import 'package:k3h_erp_app/utils/functions/common_function.dart';

class PayTrackModel {
  int bookingId;
  String projectName;
  int projectId;
  int enquiryId;
  String systemGeneratedCode;
  String applicantName;
  String applicantMobileNumberCountryCode;
  String applicantMobileNumber;
  String bookingType;
  int inventoryFlatId;
  String buildingNumber;
  String wing;
  String floor;
  String flat;
  String parkingNumber;
  String flatType;
  int reraCarpetAreaSqFt;
  String flatConfiguration;
  DateTime registrationDate;
  double agreementValue;
  double receivedAgreementValue;
  double agreementValueGstAmount;
  double receivedAgreementValueGstAmount;
  double stampDutyAmount;
  double receivedStampDutyAmount;
  double registrationFees;
  double receivedRegistrationFees;
  double agreementValueTds;
  double receivedAgreementValueTds;
  double otherChargesAmount;
  double receivedOtherChargesAmount;
  double otherChargesGstAmount;
  double receivedOtherChargesGstAmount;
  String approvalStatus;
  double totalAmountReceivedAgainstBooking;
  double totalAmountRefundedAgainstBooking;
  double refundedAmountOnTillDate;
  bool flatAlterationRequestIsApproval;
  String flatAlterationRequestApprovalStatus;
  bool parkingModificationRequestIsApproval;
  String parkingModificationRequestApprovalStatus;
  bool bookingApplicantModificationRequestIsApproval;
  String bookingApprovalStatus;
  String bookingApplicantModificationRequestApprovalStatus;
  int tenantId;
  String applicantEmailId;
  String numberOfParking;
  String? parkingId;
  DateTime? finalRegistrationDate;
  bool isFinalRegistrationCompleted;
  String finalRegistrationUrl;
  String cancelRemark;
  String cancelBookingApprovalStatus;
  bool cancelBookingIsApproval;
  List<BookingOtherChargesDatum> bookingOtherChargesData;
  List<BookingApplicantDatum> bookingApplicantData;
  List<ParkingDatum> parkingData;
  int pendingLedgerApprovalCount;

  PayTrackModel({
    required this.bookingId,
    required this.projectName,
    required this.projectId,
    required this.enquiryId,
    required this.systemGeneratedCode,
    required this.applicantName,
    required this.applicantMobileNumberCountryCode,
    required this.applicantMobileNumber,
    required this.bookingType,
    required this.inventoryFlatId,
    required this.buildingNumber,
    required this.wing,
    required this.floor,
    required this.flat,
    required this.parkingNumber,
    required this.flatType,
    required this.reraCarpetAreaSqFt,
    required this.flatConfiguration,
    required this.registrationDate,
    required this.agreementValue,
    required this.receivedAgreementValue,
    required this.agreementValueGstAmount,
    required this.receivedAgreementValueGstAmount,
    required this.stampDutyAmount,
    required this.receivedStampDutyAmount,
    required this.registrationFees,
    required this.receivedRegistrationFees,
    required this.agreementValueTds,
    required this.receivedAgreementValueTds,
    required this.otherChargesAmount,
    required this.receivedOtherChargesAmount,
    required this.otherChargesGstAmount,
    required this.receivedOtherChargesGstAmount,
    required this.approvalStatus,
    required this.totalAmountReceivedAgainstBooking,
    required this.totalAmountRefundedAgainstBooking,
    required this.refundedAmountOnTillDate,
    required this.flatAlterationRequestIsApproval,
    required this.flatAlterationRequestApprovalStatus,
    required this.parkingModificationRequestIsApproval,
    required this.parkingModificationRequestApprovalStatus,
    required this.bookingApplicantModificationRequestIsApproval,
    required this.bookingApprovalStatus,
    required this.bookingApplicantModificationRequestApprovalStatus,
    required this.tenantId,
    required this.applicantEmailId,
    required this.finalRegistrationDate,
    required this.isFinalRegistrationCompleted,
    required this.finalRegistrationUrl,
    required this.cancelRemark,
    required this.cancelBookingApprovalStatus,
    required this.cancelBookingIsApproval,
    required this.numberOfParking,
    required this.bookingOtherChargesData,
    required this.bookingApplicantData,
    required this.parkingData,
    required this.pendingLedgerApprovalCount,
  });

  factory PayTrackModel.fromJson(Map<String, dynamic> json) => PayTrackModel(
    bookingId: parseValue<int>(json, "BookingId"),
    projectName: parseValue<String>(json, "ProjectName"),
    projectId: parseValue<int>(json, "ProjectId"),
    enquiryId: parseValue<int>(json, "EnquiryId"),
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    applicantName: parseValue<String>(json, "ApplicantName"),
    applicantMobileNumberCountryCode: parseValue<String>(
      json,
      "ApplicantMobileNumberCountryCode",
    ),
    applicantMobileNumber: parseValue<String>(json, "ApplicantMobileNumber"),
    bookingType: parseValue<String>(json, "BookingType"),
    inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    wing: parseValue<String>(json, "Wing"),
    floor: parseValue<String>(json, "Floor"),
    flat: parseValue<String>(json, "Flat"),
    parkingNumber: parseValue<String>(json, "ParkingNumber"),
    flatType: parseValue<String>(json, "FlatType"),
    reraCarpetAreaSqFt: parseValue<int>(json, "ReraCarpetAreaSqFt"),
    flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
    registrationDate: parseValue<DateTime>(json, "RegistrationDate"),
    agreementValue: parseValue<double>(json, "AgreementValue"),
    receivedAgreementValue: parseValue<double>(json, "ReceivedAgreementValue"),
    agreementValueGstAmount: parseValue<double>(
      json,
      "AgreementValueGSTAmount",
    ),
    receivedAgreementValueGstAmount: parseValue<double>(
      json,
      "ReceivedAgreementValueGSTAmount",
    ),
    stampDutyAmount: parseValue<double>(json, "StampDutyAmount"),
    receivedStampDutyAmount: parseValue<double>(
      json,
      "ReceivedStampDutyAmount",
    ),
    registrationFees: parseValue<double>(json, "RegistrationFees"),
    receivedRegistrationFees: parseValue<double>(
      json,
      "ReceivedRegistrationFees",
    ),
    agreementValueTds: parseValue<double>(json, "AgreementValueTDS"),
    receivedAgreementValueTds: parseValue<double>(
      json,
      "ReceivedAgreementValueTDS",
    ),
    otherChargesAmount: parseValue<double>(json, "OtherChargesAmount"),
    receivedOtherChargesAmount: parseValue<double>(
      json,
      "ReceivedOtherChargesAmount",
    ),
    otherChargesGstAmount: parseValue<double>(json, "OtherChargesGSTAmount"),
    receivedOtherChargesGstAmount: parseValue<double>(
      json,
      "ReceivedOtherChargesGSTAmount",
    ),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    totalAmountReceivedAgainstBooking: parseValue<double>(
      json,
      "TotalAmountReceivedAgainstBooking",
    ),
    totalAmountRefundedAgainstBooking: parseValue<double>(
      json,
      "TotalAmountRefundedAgainstBooking",
    ),
    refundedAmountOnTillDate: parseValue<double>(
      json,
      "RefundedAmountOnTillDate",
    ),
    flatAlterationRequestIsApproval: parseValue<bool>(
      json,
      "FlatAlterationRequestIsApproval",
    ),
    flatAlterationRequestApprovalStatus: parseValue<String>(
      json,
      "FlatAlterationRequestApprovalStatus",
    ),
    parkingModificationRequestIsApproval: parseValue<bool>(
      json,
      "ParkingModificationRequestIsApproval",
    ),
    parkingModificationRequestApprovalStatus: parseValue<String>(
      json,
      "ParkingModificationRequestApprovalStatus",
    ),
    bookingApplicantModificationRequestIsApproval: parseValue<bool>(
      json,
      "BookingApplicantModificationRequestIsApproval",
    ),
    bookingApprovalStatus: parseValue<String>(json, "BookingApprovalStatus"),
    bookingApplicantModificationRequestApprovalStatus: parseValue<String>(
      json,
      "BookingApplicantModificationRequestApprovalStatus",
    ),
    tenantId: parseValue<int>(json, "TenantId"),
    applicantEmailId: json["ApplicantEmailId"],
    numberOfParking: json["NumberOfParking"],
    finalRegistrationDate:
        json["FinalRegistrationDate"] != null
            ? DateTime.parse(json["FinalRegistrationDate"])
            : null,
    isFinalRegistrationCompleted: json["IsFinalRegistrationCompleted"],
    finalRegistrationUrl: json["FinalRegistrationURL"],

    bookingOtherChargesData: List<BookingOtherChargesDatum>.from(
      json["BookingOtherChargesData"].map(
        (x) => BookingOtherChargesDatum.fromJson(x),
      ),
    ),
    bookingApplicantData: List<BookingApplicantDatum>.from(
      json["BookingApplicantData"].map(
        (x) => BookingApplicantDatum.fromJson(x),
      ),
    ),
    parkingData: List<ParkingDatum>.from(
      json["ParkingData"].map((x) => ParkingDatum.fromJson(x)),
    ),
    cancelRemark: parseValue<String>(json, "CancelRemark"),
    cancelBookingApprovalStatus: parseValue<String>(
      json,
      "CancelBookingApprovalStatus",
    ),
    cancelBookingIsApproval: parseValue<bool>(json, "CancelBookingIsApproval"),
    pendingLedgerApprovalCount: parseValue<int>(
      json,
      "PendingLedgerApprovalCount",
    ),
  );

  Map<String, dynamic> toJson() => {
    "BookingId": bookingId,
    "ProjectName": projectName,
    "ProjectId": projectId,
    "EnquiryId": enquiryId,
    "SystemGeneratedCode": systemGeneratedCode,
    "ApplicantName": applicantName,
    "ApplicantMobileNumberCountryCode": applicantMobileNumberCountryCode,
    "ApplicantMobileNumber": applicantMobileNumber,
    "BookingType": bookingType,
    "InventoryFlatId": inventoryFlatId,
    "BuildingNumber": buildingNumber,
    "Wing": wing,
    "Floor": floor,
    "Flat": flat,
    "ParkingNumber": parkingNumber,
    "FlatType": flatType,
    "ReraCarpetAreaSqFt": reraCarpetAreaSqFt,
    "FlatConfiguration": flatConfiguration,
    "RegistrationDate": registrationDate.toIso8601String(),
    "AgreementValue": agreementValue.toDouble(),
    "ReceivedAgreementValue": receivedAgreementValue.toDouble(),
    "AgreementValueGSTAmount": agreementValueGstAmount.toDouble(),
    "ReceivedAgreementValueGSTAmount": receivedAgreementValueGstAmount,
    "StampDutyAmount": stampDutyAmount.toDouble(),
    "ReceivedStampDutyAmount": receivedStampDutyAmount.toDouble(),
    "RegistrationFees": registrationFees.toDouble(),
    "ReceivedRegistrationFees": receivedRegistrationFees.toDouble(),
    "AgreementValueTDS": agreementValueTds.toDouble(),
    "ReceivedAgreementValueTDS": receivedAgreementValueTds.toDouble(),
    "OtherChargesAmount": otherChargesAmount.toDouble(),
    "ReceivedOtherChargesAmount": receivedOtherChargesAmount.toDouble(),
    "OtherChargesGSTAmount": otherChargesGstAmount.toDouble(),
    "ReceivedOtherChargesGSTAmount": receivedOtherChargesGstAmount.toDouble(),
    "ApprovalStatus": approvalStatus,
    "TotalAmountReceivedAgainstBooking":
        totalAmountReceivedAgainstBooking.toDouble(),
    "TotalAmountRefundedAgainstBooking":
        totalAmountRefundedAgainstBooking.toDouble(),
    "RefundedAmountOnTillDate": refundedAmountOnTillDate.toDouble(),
    "FlatAlterationRequestIsApproval": flatAlterationRequestIsApproval,
    "FlatAlterationRequestApprovalStatus": flatAlterationRequestApprovalStatus,
    "ParkingModificationRequestIsApproval":
        parkingModificationRequestIsApproval,
    "ParkingModificationRequestApprovalStatus":
        parkingModificationRequestApprovalStatus,
    "BookingApplicantModificationRequestIsApproval":
        bookingApplicantModificationRequestIsApproval,
    "BookingApprovalStatus": bookingApprovalStatus,
    "BookingApplicantModificationRequestApprovalStatus":
        bookingApplicantModificationRequestApprovalStatus,
    "TenantId": tenantId,
    "ApplicantEmailId": applicantEmailId,
    "NumberOfParking": numberOfParking,
    "RERACarpetAreaSqFt": reraCarpetAreaSqFt,
    "ParkingId": parkingId,
    "FinalRegistrationDate": finalRegistrationDate?.toIso8601String(),
    "IsFinalRegistrationCompleted": isFinalRegistrationCompleted,
    "FinalRegistrationURL": finalRegistrationUrl,
    "PendingLedgerApprovalCount": pendingLedgerApprovalCount,
    "BookingOtherChargesData": List<dynamic>.from(
      bookingOtherChargesData.map((x) => x.toJson()),
    ),
    "BookingApplicantData": List<dynamic>.from(
      bookingApplicantData.map((x) => x.toJson()),
    ),
    "ParkingData": List<dynamic>.from(parkingData.map((x) => x.toJson())),
    "CancelRemark": cancelRemark,
    "CancelBookingApprovalStatus": cancelBookingApprovalStatus,
    "CancelBookingIsApproval": cancelBookingIsApproval,
  };
}

class BookingApplicantDatum {
  int bookingApplicantId;
  String applicantType;
  String applicantName;
  String applicantMobileNumberCountryCode;
  String applicantMobileNumber;
  String applicantEmailId;
  String photoUrl;
  String aadharCardNumber;
  String aadharCardUrl;
  String panNumber;
  String panCardUrl;
  String passportNumber;
  String passportUrl;
  String drivingLicenseNumber;
  String drivingLicenseUrl;
  String votingIdNumber;
  String votingIdUrl;
  String gstNumber;
  String gstNumberUrl;
  String cancelledChequeUrl;
  String poaurl;
  String incomeForm16Itrurl;
  String nreNroBankDetailsUrl;
  String nomineeFormUrl;
  String statementOfSourceOfFundsUrl;
  String paymentProofUrl;
  int createdById;
  String createdBy;
  String createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  BookingApplicantDatum({
    required this.bookingApplicantId,
    required this.applicantType,
    required this.applicantName,
    required this.applicantMobileNumberCountryCode,
    required this.applicantMobileNumber,
    required this.applicantEmailId,
    required this.photoUrl,
    required this.aadharCardNumber,
    required this.aadharCardUrl,
    required this.panNumber,
    required this.panCardUrl,
    required this.passportNumber,
    required this.passportUrl,
    required this.drivingLicenseNumber,
    required this.drivingLicenseUrl,
    required this.votingIdNumber,
    required this.votingIdUrl,
    required this.gstNumber,
    required this.gstNumberUrl,
    required this.cancelledChequeUrl,
    required this.poaurl,
    required this.incomeForm16Itrurl,
    required this.nreNroBankDetailsUrl,
    required this.nomineeFormUrl,
    required this.statementOfSourceOfFundsUrl,
    required this.paymentProofUrl,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BookingApplicantDatum.fromJson(Map<String, dynamic> json) =>
      BookingApplicantDatum(
        bookingApplicantId: json["BookingApplicantId"],
        applicantType: json["ApplicantType"],
        applicantName: json["ApplicantName"],
        applicantMobileNumberCountryCode:
            json["ApplicantMobileNumberCountryCode"],
        applicantMobileNumber: json["ApplicantMobileNumber"],
        applicantEmailId: json["ApplicantEmailId"],
        photoUrl: json["PhotoURL"],
        aadharCardNumber: json["AadharCardNumber"],
        aadharCardUrl: json["AadharCardURL"],
        panNumber: json["PanNumber"],
        panCardUrl: json["PanCardURL"],
        passportNumber: json["PassportNumber"],
        passportUrl: json["PassportURL"],
        drivingLicenseNumber: json["DrivingLicenseNumber"],
        drivingLicenseUrl: json["DrivingLicenseURL"],
        votingIdNumber: json["VotingIdNumber"],
        votingIdUrl: json["VotingIdURL"],
        gstNumber: json["GSTNumber"],
        gstNumberUrl: json["GSTNumberURL"],
        cancelledChequeUrl: json["CancelledChequeURL"],
        poaurl: json["POAURL"],
        incomeForm16Itrurl: json["IncomeForm16ITRURL"],
        nreNroBankDetailsUrl: json["NreNroBankDetailsURL"],
        nomineeFormUrl: json["NomineeFormURL"],
        statementOfSourceOfFundsUrl: json["StatementOfSourceOfFundsURL"],
        paymentProofUrl: json["PaymentProofURL"],
        createdById: json["CreatedById"],
        createdBy: json["CreatedBy"],
        createdDate: json["CreatedDate"],
        modifiedById: json["ModifiedById"],
        modifiedBy: json["ModifiedBy"],
        modifiedDate: json["ModifiedDate"],
      );

  Map<String, dynamic> toJson() => {
    "BookingApplicantId": bookingApplicantId,
    "ApplicantType": applicantType,
    "ApplicantName": applicantName,
    "ApplicantMobileNumberCountryCode": applicantMobileNumberCountryCode,
    "ApplicantMobileNumber": applicantMobileNumber,
    "ApplicantEmailId": applicantEmailId,
    "PhotoURL": photoUrl,
    "AadharCardNumber": aadharCardNumber,
    "AadharCardURL": aadharCardUrl,
    "PanNumber": panNumber,
    "PanCardURL": panCardUrl,
    "PassportNumber": passportNumber,
    "PassportURL": passportUrl,
    "DrivingLicenseNumber": drivingLicenseNumber,
    "DrivingLicenseURL": drivingLicenseUrl,
    "VotingIdNumber": votingIdNumber,
    "VotingIdURL": votingIdUrl,
    "GSTNumber": gstNumber,
    "GSTNumberURL": gstNumberUrl,
    "CancelledChequeURL": cancelledChequeUrl,
    "POAURL": poaurl,
    "IncomeForm16ITRURL": incomeForm16Itrurl,
    "NreNroBankDetailsURL": nreNroBankDetailsUrl,
    "NomineeFormURL": nomineeFormUrl,
    "StatementOfSourceOfFundsURL": statementOfSourceOfFundsUrl,
    "PaymentProofURL": paymentProofUrl,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}

class BookingOtherChargesDatum {
  int bookingOtherChargesId;
  String uniquekey;
  String chargeName;
  String calculatedOn;
  int value;
  int gstPercentage;
  int gstValue;
  int createdById;
  String createdBy;
  String createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;

  BookingOtherChargesDatum({
    required this.bookingOtherChargesId,
    required this.uniquekey,
    required this.chargeName,
    required this.calculatedOn,
    required this.value,
    required this.gstPercentage,
    required this.gstValue,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BookingOtherChargesDatum.fromJson(Map<String, dynamic> json) =>
      BookingOtherChargesDatum(
        bookingOtherChargesId: parseValue<int>(json, "BookingOtherChargesId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        chargeName: parseValue<String>(json, "ChargeName"),
        calculatedOn: parseValue<String>(json, "CalculatedOn"),
        value: parseValue<int>(json, "Value"),
        gstPercentage: parseValue<int>(json, "GSTPercentage"),
        gstValue: parseValue<int>(json, "GSTValue"),
        createdById: parseValue<int>(json, "CreatedById"),
        createdBy: parseValue<String>(json, "CreatedBy"),
        createdDate: parseValue<String>(json, "CreatedDate"),
        modifiedById: parseValue<int>(json, "ModifiedById"),
        modifiedBy: parseValue<String>(json, "ModifiedBy"),
        modifiedDate: parseValue<String>(json, "ModifiedDate"),
      );

  Map<String, dynamic> toJson() => {
    "BookingOtherChargesId": bookingOtherChargesId,
    "Uniquekey": uniquekey,
    "ChargeName": chargeName,
    "CalculatedOn": calculatedOn,
    "Value": value,
    "GSTPercentage": gstPercentage,
    "GSTValue": gstValue,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}

class ParkingDatum {
  int parkingId;
  String uniquekey;
  int projectId;
  String parkingNumber;
  String parkingCategory;
  String parkingType;
  String parkingSubType;
  String parkingDimensions;
  bool isEvChargingAvailable;
  String evChargingAvailable;
  String parkingStatus;
  int inventoryBuildingId;
  String buildingNumber;
  int inventoryFlatFloorBasementPodiumWingId;
  String wing;
  int inventoryFloorId;
  String floor;
  String ownerName;
  int bookingId;
  bool isApproval;
  String approvalStatus;
  int parkingBookingCreatedById;
  String parkingBookingCreatedBy;
  String? parkingBookingCreatedDate;
  int createdById;
  String createdBy;
  String createdDate;
  int modifiedById;
  String modifiedBy;
  String modifiedDate;

  ParkingDatum({
    required this.parkingId,
    required this.uniquekey,
    required this.projectId,
    required this.parkingNumber,
    required this.parkingCategory,
    required this.parkingType,
    required this.parkingSubType,
    required this.parkingDimensions,
    required this.isEvChargingAvailable,
    required this.evChargingAvailable,
    required this.parkingStatus,
    required this.inventoryBuildingId,
    required this.buildingNumber,
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.wing,
    required this.inventoryFloorId,
    required this.floor,
    required this.ownerName,
    required this.bookingId,
    required this.isApproval,
    required this.approvalStatus,
    required this.parkingBookingCreatedById,
    required this.parkingBookingCreatedBy,
    required this.parkingBookingCreatedDate,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory ParkingDatum.fromJson(Map<String, dynamic> json) => ParkingDatum(
    parkingId: parseValue<int>(json, "ParkingId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    projectId: parseValue<int>(json, "ProjectId"),
    parkingNumber: parseValue<String>(json, "ParkingNumber"),
    parkingCategory: parseValue<String>(json, "ParkingCategory"),
    parkingType: parseValue<String>(json, "ParkingType"),
    parkingSubType: parseValue<String>(json, "ParkingSubType"),
    parkingDimensions: parseValue<String>(json, "ParkingDimensions"),
    isEvChargingAvailable: parseValue<bool>(json, "IsEVChargingAvailable"),
    evChargingAvailable: parseValue<String>(json, "EVChargingAvailable"),
    parkingStatus: parseValue<String>(json, "ParkingStatus"),
    inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
      json,
      "InventoryFlatFloorBasementPodiumWingId",
    ),
    wing: parseValue<String>(json, "Wing"),
    inventoryFloorId: parseValue<int>(json, "InventoryFloorId"),
    floor: parseValue<String>(json, "Floor"),
    ownerName: parseValue<String>(json, "OwnerName"),
    bookingId: parseValue<int>(json, "BookingId"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    parkingBookingCreatedById: parseValue<int>(
      json,
      "ParkingBookingCreatedById",
    ),
    parkingBookingCreatedBy: parseValue<String>(
      json,
      "ParkingBookingCreatedBy",
    ),
    parkingBookingCreatedDate: parseValue<String>(
      json,
      "ParkingBookingCreatedDate",
    ),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<String>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate: parseValue<String>(json, "ModifiedDate"),
  );

  Map<String, dynamic> toJson() => {
    "ParkingId": parkingId,
    "Uniquekey": uniquekey,
    "ProjectId": projectId,
    "ParkingNumber": parkingNumber,
    "ParkingCategory": parkingCategory,
    "ParkingType": parkingType,
    "ParkingSubType": parkingSubType,
    "ParkingDimensions": parkingDimensions,
    "IsEVChargingAvailable": isEvChargingAvailable,
    "EVChargingAvailable": evChargingAvailable,
    "ParkingStatus": parkingStatus,
    "InventoryBuildingId": inventoryBuildingId,
    "BuildingNumber": buildingNumber,
    "InventoryFlatFloorBasementPodiumWingId":
        inventoryFlatFloorBasementPodiumWingId,
    "Wing": wing,
    "InventoryFloorId": inventoryFloorId,
    "Floor": floor,
    "OwnerName": ownerName,
    "BookingId": bookingId,
    "IsApproval": isApproval,
    "ApprovalStatus": approvalStatus,
    "ParkingBookingCreatedById": parkingBookingCreatedById,
    "ParkingBookingCreatedBy": parkingBookingCreatedBy,
    "ParkingBookingCreatedDate": parkingBookingCreatedDate,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
