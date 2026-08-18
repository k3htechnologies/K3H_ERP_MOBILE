import 'package:k3h_erp_app/utils/functions/common_function.dart';

class TaxTrackerModel {
  int taxTrackerId;
  String uniquekey;
  String governmentCompliance;
  int companyId;
  String companyName;
  String financialYear;
  String responsiblePersonId;
  String responsiblePerson;
  String noticeType;
  int noticeSectionMasterId;
  String noticeSection;
  String authority;
  String noticeDate;
  String dueDate;
  String noticeStatus;
  List<TaxTrackerDocumentDetails> taxTrackerDocumentDetailsData;
  bool isDelete;
  int createdById;
  String createdBy;
  String createdDate;
  int modifiedById;
  String modifiedBy;
  String? modifiedDate;

  TaxTrackerModel({
    required this.taxTrackerId,
    required this.uniquekey,
    required this.governmentCompliance,
    required this.companyId,
    required this.companyName,
    required this.financialYear,
    required this.responsiblePersonId,
    required this.responsiblePerson,
    required this.noticeType,
    required this.noticeSectionMasterId,
    required this.noticeSection,
    required this.authority,
    required this.noticeDate,
    required this.dueDate,
    required this.noticeStatus,
    required this.taxTrackerDocumentDetailsData,
    required this.isDelete,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TaxTrackerModel.fromJson(Map<String, dynamic> json) =>
      TaxTrackerModel(
        taxTrackerId: parseValue<int>(json, "TaxTrackerId"),
        uniquekey: parseValue<String>(json, "Uniquekey"),
        governmentCompliance: parseValue<String>(json, "GovernmentCompliance"),
        companyId: parseValue<int>(json, "CompanyId"),
        companyName: parseValue<String>(json, "CompanyName"),
        financialYear: parseValue<String>(json, "FinancialYear"),
        responsiblePersonId: parseValue<String>(json, "ResponsiblePersonId"),
        responsiblePerson: parseValue<String>(json, "ResponsiblePerson"),
        noticeType: parseValue<String>(json, "NoticeType"),
        noticeSectionMasterId: parseValue<int>(json, "NoticeSectionMasterId"),
        noticeSection: parseValue<String>(json, "NoticeSection"),
        authority: parseValue<String>(json, "Authority"),
        noticeDate: parseValue<String>(json, "NoticeDate"),
        dueDate: parseValue<String>(json, "DueDate"),
        noticeStatus: json["NoticeStatus"],
        taxTrackerDocumentDetailsData: List<TaxTrackerDocumentDetails>.from(
          json["TaxTrackerDocumentDetailsData"].map(
            (x) => TaxTrackerDocumentDetails.fromJson(x),
          ),
        ),
        isDelete: json["IsDelete"],
        createdById: json["CreatedById"],
        createdBy: json["CreatedBy"],
        createdDate: json["CreatedDate"],
        modifiedById: json["ModifiedById"],
        modifiedBy: json["ModifiedBy"],
        modifiedDate: json["ModifiedDate"],
      );

  Map<String, dynamic> toJson() => {
    "TaxTrackerId": taxTrackerId,
    "Uniquekey": uniquekey,
    "GovernmentCompliance": governmentCompliance,
    "CompanyId": companyId,
    "CompanyName": companyName,
    "FinancialYear": financialYear,
    "ResponsiblePersonId": responsiblePersonId,
    "ResponsiblePerson": responsiblePerson,
    "NoticeType": noticeType,
    "NoticeSectionMasterId": noticeSectionMasterId,
    "NoticeSection": noticeSection,
    "Authority": authority,
    "NoticeDate": noticeDate,
    "DueDate": dueDate,
    "NoticeStatus": noticeStatus,
    "TaxTrackerDocumentDetailsData": List<dynamic>.from(
      taxTrackerDocumentDetailsData.map((x) => x.toJson()),
    ),
    "IsDelete": isDelete,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}

class TaxTrackerDocumentDetails {
  int taxTrackerDocumentId;
  String uniquekey;
  int taxTrackerId;
  String requestType;
  String authorityType;
  String noticeDocumentUrl;
  String noticeDescription;
  String officerName;
  String officerAddress;
  String? amountUnderDisputeDate;
  int amountUnderDispute;
  String orderStatus;
  String noticeStatus;
  int createdById;
  String createdBy;
  String createdDate;
  int modifiedById;
  String modifiedBy;
  String? modifiedDate;

  TaxTrackerDocumentDetails({
    required this.taxTrackerDocumentId,
    required this.uniquekey,
    required this.taxTrackerId,
    required this.requestType,
    required this.authorityType,
    required this.noticeDocumentUrl,
    required this.noticeDescription,
    required this.officerName,
    required this.officerAddress,
    required this.amountUnderDisputeDate,
    required this.amountUnderDispute,
    required this.orderStatus,
    required this.noticeStatus,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
  });

  factory TaxTrackerDocumentDetails.fromJson(Map<String, dynamic> json) =>
      TaxTrackerDocumentDetails(
        taxTrackerDocumentId: json["TaxTrackerDocumentId"],
        uniquekey: json["Uniquekey"],
        taxTrackerId: json["TaxTrackerId"],
        requestType: json["RequestType"],
        authorityType: json["AuthorityType"],
        noticeDocumentUrl: json["NoticeDocumentURL"],
        noticeDescription: json["NoticeDescription"],
        officerName: json["OfficerName"],
        officerAddress: json["OfficerAddress"],
        amountUnderDisputeDate: json["AmountUnderDisputeDate"],
        amountUnderDispute: json["AmountUnderDispute"],
        orderStatus: json["OrderStatus"],
        noticeStatus: json["NoticeStatus"],
        createdById: json["CreatedById"],
        createdBy: json["CreatedBy"],
        createdDate: json["CreatedDate"],
        modifiedById: json["ModifiedById"],
        modifiedBy: json["ModifiedBy"],
        modifiedDate: json["ModifiedDate"],
      );

  Map<String, dynamic> toJson() => {
    "TaxTrackerDocumentId": taxTrackerDocumentId,
    "Uniquekey": uniquekey,
    "TaxTrackerId": taxTrackerId,
    "RequestType": requestType,
    "AuthorityType": authorityType,
    "NoticeDocumentURL": noticeDocumentUrl,
    "NoticeDescription": noticeDescription,
    "OfficerName": officerName,
    "OfficerAddress": officerAddress,
    "AmountUnderDisputeDate": amountUnderDisputeDate,
    "AmountUnderDispute": amountUnderDispute,
    "OrderStatus": orderStatus,
    "NoticeStatus": noticeStatus,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate,
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
  };
}
