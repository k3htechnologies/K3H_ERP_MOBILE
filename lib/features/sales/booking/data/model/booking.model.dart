import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/payment_schedule_data.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BookingModel {
  int bookingId;
  String uniquekey;
  String applicantName;
  List<BookingApplicantData> bookingApplicantData;
  String applicantMobileNumber;
  String applicantMobileNumberCountryCode;
  String permanentAddress;
  String systemGeneratedCode;
  int inventoryFlatFloorBasementPodiumWingId;
  int inventoryBuildingId;
  String paymentRemark;
  String otherRemark;
  int transferBookingId;
  String transferFlat;
  int tenantId;
  int paymentScheduleSchemeMasterId;
  String paymentScheduleScheme;
  String communicationAddress;
  String sourceOfFunding;
  String source;
  String subSource;
  String channelPartnerName;
  String channelPartnerCompany;
  String channelPartnerMobileNumber;
  double brokeragePercentage;
  double brokerageAmount;
  double referelPercentage;
  double referelAmount;
  double loyaltyPercentage;
  double loyaltyAmount;
  double employeeReferencePercentage;
  double employeeReferenceAmount;
  int inventoryFlatId;
  String buildingNumber;
  String wing;
  String floor;
  String flat;
  String flatType;
  double reraCarpetAreaSqFt;
  String flatConfiguration;
  double agreementValue;
  double agreementValueTDS;
  double agreementValueGSTPercentage;
  double agreementValueGSTAmount;
  double stampDutyPercentage;
  double stampDutyAmount;
  double registrationFees;
  String parkingId;
  String parkingNumber;
  String handoverType;
  DateTime registrationDate;
  DateTime? finalRegistrationDate;
  bool isFinalRegistrationCompleted;
  String modeOfPayment;
  double bookingAmount;
  String chequeRTGSNumber;
  DateTime? chequeRTGSDate;
  int bankListMasterId;
  String bankName;
  String approvalStatus;
  bool isApproval;
  String bookingType;
  List<OtherChargeModel> bookingOtherChargesData;
  List<BookingPaymentScheduleData> bookingPaymentScheduleData;
  List<ParkingModel> parkingData;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  int projectId;
  int enquiryId;
  String projectName;
  String flatAlterationRemark;
  String termsAndConditionsDescription;
  double totalAmountReceivedAgainstBooking;
  double totalAmountRefundedAgainstBooking;
  double refundedAmountOnTillDate;
  bool flatAlterationRequestIsApproval;
  String flatAlterationRequestApprovalStatus;
  bool parkingModificationRequestIsApproval;
  String parkingModificationRequestApprovalStatus;
  bool bookingApplicantModificationRequestIsApproval;
  String bookingApplicantModificationRequestApprovalStatus;
  int numberOfParking;
  bool isApplicableOtherCharge;
  String applicantMobileNumberCountryCode;
  String applicantMobileNumber;
  String channelPartnerMobileNumberCountryCode;
  double referralPercentage;
  double referralAmount;
  String finalRegistrationUrl;
  double agreementValueTds;
  double agreementValueGstPercentage;
  double agreementValueGstAmount;
  String chequeRtgsNumber;
  DateTime? chequeRtgsDate;
  int cancelledById;
  String cancelledBy;
  DateTime? cancelledDate;
  String cancelRemark;
  String proofOfDocumentUrl;
  String cancelBookingApprovalStatus;
  int refundedPaymentLedgerCount;

  BookingModel({
    required this.bookingId,
    required this.uniquekey,
    required this.applicantName,
    required this.bookingApplicantData,
    required this.applicantMobileNumber,
    required this.applicantMobileNumberCountryCode,
    required this.permanentAddress,
    required this.systemGeneratedCode,
    required this.inventoryFlatFloorBasementPodiumWingId,
    required this.inventoryBuildingId,
    required this.paymentRemark,
    required this.otherRemark,
    required this.transferBookingId,
    required this.transferFlat,
    required this.tenantId,
    required this.paymentScheduleSchemeMasterId,
    required this.paymentScheduleScheme,
    required this.communicationAddress,
    required this.sourceOfFunding,
    required this.source,
    required this.subSource,
    required this.channelPartnerName,
    required this.channelPartnerCompany,
    required this.channelPartnerMobileNumber,
    required this.brokeragePercentage,
    required this.brokerageAmount,
    required this.referelPercentage,
    required this.referelAmount,
    required this.loyaltyPercentage,
    required this.loyaltyAmount,
    required this.employeeReferencePercentage,
    required this.employeeReferenceAmount,
    required this.inventoryFlatId,
    required this.buildingNumber,
    required this.wing,
    required this.floor,
    required this.flat,
    required this.flatType,
    required this.reraCarpetAreaSqFt,
    required this.flatConfiguration,
    required this.agreementValue,
    required this.agreementValueTDS,
    required this.agreementValueGSTPercentage,
    required this.agreementValueGSTAmount,
    required this.stampDutyPercentage,
    required this.stampDutyAmount,
    required this.registrationFees,
    required this.parkingId,
    required this.parkingNumber,
    required this.handoverType,
    required this.registrationDate,
    this.finalRegistrationDate,
    required this.isFinalRegistrationCompleted,
    required this.modeOfPayment,
    required this.bookingAmount,
    required this.chequeRTGSNumber,
    required this.chequeRTGSDate,
    required this.bankListMasterId,
    required this.bankName,
    required this.approvalStatus,
    required this.isApproval,
    required this.bookingType,
    required this.bookingOtherChargesData,
    required this.bookingPaymentScheduleData,
    required this.parkingData,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.projectId,
    required this.enquiryId,
    required this.projectName,
    required this.flatAlterationRemark,
    required this.termsAndConditionsDescription,
    required this.totalAmountReceivedAgainstBooking,
    required this.totalAmountRefundedAgainstBooking,
    required this.refundedAmountOnTillDate,
    required this.flatAlterationRequestIsApproval,
    required this.flatAlterationRequestApprovalStatus,
    required this.parkingModificationRequestIsApproval,
    required this.parkingModificationRequestApprovalStatus,
    required this.bookingApplicantModificationRequestIsApproval,
    required this.bookingApplicantModificationRequestApprovalStatus,
    required this.numberOfParking,
    required this.isApplicableOtherCharge,
    required this.applicantMobileNumberCountryCode,
    required this.applicantMobileNumber,
    required this.channelPartnerMobileNumberCountryCode,
    required this.referralPercentage,
    required this.referralAmount,
    required this.finalRegistrationUrl,
    required this.agreementValueTds,
    required this.agreementValueGstPercentage,
    required this.agreementValueGstAmount,
    required this.chequeRtgsNumber,
    required this.chequeRtgsDate,
    required this.cancelledById,
    required this.cancelledBy,
    required this.cancelledDate,
    required this.cancelRemark,
    required this.proofOfDocumentUrl,
    required this.cancelBookingApprovalStatus,
    required this.refundedPaymentLedgerCount,
  });
  factory BookingModel.fromJson(
    Map<String, dynamic> json, {
    bool setOtherCharge = false,
  }) => BookingModel(
    bookingId: parseValue<int>(json, "BookingId"),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    applicantName: parseValue<String>(json, "ApplicantName"),
    bookingApplicantData:
        (json["BookingApplicantData"] as List<dynamic>)
            .map(
              (e) => BookingApplicantData.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
    applicantMobileNumberCountryCode: parseValue<String>(
      json,
      "ApplicantMobileNumberCountryCode",
    ),
    applicantMobileNumber: parseValue<String>(json, "ApplicantMobileNumber"),
    permanentAddress: parseValue<String>(json, "PermanentAddress"),
    communicationAddress: parseValue<String>(json, "CommunicationAddress"),
    source: parseValue<String>(json, "Source"),
    subSource: parseValue<String>(json, "SubSource"),
    channelPartnerName: parseValue<String>(json, "ChannelPartnerName"),
    channelPartnerCompany: parseValue<String>(json, "ChannelPartnerCompany"),
    channelPartnerMobileNumber: parseValue<String>(
      json,
      "ChannelPartnerMobileNumber",
    ),
    inventoryFlatFloorBasementPodiumWingId: parseValue<int>(
      json,
      "InventoryFlatFloorBasementPodiumWingId",
    ),
    inventoryBuildingId: parseValue<int>(json, "InventoryBuildingId"),
    paymentScheduleSchemeMasterId: parseValue<int>(
      json,
      "PaymentScheduleSchemeMasterId",
    ),
    paymentScheduleScheme: parseValue<String>(json, "PaymentScheduleScheme"),
    paymentRemark: parseValue<String>(json, "PaymentRemark"),
    otherRemark: parseValue<String>(json, "OtherRemark"),
    sourceOfFunding: parseValue<String>(json, "SourceOfFunding"),
    transferBookingId: parseValue<int>(json, "TransferBookingId"),
    transferFlat: parseValue<String>(json, "TransferFlat"),
    tenantId: parseValue<int>(json, "TenantId"),
    brokeragePercentage: parseValue<double>(json, "BrokeragePercentage"),
    brokerageAmount: parseValue<double>(json, "BrokerageAmount"),
    referelPercentage: parseValue<double>(json, "ReferelPercentage"),
    referelAmount: parseValue<double>(json, "ReferelAmount"),
    loyaltyPercentage: parseValue<double>(json, "LoyaltyPercentage"),
    loyaltyAmount: parseValue<double>(json, "LoyaltyAmount"),
    employeeReferencePercentage: parseValue<double>(
      json,
      "EmployeeReferencePercentage",
    ),
    employeeReferenceAmount: parseValue<double>(
      json,
      "EmployeeReferenceAmount",
    ),
    inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    wing: parseValue<String>(json, "Wing"),
    floor: parseValue<String>(json, "Floor"),
    flat: parseValue<String>(json, "Flat"),
    flatType: parseValue<String>(json, "FlatType"),
    reraCarpetAreaSqFt: parseValue<double>(json, "RERACarpetAreaSqFt"),
    flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
    systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
    agreementValue: parseValue<double>(json, "AgreementValue"),
    agreementValueTDS: parseValue<double>(json, "AgreementValueTDS"),
    agreementValueGSTPercentage: parseValue<double>(
      json,
      "AgreementValueGSTPercentage",
    ),
    agreementValueGSTAmount: parseValue<double>(
      json,
      "AgreementValueGSTAmount",
    ),
    stampDutyPercentage: parseValue<double>(json, "StampDutyPercentage"),
    stampDutyAmount: parseValue<double>(json, "StampDutyAmount"),
    registrationFees: parseValue<double>(json, "RegistrationFees"),
    parkingId: parseValue<String>(json, "ParkingId"),
    parkingNumber: parseValue<String>(json, "ParkingNumber"),
    handoverType: parseValue<String>(json, "HandoverType"),
    registrationDate: parseValue<DateTime>(json, "RegistrationDate"),
    finalRegistrationDate:
        json['FinalRegistrationDate'] != null
            ? parseValue<DateTime>(json, "FinalRegistrationDate")
            : null,
    isFinalRegistrationCompleted: parseValue<bool>(
      json,
      "IsFinalRegistrationCompleted",
    ),
    modeOfPayment: parseValue<String>(json, "ModeOfPayment"),
    bookingAmount: parseValue<double>(json, "BookingAmount"),
    chequeRTGSNumber: parseValue<String>(json, "ChequeRTGSNumber"),
    chequeRTGSDate:
        json["ChequeRTGSDate"] == null
            ? null
            : parseValue<DateTime>(json, "ChequeRTGSDate"),
    bankListMasterId: parseValue<int>(json, "BankListMasterId"),
    bankName: parseValue<String>(json, "BankName"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    bookingType: parseValue<String>(json, "BookingType"),
    isApplicableOtherCharge: parseValue<bool>(json, "IsApplicableOtherCharge"),
    bookingOtherChargesData:
        (json["BookingOtherChargesData"] as List<dynamic>)
            .map(
              (e) =>
                  OtherChargeModel.fromJson(e as Map<String, dynamic>)
                    ..isMaster = setOtherCharge,
            )
            .toList(),
    bookingPaymentScheduleData:
        (json["BookingPaymentScheduleData"] as List<dynamic>)
            .map(
              (e) => BookingPaymentScheduleData.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
    parkingData:
        (json["ParkingData"] as List<dynamic>)
            .map((e) => ParkingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json["ModifiedDate"] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
    projectId: parseValue<int>(json, "ProjectId"),
    enquiryId: parseValue<int>(json, "EnquiryId"),
    projectName: parseValue<String>(json, "ProjectName"),
    flatAlterationRemark: parseValue<String>(json, "FlatAlterationRemark"),
    termsAndConditionsDescription: parseValue<String>(
      json,
      "TermsAndConditionsDescription",
    ),
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
    bookingApplicantModificationRequestApprovalStatus: parseValue<String>(
      json,
      "BookingApplicantModificationRequestApprovalStatus",
    ),
    numberOfParking: parseValue<int>(json, "NumberOfParking"),
    applicantMobileNumberCountryCode: parseValue<String>(
      json,
      "ApplicantMobileNumberCountryCode",
    ),
    applicantMobileNumber: parseValue<String>(json, "ApplicantMobileNumber"),
    channelPartnerMobileNumberCountryCode: parseValue<String>(
      json,
      "ChannelPartnerMobileNumberCountryCode",
    ),
    referralPercentage: parseValue<double>(json, "ReferralPercentage"),
    referralAmount: parseValue<double>(json, "ReferralAmount"),
    finalRegistrationUrl: parseValue<String>(json, "FinalRegistrationURL"),
    agreementValueTds: parseValue<double>(json, "AgreementValueTDS"),
    agreementValueGstPercentage: parseValue<double>(
      json,
      "AgreementValueGSTPercentage",
    ),
    agreementValueGstAmount: parseValue<double>(
      json,
      "AgreementValueGSTAmount",
    ),
    chequeRtgsNumber: parseValue<String>(json, "ChequeRTGSNumber"),
    chequeRtgsDate:
        json["ChequeRTGSDate"] == null
            ? null
            : parseValue<DateTime>(json, "ChequeRTGSDate"),
    cancelledById: parseValue<int>(json, "CancelledById"),
    cancelledBy: parseValue<String>(json, "CancelledBy"),
    cancelledDate:
        json["CancelledDate"] == null
            ? null
            : parseValue<DateTime>(json, "CancelledDate"),
    cancelRemark: parseValue<String>(json, "CancelRemark"),
    proofOfDocumentUrl: parseValue<String>(json, "ProofOfDocumentURL"),
    cancelBookingApprovalStatus: parseValue<String>(
      json,
      "CancelBookingApprovalStatus",
    ),
    refundedPaymentLedgerCount: parseValue<int>(
      json,
      "RefundedPaymentLedgerCount",
    ),
  );

  Map<String, dynamic> toJson() => {
    "BookingId": bookingId,
    "Uniquekey": uniquekey,
    "ApplicantName": applicantName,
    "ApplicantMobileNumber": applicantMobileNumber,
    "ApplicantMobileNumberCountryCode": applicantMobileNumberCountryCode,
    "BookingApplicantData":
        bookingApplicantData.map((e) => e.toJson()).toList(),
    "PermanentAddress": permanentAddress,
    "CommunicationAddress": communicationAddress,
    "Source": source,
    "SubSource": subSource,
    "ChannelPartnerName": channelPartnerName,
    "ChannelPartnerCompany": channelPartnerCompany,
    "ChannelPartnerMobileNumber": channelPartnerMobileNumber,
    "BrokeragePercentage": brokeragePercentage,
    "BrokerageAmount": brokerageAmount,
    "ReferelPercentage": referelPercentage,
    "ReferelAmount": referelAmount,
    "LoyaltyPercentage": loyaltyPercentage,
    "LoyaltyAmount": loyaltyAmount,
    "EmployeeReferencePercentage": employeeReferencePercentage,
    "EmployeeReferenceAmount": employeeReferenceAmount,
    "InventoryFlatId": inventoryFlatId,
    "BuildingNumber": buildingNumber,
    "Wing": wing,
    "Floor": floor,
    "Flat": flat,
    "FlatType": flatType,
    "InventoryFlatFloorBasementPodiumWingId":
        inventoryFlatFloorBasementPodiumWingId,
    "InventoryBuildingId": inventoryBuildingId,
    "PaymentScheduleSchemeMasterId": paymentScheduleSchemeMasterId,
    "PaymentScheduleScheme": paymentScheduleScheme,
    "PaymentRemark": paymentRemark,
    "OtherRemark": otherRemark,
    "SourceOfFunding": sourceOfFunding,
    "TransferBookingId": transferBookingId,
    "TransferFlat": transferFlat,
    "TenantId": tenantId,
    "RERACarpetAreaSqFt": reraCarpetAreaSqFt,
    "FlatConfiguration": flatConfiguration,
    "AgreementValue": agreementValue,
    "AgreementValueTDS": agreementValueTDS,
    "AgreementValueGSTPercentage": agreementValueGSTPercentage,
    "AgreementValueGSTAmount": agreementValueGSTAmount,
    "StampDutyPercentage": stampDutyPercentage,
    "StampDutyAmount": stampDutyAmount,
    "RegistrationFees": registrationFees,
    "ParkingId": parkingId,
    "ParkingNumber": parkingNumber,
    "HandoverType": handoverType,
    "RegistrationDate": registrationDate.toIso8601String(),
    "ModeOfPayment": modeOfPayment,
    "BookingAmount": bookingAmount,
    "ChequeRTGSNumber": chequeRTGSNumber,
    "ChequeRTGSDate": chequeRTGSDate?.toIso8601String(),
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "ApprovalStatus": approvalStatus,
    "IsApproval": isApproval,
    "BookingType": bookingType,
    "IsApplicableOtherCharge": isApplicableOtherCharge.toString(),
    "BookingOtherChargesData":
        bookingOtherChargesData.map((e) => e.toJson()).toList(),
    "BookingPaymentScheduleData":
        bookingPaymentScheduleData.map((e) => e.toJson()).toList(),
    "ParkingData": parkingData.map((e) => e.toJson()).toList(),
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "ProjectId": projectId,
    "EnquiryId": enquiryId,
    "ProjectName": projectName,
    "SystemGeneratedCode": systemGeneratedCode,
    "FlatAlterationRemark": flatAlterationRemark,
    "TermsAndConditionsDescription": termsAndConditionsDescription,
    "TotalAmountReceivedAgainstBooking": totalAmountReceivedAgainstBooking,
    "TotalAmountRefundedAgainstBooking": totalAmountRefundedAgainstBooking,
    "RefundedAmountOnTillDate": refundedAmountOnTillDate,
    "FlatAlterationRequestIsApproval": flatAlterationRequestIsApproval,
    "FlatAlterationRequestApprovalStatus": flatAlterationRequestApprovalStatus,
    "ParkingModificationRequestIsApproval":
        parkingModificationRequestIsApproval,
    "ParkingModificationRequestApprovalStatus":
        parkingModificationRequestApprovalStatus,
    "BookingApplicantModificationRequestIsApproval":
        bookingApplicantModificationRequestIsApproval,
    "BookingApplicantModificationRequestApprovalStatus":
        bookingApplicantModificationRequestApprovalStatus,
    "NumberOfParking": numberOfParking,
    "FinalRegistrationDate": finalRegistrationDate?.toIso8601String(),
    "IsFinalRegistrationCompleted": isFinalRegistrationCompleted,
    "ApplicantMobileNumberCountryCode": applicantMobileNumberCountryCode,
    "ApplicantMobileNumber": applicantMobileNumber,
    "ChannelPartnerMobileNumberCountryCode":
        channelPartnerMobileNumberCountryCode,
    "ReferralPercentage": referralPercentage,
    "ReferralAmount": referralAmount,
    "FinalRegistrationURL": finalRegistrationUrl,
    "CancelledById": cancelledById,
    "CancelledBy": cancelledBy,
    "CancelledDate": cancelledDate?.toIso8601String(),
    "CancelRemark": cancelRemark,
    "ProofOfDocumentURL": proofOfDocumentUrl,
    "CancelBookingApprovalStatus": cancelBookingApprovalStatus,
    "RefundedPaymentLedgerCount": refundedPaymentLedgerCount,
  };
}

class BookingApplicantData {
  int bookingApplicantId;
  String applicantType;
  String applicantName;
  String applicantMobileNumber;
  String applicantMobileNumberCountryCode;
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
  String cancelledChequeUrl;
  String poaurl;
  String incomeForm16Itrurl;
  String nreNroBankDetailsUrl;
  String nomineeFormUrl;
  String statementOfSourceOfFundsURL;
  String paymentProofURL;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  // APPLICANT DETAIL DOCUMENT VARIABLES
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
  MultiFilePickerModel cancelledChequeImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel poaImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel incomeForm16ItrImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel nreNroBankDetailsImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel nomineeFormImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel statementOfSourceOfFundImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel paymentProofImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  BookingApplicantData({
    required this.bookingApplicantId,
    required this.applicantType,
    required this.applicantName,
    required this.applicantMobileNumber,
    required this.applicantMobileNumberCountryCode,
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
    required this.cancelledChequeUrl,
    required this.poaurl,
    required this.incomeForm16Itrurl,
    required this.nreNroBankDetailsUrl,
    required this.nomineeFormUrl,
    required this.statementOfSourceOfFundsURL,
    required this.paymentProofURL,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BookingApplicantData.fromJson(Map<String, dynamic> json) =>
      BookingApplicantData(
        bookingApplicantId: parseValue<int>(json, "BookingApplicantId"),
        applicantType: parseValue<String>(json, "ApplicantType"),
        applicantName: parseValue<String>(json, "ApplicantName"),
        applicantMobileNumberCountryCode: parseValue<String>(
          json,
          "ApplicantMobileNumberCountryCode",
        ),
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
        nomineeFormUrl: parseValue<String>(json, "NomineeFormURL"),
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

  Map<String, dynamic> toJson() => {
    "BookingApplicantId": bookingApplicantId,
    "ApplicantType": applicantType,
    "ApplicantName": applicantName,
    "ApplicantMobileNumber": applicantMobileNumber,
    "ApplicantMobileNumberCountryCode": applicantMobileNumberCountryCode,
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
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };

  BookingApplicantData copyWith({
    int? bookingApplicantId,
    String? applicantType,
    String? applicantName,
    String? applicantMobileNumber,
    String? applicantMobileNumberCountryCode,
    String? applicantEmailId,
    String? photoURL,
    String? aadharCardNumber,
    String? aadharCardURL,
    String? panNumber,
    String? panCardURL,
    String? passportNumber,
    String? passportURL,
    String? drivingLicenseNumber,
    String? drivingLicenseURL,
    String? votingIdNumber,
    String? votingIdURL,
    String? gstNumber,
    String? gstNumberURL,
    String? cancelledChequeUrl,
    String? poaurl,
    String? incomeForm16Itrurl,
    String? nreNroBankDetailsUrl,
    String? nomineeFormUrl,
    String? statementOfSourceOfFundsURL,
    String? paymentProofURL,
    int? createdById,
    String? createdBy,
    DateTime? createdDate,
    int? modifiedById,
    String? modifiedBy,
    DateTime? modifiedDate,
  }) {
    return BookingApplicantData(
      bookingApplicantId: bookingApplicantId ?? this.bookingApplicantId,
      applicantType: applicantType ?? this.applicantType,
      applicantName: applicantName ?? this.applicantName,
      applicantMobileNumber:
          applicantMobileNumber ?? this.applicantMobileNumber,
      applicantMobileNumberCountryCode:
          applicantMobileNumberCountryCode ??
          this.applicantMobileNumberCountryCode,
      applicantEmailId: applicantEmailId ?? this.applicantEmailId,
      photoURL: photoURL ?? this.photoURL,
      aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
      aadharCardURL: aadharCardURL ?? this.aadharCardURL,
      panNumber: panNumber ?? this.panNumber,
      panCardURL: panCardURL ?? this.panCardURL,
      passportNumber: passportNumber ?? this.passportNumber,
      passportURL: passportURL ?? this.passportURL,
      drivingLicenseNumber: drivingLicenseNumber ?? this.drivingLicenseNumber,
      drivingLicenseURL: drivingLicenseURL ?? this.drivingLicenseURL,
      votingIdNumber: votingIdNumber ?? this.votingIdNumber,
      votingIdURL: votingIdURL ?? this.votingIdURL,
      gstNumber: gstNumber ?? this.gstNumber,
      gstNumberURL: gstNumberURL ?? this.gstNumberURL,
      cancelledChequeUrl: cancelledChequeUrl ?? this.cancelledChequeUrl,
      poaurl: poaurl ?? this.poaurl,
      incomeForm16Itrurl: incomeForm16Itrurl ?? this.incomeForm16Itrurl,
      nreNroBankDetailsUrl: nreNroBankDetailsUrl ?? this.nreNroBankDetailsUrl,
      nomineeFormUrl: nomineeFormUrl ?? this.nomineeFormUrl,
      statementOfSourceOfFundsURL:
          statementOfSourceOfFundsURL ?? this.statementOfSourceOfFundsURL,
      paymentProofURL: paymentProofURL ?? this.paymentProofURL,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }
}
