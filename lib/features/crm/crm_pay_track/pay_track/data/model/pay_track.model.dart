import 'package:k3h_erp_app/utils/common_function.dart';

class PayTrackModel {
  int bookingId;
  String projectName;
  int projectId;
  int enquiryId;
  String systemGeneratedCode;
  String applicantName;
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
  int agreementValue;
  int receivedAgreementValue;
  double agreementValueGstAmount;
  int receivedAgreementValueGstAmount;
  double stampDutyAmount;
  int receivedStampDutyAmount;
  double registrationFees;
  int receivedRegistrationFees;
  double agreementValueTds;
  int receivedAgreementValueTds;
  int otherChargesAmount;
  int receivedOtherChargesAmount;
  int otherChargesGstAmount;
  int receivedOtherChargesGstAmount;
  String approvalStatus;
  int totalAmountReceivedAgainstBooking;
  int totalAmountRefundedAgainstBooking;
  int refundedAmountOnTillDate;
  bool flatAlterationRequestIsApproval;
  String flatAlterationRequestApprovalStatus;
  bool parkingModificationRequestIsApproval;
  String parkingModificationRequestApprovalStatus;
  bool bookingApplicantModificationRequestIsApproval;
  String bookingApplicantModificationRequestApprovalStatus;
  int tenantId;

  PayTrackModel({
    required this.bookingId,
    required this.projectName,
    required this.projectId,
    required this.enquiryId,
    required this.systemGeneratedCode,
    required this.applicantName,
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
    agreementValue: parseValue<int>(json, "AgreementValue"),
    receivedAgreementValue: parseValue<int>(json, "ReceivedAgreementValue"),
    agreementValueGstAmount: parseValue<double>(
      json,
      "AgreementValueGstAmount",
    ),
    receivedAgreementValueGstAmount: parseValue<int>(
      json,
      "ReceivedAgreementValueGstAmount",
    ),
    stampDutyAmount: parseValue<double>(json, "StampDutyAmount"),
    receivedStampDutyAmount: parseValue<int>(json, "ReceivedStampDutyAmount"),
    registrationFees: parseValue<double>(json, "RegistrationFees"),
    receivedRegistrationFees: parseValue<int>(json, "ReceivedRegistrationFees"),
    agreementValueTds: parseValue<double>(json, "AgreementValueTds"),
    receivedAgreementValueTds: parseValue<int>(
      json,
      "ReceivedAgreementValueTds",
    ),
    otherChargesAmount: parseValue<int>(json, "OtherChargesAmount"),
    receivedOtherChargesAmount: parseValue<int>(
      json,
      "ReceivedOtherChargesAmount",
    ),
    otherChargesGstAmount: parseValue<int>(json, "OtherChargesGstAmount"),
    receivedOtherChargesGstAmount: parseValue<int>(
      json,
      "ReceivedOtherChargesGstAmount",
    ),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    totalAmountReceivedAgainstBooking: parseValue<int>(
      json,
      "TotalAmountReceivedAgainstBooking",
    ),
    totalAmountRefundedAgainstBooking: parseValue<int>(
      json,
      "TotalAmountRefundedAgainstBooking",
    ),
    refundedAmountOnTillDate: parseValue<int>(json, "RefundedAmountOnTillDate"),
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
    tenantId: parseValue<int>(json, "TenantId"),
  );

  Map<String, dynamic> toJson() => {
    "BookingId": bookingId,
    "ProjectName": projectName,
    "ProjectId": projectId,
    "EnquiryId": enquiryId,
    "SystemGeneratedCode": systemGeneratedCode,
    "ApplicantName": applicantName,
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
    "AgreementValue": agreementValue,
    "ReceivedAgreementValue": receivedAgreementValue,
    "AgreementValueGstAmount": agreementValueGstAmount,
    "ReceivedAgreementValueGstAmount": receivedAgreementValueGstAmount,
    "StampDutyAmount": stampDutyAmount,
    "ReceivedStampDutyAmount": receivedStampDutyAmount,
    "RegistrationFees": registrationFees,
    "ReceivedRegistrationFees": receivedRegistrationFees,
    "AgreementValueTds": agreementValueTds,
    "ReceivedAgreementValueTds": receivedAgreementValueTds,
    "OtherChargesAmount": otherChargesAmount,
    "ReceivedOtherChargesAmount": receivedOtherChargesAmount,
    "OtherChargesGstAmount": otherChargesGstAmount,
    "ReceivedOtherChargesGstAmount": receivedOtherChargesGstAmount,
    "ApprovalStatus": approvalStatus,
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
    "TenantId": tenantId,
  };
}
