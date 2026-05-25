import 'package:k3h_erp_app/utils/common_function.dart';

class BookingApplicantModificationRequestModel {
  int bookingApplicantModificationRequestId;
  String applicantType;
  String applicantName;
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
  bool isApproval;
  String approvalStatus;
  String versionNumber;
  int createdById;
  String createdBy;
  DateTime? createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;

  BookingApplicantModificationRequestModel({
    required this.bookingApplicantModificationRequestId,
    required this.applicantType,
    required this.applicantName,
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
    required this.isApproval,
    required this.approvalStatus,
    required this.versionNumber,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory BookingApplicantModificationRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => BookingApplicantModificationRequestModel(
    bookingApplicantModificationRequestId: parseValue<int>(
      json,
      "BookingApplicantModificationRequestId",
    ),
    applicantType: parseValue<String>(json, "ApplicantType"),
    applicantName: parseValue<String>(json, "ApplicantName"),
    applicantMobileNumber: parseValue<String>(json, "ApplicantMobileNumber"),
    applicantEmailId: parseValue<String>(json, "ApplicantEmailId"),
    photoUrl: parseValue<String>(json, "PhotoURL"),
    aadharCardNumber: parseValue<String>(json, "AadharCardNumber"),
    aadharCardUrl: parseValue<String>(json, "AadharCardURL"),
    panNumber: parseValue<String>(json, "PanNumber"),
    panCardUrl: parseValue<String>(json, "PanCardURL"),
    passportNumber: parseValue<String>(json, "PassportNumber"),
    passportUrl: parseValue<String>(json, "PassportURL"),
    drivingLicenseNumber: parseValue<String>(json, "DrivingLicenseNumber"),
    drivingLicenseUrl: parseValue<String>(json, "DrivingLicenseURL"),
    votingIdNumber: parseValue<String>(json, "VotingIdNumber"),
    votingIdUrl: parseValue<String>(json, "VotingIdURL"),
    gstNumber: parseValue<String>(json, "GSTNumber"),
    gstNumberUrl: parseValue<String>(json, "GSTNumberURL"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    versionNumber: parseValue<String>(json, "VersionNumber"),
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
  );

  Map<String, dynamic> toJson() => {
    "BookingApplicantModificationRequestId":
        bookingApplicantModificationRequestId,
    "ApplicantType": applicantType,
    "ApplicantName": applicantName,
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
    "IsApproval": isApproval,
    "ApprovalStatus": approvalStatus,
    "VersionNumber": versionNumber,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate?.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}
