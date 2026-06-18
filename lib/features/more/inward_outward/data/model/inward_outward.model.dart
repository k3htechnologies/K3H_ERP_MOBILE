import 'package:k3h_erp_app/utils/common_function.dart';

class InwardOutwardModel {
  final int inwardOutwardId;
  final String uniqueKey;
  final String systemGeneratedCode;
  final String deliveryType;
  final String departmentName;
  final DateTime inwardOutwardDate;
  final String senderName;
  final String senderAddress;
  final String senderMobileNumberCountryCode;
  final String senderMobileNumber;
  final String senderEmailId;
  final String receiverName;
  final String receiverAddress;
  final String receiverMobileNumberCountryCode;
  final String receiverMobileNumber;
  final String receiverEmailId;
  final String documentURL;
  final String employeeId;
  final String employeeNames;
  final String documentType;
  final String invoiceNumber;
  final DateTime? invoiceDate;
  final String acknowledgementBy;
  final String acknowledgementSignatureURL;
  final String chequeNumber;
  final String documentTitle;
  final int amount;
  final String deliveryMode;
  final String deliveryStatus;
  final String documentDescription;
  final String handOverTo;
  final DateTime? handOverDate;
  final String acknowledgementRemark;
  final String acknowledgementURL;
  final List<InwardOutwardRevertHistoryModel> inwardOutwardRevertHistory;
  final int createdById;
  final String createdBy;
  final DateTime createdDate;
  final int modifiedById;
  final String modifiedBy;
  final DateTime? modifiedDate;

  const InwardOutwardModel({
    required this.inwardOutwardId,
    required this.uniqueKey,
    required this.systemGeneratedCode,
    required this.deliveryType,
    required this.departmentName,
    required this.inwardOutwardDate,
    required this.senderName,
    required this.senderAddress,
    required this.senderMobileNumber,
    required this.senderMobileNumberCountryCode,
    required this.senderEmailId,
    required this.receiverName,
    required this.receiverAddress,
    required this.receiverMobileNumberCountryCode,
    required this.receiverMobileNumber,
    required this.receiverEmailId,
    required this.documentURL,
    required this.employeeId,
    required this.employeeNames,
    required this.documentType,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.acknowledgementBy,
    required this.acknowledgementSignatureURL,
    required this.chequeNumber,
    required this.documentTitle,
    required this.amount,
    required this.deliveryMode,
    required this.deliveryStatus,
    required this.documentDescription,
    required this.handOverTo,
    required this.handOverDate,
    required this.acknowledgementRemark,
    required this.acknowledgementURL,
    required this.inwardOutwardRevertHistory,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    this.modifiedDate,
  });

