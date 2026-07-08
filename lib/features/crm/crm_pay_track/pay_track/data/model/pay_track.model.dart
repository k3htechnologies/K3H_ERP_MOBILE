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
      "AgreementValueGstAmount",
    ),
    receivedAgreementValueGstAmount: parseValue<double>(
      json,
      "ReceivedAgreementValueGstAmount",
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
    otherChargesGstAmount: parseValue<double>(json, "OtherChargesGstAmount"),
    receivedOtherChargesGstAmount: parseValue<double>(
      json,
      "ReceivedOtherChargesGstAmount",
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
    "AgreementValueGstAmount": agreementValueGstAmount.toDouble(),
    "ReceivedAgreementValueGstAmount":
        receivedAgreementValueGstAmount.toDouble(),
    "StampDutyAmount": stampDutyAmount.toDouble(),
    "ReceivedStampDutyAmount": receivedStampDutyAmount.toDouble(),
    "RegistrationFees": registrationFees.toDouble(),
    "ReceivedRegistrationFees": receivedRegistrationFees.toDouble(),
    "AgreementValueTDS": agreementValueTds.toDouble(),
    "ReceivedAgreementValueTDS": receivedAgreementValueTds.toDouble(),
    "OtherChargesAmount": otherChargesAmount.toDouble(),
    "ReceivedOtherChargesAmount": receivedOtherChargesAmount.toDouble(),
    "OtherChargesGstAmount": otherChargesGstAmount.toDouble(),
    "ReceivedOtherChargesGstAmount": receivedOtherChargesGstAmount.toDouble(),
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
  };
}
