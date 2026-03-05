import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

class BookingModel {
  int bookingId;
  String uniquekey;
  String applicantName;
  List<BookingApplicantData> bookingApplicantData;
  String permanentAddress;
  String communicationAddress;
  String source;
  String subSource;
  String channelPartnerName;
  String channelPartnerCompany;
  String channelPartnerMobileNumber;
  double brokeragePercentage;
  double brokerageAmount;
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
  String modeOfPayment;
  double bookingAmount;
  String chequeRTGSNumber;
  DateTime chequeRTGSDate;
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

  BookingModel({
    required this.bookingId,
    required this.uniquekey,
    required this.applicantName,
    required this.bookingApplicantData,
    required this.permanentAddress,
    required this.communicationAddress,
    required this.source,
    required this.subSource,
    required this.channelPartnerName,
    required this.channelPartnerCompany,
    required this.channelPartnerMobileNumber,
    required this.brokeragePercentage,
    required this.brokerageAmount,
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
    brokeragePercentage: parseValue<double>(json, "BrokeragePercentage"),
    brokerageAmount: parseValue<double>(json, "BrokerageAmount"),
    inventoryFlatId: parseValue<int>(json, "InventoryFlatId"),
    buildingNumber: parseValue<String>(json, "BuildingNumber"),
    wing: parseValue<String>(json, "Wing"),
    floor: parseValue<String>(json, "Floor"),
    flat: parseValue<String>(json, "Flat"),
    flatType: parseValue<String>(json, "FlatType"),
    reraCarpetAreaSqFt: parseValue<double>(json, "RERACarpetAreaSqFt"),
    flatConfiguration: parseValue<String>(json, "FlatConfiguration"),
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
    modeOfPayment: parseValue<String>(json, "ModeOfPayment"),
    bookingAmount: parseValue<double>(json, "BookingAmount"),
    chequeRTGSNumber: parseValue<String>(json, "ChequeRTGSNumber"),
    chequeRTGSDate: parseValue<DateTime>(json, "ChequeRTGSDate"),
    bankListMasterId: parseValue<int>(json, "BankListMasterId"),
    bankName: parseValue<String>(json, "BankName"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    bookingType: parseValue<String>(json, "BookingType"),
    bookingOtherChargesData:
        (json["BookingOtherChargesData"] as List<dynamic>)
            .map(
              (e) =>
                  OtherChargeModel.fromJson(e as Map<String, dynamic>)
                    ..isSelected = setOtherCharge
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
  );

  Map<String, dynamic> toJson() => {
    "BookingId": bookingId,
    "Uniquekey": uniquekey,
    "ApplicantName": applicantName,
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
    "InventoryFlatId": inventoryFlatId,
    "BuildingNumber": buildingNumber,
    "Wing": wing,
    "Floor": floor,
    "Flat": flat,
    "FlatType": flatType,
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
    "ChequeRTGSDate": chequeRTGSDate.toIso8601String(),
    "BankListMasterId": bankListMasterId,
    "BankName": bankName,
    "ApprovalStatus": approvalStatus,
    "IsApproval": isApproval,
    "BookingType": bookingType,
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
  };
}

class BookingApplicantData {
  int bookingApplicantId;
  String applicantType;
  String applicantName;
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
  BookingApplicantData({
    required this.bookingApplicantId,
    required this.applicantType,
    required this.applicantName,
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
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
  };
}

class BookingPaymentScheduleData {
  int bookingPaymentScheduleId;
  String type;
  String name;
  DateTime? date;
  double paymentSchedulePercentage;
  double paymentCummulativePercentage;
  double paymentScheduleAmount;
  double paymentScheduleGSTAmount;
  double paymentScheduleTDSAmount;
  int ranking;
  BookingPaymentScheduleData({
    required this.bookingPaymentScheduleId,
    required this.type,
    required this.name,
    this.date,
    required this.paymentSchedulePercentage,
    required this.paymentCummulativePercentage,
    required this.paymentScheduleAmount,
    required this.paymentScheduleGSTAmount,
    required this.paymentScheduleTDSAmount,
    required this.ranking,
  });

  factory BookingPaymentScheduleData.fromJson(
    Map<String, dynamic> json,
  ) => BookingPaymentScheduleData(
    bookingPaymentScheduleId: parseValue<int>(json, "BookingPaymentScheduleId"),
    type: parseValue<String>(json, "Type"),
    name: parseValue<String>(json, "Name"),
    date: json["Date"] == null ? null : parseValue<DateTime>(json, "Date"),
    paymentSchedulePercentage: parseValue<double>(
      json,
      "PaymentSchedulePercentage",
    ),
    paymentCummulativePercentage: parseValue<double>(
      json,
      "PaymentCummulativePercentage",
    ),
    paymentScheduleAmount: parseValue<double>(json, "PaymentScheduleAmount"),
    paymentScheduleGSTAmount: parseValue<double>(
      json,
      "PaymentScheduleGSTAmount",
    ),
    paymentScheduleTDSAmount: parseValue<double>(
      json,
      "PaymentScheduleTDSAmount",
    ),
    ranking: parseValue<int>(json, "Ranking"),
  );

  Map<String, dynamic> toJson() => {
    "BookingPaymentScheduleId": bookingPaymentScheduleId,
    "Type": type,
    "Name": name,
    "Date": date?.toIso8601String(),
    "PaymentSchedulePercentage": paymentSchedulePercentage,
    "PaymentCummulativePercentage": paymentCummulativePercentage,
    "PaymentScheduleAmount": paymentScheduleAmount,
    "PaymentScheduleGSTAmount": paymentScheduleGSTAmount,
    "PaymentScheduleTDSAmount": paymentScheduleTDSAmount,
    "Ranking": ranking,
  };
}