  factory InwardOutwardModel.fromJson(Map<String, dynamic> json) {
    return InwardOutwardModel(
      inwardOutwardId: parseValue<int>(json, "InwardOutwardId"),
      uniqueKey: parseValue<String>(json, "UniqueKey"),
      systemGeneratedCode: parseValue<String>(json, "SystemGeneratedCode"),
      deliveryType: parseValue<String>(json, "DeliveryType"),
      departmentName: parseValue<String>(json, "DepartmentName"),
      inwardOutwardDate: parseValue<DateTime>(json, "InwardOutwardDate"),
      senderName: parseValue<String>(json, "SenderName"),
      senderAddress: parseValue<String>(json, "SenderAddress"),
      senderMobileNumberCountryCode: parseValue<String>(
        json,
        "SenderMobileNumberCountryCode",
      ),
      senderMobileNumber: parseValue<String>(json, "SenderMobileNumber"),
      senderEmailId: parseValue<String>(json, "SenderEmailId"),
      receiverName: parseValue<String>(json, "ReceiverName"),
      receiverAddress: parseValue<String>(json, "ReceiverAddress"),
      receiverMobileNumber: parseValue<String>(json, "ReceiverMobileNumber"),
      receiverMobileNumberCountryCode: parseValue<String>(
        json,
        "ReceiverMobileNumberCountryCode",
      ),
      receiverEmailId: parseValue<String>(json, "ReceiverEmailId"),
      documentURL: parseValue<String>(json, "DocumentURL"),
      employeeId: parseValue<String>(json, "EmployeeId"),
      employeeNames: parseValue<String>(json, "EmployeeNames"),
      documentType: parseValue<String>(json, "DocumentType"),
      invoiceNumber: parseValue<String>(json, "InvoiceNumber"),
      invoiceDate:
          json["InvoiceDate"] == null
              ? null
              : parseValue<DateTime>(json, "InvoiceDate"),
      acknowledgementBy: parseValue<String>(json, "AcknowledgementBy"),
      acknowledgementSignatureURL: parseValue<String>(
        json,
        "AcknowledgementSignatureURL",
      ),
      chequeNumber: parseValue<String>(json, "ChequeNumber"),
      documentTitle: parseValue<String>(json, "DocumentTitle"),
      amount: parseValue<int>(json, "Amount"),
      deliveryMode: parseValue<String>(json, "DeliveryMode"),
      deliveryStatus: parseValue<String>(json, "DeliveryStatus"),
      documentDescription: parseValue<String>(json, "DocumentDescription"),
      handOverTo: parseValue<String>(json, "HandOverTo"),
      handOverDate:
          json["HandOverDate"] == null
              ? null
              : parseValue<DateTime>(json, "HandOverDate"),
      acknowledgementRemark: parseValue<String>(json, "AcknowledgementRemark"),
      acknowledgementURL: parseValue<String>(json, "AcknowledgementURL"),
      inwardOutwardRevertHistory: List<InwardOutwardRevertHistoryModel>.from(
        (json["InwardOutwardRevertHistory"] ?? []).map(
          (x) => InwardOutwardRevertHistoryModel.fromJson(x),
        ),
      ),

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
  }

  Map<String, dynamic> toJson() {
    return {
      "InwardOutwardId": inwardOutwardId,
      "UniqueKey": uniqueKey,
      "SystemGeneratedCode": systemGeneratedCode,
      "DeliveryType": deliveryType,
      "DepartmentName": departmentName,
      "InwardOutwardDate": inwardOutwardDate.toIso8601String(),
      "SenderName": senderName,
      "SenderAddress": senderAddress,
      "SenderMobileNumber": senderMobileNumber,
      "SenderMobileNumberCountryCode": senderMobileNumberCountryCode,
      "SenderEmailId": senderEmailId,
      "ReceiverName": receiverName,
      "ReceiverAddress": receiverAddress,
      "ReceiverMobileNumber": receiverMobileNumber,
      "ReceiverMobileNumberCountryCode": receiverMobileNumberCountryCode,
      "ReceiverEmailId": receiverEmailId,
      "DocumentURL": documentURL,
      "EmployeeId": employeeId,
      "EmployeeNames": employeeNames,
      "DocumentType": documentType,
      "InvoiceNumber": invoiceNumber,
      "InvoiceDate": invoiceDate?.toIso8601String(),
      "AcknowledgementBy": acknowledgementBy,
      "AcknowledgementSignatureURL": acknowledgementSignatureURL,
      "ChequeNumber": chequeNumber,
      "DocumentTitle": documentTitle,
      "Amount": amount,
      "DeliveryMode": deliveryMode,
      "DeliveryStatus": deliveryStatus,
      "DocumentDescription": documentDescription,
      "HandOverTo": handOverTo,
      "HandOverDate": handOverDate?.toIso8601String(),
      "AcknowledgementRemark": acknowledgementRemark,
      "AcknowledgementURL": acknowledgementURL,
      "InwardOutwardRevertHistory": List<dynamic>.from(
        inwardOutwardRevertHistory.map((x) => x.toJson()),
      ),

      "CreatedById": createdById,
      "CreatedBy": createdBy,
      "CreatedDate": createdDate.toIso8601String(),
      "ModifiedById": modifiedById,
      "ModifiedBy": modifiedBy,
      "ModifiedDate": modifiedDate?.toIso8601String(),
    };
  }
}

class InwardOutwardRevertHistoryModel {
  final int inwardOutwardRevertId;
  final int inwardOutwardId;
  final String uniqueKey;
  final DateTime revertDate;
  final String revertRemark;
  final String revertDocumentURL;

  const InwardOutwardRevertHistoryModel({
    required this.inwardOutwardRevertId,
    required this.inwardOutwardId,
    required this.uniqueKey,
    required this.revertDate,
    required this.revertRemark,
    required this.revertDocumentURL,
  });

  factory InwardOutwardRevertHistoryModel.fromJson(Map<String, dynamic> json) {
    return InwardOutwardRevertHistoryModel(
      inwardOutwardRevertId: parseValue<int>(json, "InwardOutwardRevertId"),
      inwardOutwardId: parseValue<int>(json, "InwardOutwardId"),
      uniqueKey: parseValue<String>(json, "UniqueKey"),
      revertDate: parseValue<DateTime>(json, "RevertDate"),
      revertRemark: parseValue<String>(json, "RevertRemark"),
      revertDocumentURL: parseValue<String>(json, "RevertDocumentURL"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "InwardOutwardRevertId": inwardOutwardRevertId,
      "InwardOutwardId": inwardOutwardId,
      "UniqueKey": uniqueKey,
      "RevertDate": revertDate.toIso8601String(),
      "RevertRemark": revertRemark,
      "RevertDocumentURL": revertDocumentURL,
    };
  }
}
