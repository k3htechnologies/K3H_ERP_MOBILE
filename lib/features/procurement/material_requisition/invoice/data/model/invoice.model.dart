import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class InvoiceModel {
  int materialRequisitionInvoiceId;
  String uniquekey;
  int materialRequisitionId;
  int materialRequisitionGrnId;
  String invoiceNumber;
  DateTime invoiceDate;
  String uploadInvoiceUrl;
  String performaInvoiceUrl;
  String measurementReportUrl;
  double invoiceAmount;
  DateTime invoiceDueDate;
  String remarks;
  String invoiceStatus;
  int clientRegistrationId;
  double invoiceAmountPaidTillDate;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  dynamic modifiedDate;
  bool isApproval;

  // THIS HAS BEEN ADDED ONLY TO SELECT THE FILE DATA
  MultiFilePickerModel? uploadInvoiceFile;
  MultiFilePickerModel? performaInvoiceFile;

  InvoiceModel({
    required this.materialRequisitionInvoiceId,
    required this.uniquekey,
    required this.materialRequisitionId,
    required this.materialRequisitionGrnId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.uploadInvoiceUrl,
    required this.performaInvoiceUrl,
    required this.measurementReportUrl,
    required this.invoiceAmount,
    required this.invoiceDueDate,
    required this.remarks,
    required this.invoiceStatus,
    required this.clientRegistrationId,
    required this.invoiceAmountPaidTillDate,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.isApproval,
    this.performaInvoiceFile,
    this.uploadInvoiceFile,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
    materialRequisitionInvoiceId: parseValue<int>(
      json,
      "MaterialRequisitionInvoiceId",
    ),
    uniquekey: parseValue<String>(json, "Uniquekey"),
    materialRequisitionId: parseValue<int>(json, "MaterialRequisitionId"),
    materialRequisitionGrnId: parseValue<int>(json, "MaterialRequisitionGRNId"),
    invoiceNumber: parseValue<String>(json, "InvoiceNumber"),
    invoiceDate: parseValue<DateTime>(json, "InvoiceDate"),
    uploadInvoiceUrl: parseValue<String>(json, "UploadInvoiceURL"),
    performaInvoiceUrl: parseValue<String>(json, "PerformaInvoiceURL"),
    measurementReportUrl: parseValue(json, "MeasurementReportURL"),
    invoiceAmount: parseValue<double>(json, "InvoiceAmount"),
    invoiceDueDate: parseValue<DateTime>(json, "InvoiceDueDate"),
    remarks: parseValue<String>(json, "Remarks"),
    invoiceStatus: parseValue<String>(json, "InvoiceStatus"),
    clientRegistrationId: parseValue<int>(json, "ClientRegistrationId"),
    invoiceAmountPaidTillDate: parseValue<double>(
      json,
      "InvoiceAmountPaidTillDate",
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
    isApproval: parseValue<bool>(json, "IsApproval"),
  );

  Map<String, dynamic> toJson() => {
    "MaterialRequisitionInvoiceId": materialRequisitionInvoiceId,
    "Uniquekey": uniquekey,
    "MaterialRequisitionId": materialRequisitionId,
    "MaterialRequisitionGRNId": materialRequisitionGrnId,
    "InvoiceNumber": invoiceNumber,
    "InvoiceDate": invoiceDate.toIso8601String(),
    "UploadInvoiceURL": uploadInvoiceUrl,
    "PerformaInvoiceURL": performaInvoiceUrl,
    "MeasurementReportURL": measurementReportUrl,
    "InvoiceAmount": invoiceAmount,
    "InvoiceDueDate": invoiceDueDate.toIso8601String(),
    "Remarks": remarks,
    "InvoiceStatus": invoiceStatus,
    "ClientRegistrationId": clientRegistrationId,
    "InvoiceAmountPaidTillDate": invoiceAmountPaidTillDate,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate,
    "IsApproval": isApproval,
  };
}
