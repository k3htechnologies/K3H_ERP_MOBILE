import 'package:k3h_erp_app/utils/common_function.dart';

class InwardOutwardModel {
  final int inwardOutwardId;
  final String uniqueKey;
  final String systemGeneratedCode;
  final String deliveryType;
  final String departmentName;
  final String inwardNumber;
  final DateTime inwardOutwardDate;
  final String senderName;
  final String senderAddress;
  final String senderMobileNo;
  final String senderEmailId;
  final String receiverName;
  final String receiverAddress;
  final String receiverMobileNo;
  final String receiverEmailId;
  final String documentUrl;
  final String employeeId;
  final String employeeNames;
  final String documentType;
  final String inVoiceNumber;
  final DateTime? inVoiceDate;
  final String receivedBy;
  final String receiversSignature;
  final String chequeNo;
  final String documentTitle;
  final String priority;
  final int amount;
  final String deliveryMode;
  final String deliveryStatus;
  final String documentDescription;
  final String handOverTo;
  final DateTime? handOverDate;
  final String acknowledgementRemark;
  final String acknowledgementUrl;
  final List<dynamic> inwardOutwardRevertHistory;
  final List<dynamic> inwardOutwardDocumentHistory;
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
    required this.inwardNumber,
    required this.inwardOutwardDate,
    required this.senderName,
    required this.senderAddress,
    required this.senderMobileNo,
    required this.senderEmailId,
    required this.receiverName,
    required this.receiverAddress,
    required this.receiverMobileNo,
    required this.receiverEmailId,
    required this.documentUrl,
    required this.employeeId,
    required this.employeeNames,
    required this.documentType,
    required this.inVoiceNumber,
    required this.inVoiceDate,
    required this.receivedBy,
    required this.receiversSignature,
    required this.chequeNo,
    required this.documentTitle,
    required this.priority,
    required this.amount,
    required this.deliveryMode,
    required this.deliveryStatus,
    required this.documentDescription,
    required this.handOverTo,
    required this.handOverDate,
    required this.acknowledgementRemark,
    required this.acknowledgementUrl,
    required this.inwardOutwardRevertHistory,
    required this.inwardOutwardDocumentHistory,
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
      inwardNumber: parseValue<String>(json, "InwardNumber"),
      inwardOutwardDate: parseValue<DateTime>(json, "InwardOutwardDate"),
      senderName: parseValue<String>(json, "SenderName"),
      senderAddress: parseValue<String>(json, "SenderAddress"),
      senderMobileNo: parseValue<String>(json, "SenderMobileNo"),
      senderEmailId: parseValue<String>(json, "SenderEmailId"),
      receiverName: parseValue<String>(json, "ReceiverName"),
      receiverAddress: parseValue<String>(json, "ReceiverAddress"),
      receiverMobileNo: parseValue<String>(json, "ReceiverMobileNo"),
      receiverEmailId: parseValue<String>(json, "ReceiverEmailId"),
      documentUrl: parseValue<String>(json, "DocumentURL"),
      employeeId: parseValue<String>(json, "EmployeeId"),
      employeeNames: parseValue<String>(json, "EmployeeNames"),
      documentType: parseValue<String>(json, "DocumentType"),
      inVoiceNumber: parseValue<String>(json, "InVoiceNumber"),
      inVoiceDate:
          json["InVoiceDate"] == null
              ? null
              : parseValue<DateTime>(json, "InVoiceDate"),
      receivedBy: parseValue<String>(json, "ReceivedBy"),
      receiversSignature: parseValue<String>(json, "ReceiversSignature"),
      chequeNo: parseValue<String>(json, "ChequeNo"),
      documentTitle: parseValue<String>(json, "DocumentTitle"),
      priority: parseValue<String>(json, "Priority"),
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
      acknowledgementUrl: parseValue<String>(json, "AcknowledgementURL"),
      inwardOutwardRevertHistory: json["InwardOutwardRevertHistory"] ?? [],
      inwardOutwardDocumentHistory: json["InwardOutwardDocumentHistory"] ?? [],
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
      "InwardNumber": inwardNumber,
      "InwardOutwardDate": inwardOutwardDate.toIso8601String(),
      "SenderName": senderName,
      "SenderAddress": senderAddress,
      "SenderMobileNo": senderMobileNo,
      "SenderEmailId": senderEmailId,
      "ReceiverName": receiverName,
      "ReceiverAddress": receiverAddress,
      "ReceiverMobileNo": receiverMobileNo,
      "ReceiverEmailId": receiverEmailId,
      "DocumentURL": documentUrl,
      "EmployeeId": employeeId,
      "EmployeeNames": employeeNames,
      "DocumentType": documentType,
      "InVoiceNumber": inVoiceNumber,
      "InVoiceDate": inVoiceDate?.toIso8601String(),
      "ReceivedBy": receivedBy,
      "ReceiversSignature": receiversSignature,
      "ChequeNo": chequeNo,
      "DocumentTitle": documentTitle,
      "Priority": priority,
      "Amount": amount,
      "DeliveryMode": deliveryMode,
      "DeliveryStatus": deliveryStatus,
      "DocumentDescription": documentDescription,
      "HandOverTo": handOverTo,
      "HandOverDate": handOverDate?.toIso8601String(),
      "AcknowledgementRemark": acknowledgementRemark,
      "AcknowledgementURL": acknowledgementUrl,
      "InwardOutwardRevertHistory": inwardOutwardRevertHistory,
      "InwardOutwardDocumentHistory": inwardOutwardDocumentHistory,
      "CreatedById": createdById,
      "CreatedBy": createdBy,
      "CreatedDate": createdDate.toIso8601String(),
      "ModifiedById": modifiedById,
      "ModifiedBy": modifiedBy,
      "ModifiedDate": modifiedDate?.toIso8601String(),
    };
  }
}
