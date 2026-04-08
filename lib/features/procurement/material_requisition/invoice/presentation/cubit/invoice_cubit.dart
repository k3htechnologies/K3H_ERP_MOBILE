import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/model/invoice.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/model/invoice_payment.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/repository/invoice.repository.dart';
import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  InvoiceCubit() : super(InvoiceState.initial());
  final InvoiceRepository invoiceRepository =
      serviceLocator<InvoiceRepository>();

  Future<void> getInvoice({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
    required BuildContext context,
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await invoiceRepository.getRequisitionInvoice(
      projectId: projectId,
      materialRequisitionId: materialRequisitionId,
      uniqueKey: uniqueKey,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            invoiceList: response["data"] as List<InvoiceModel>,
          ),
        );
      },
    );
  }

  Future<void> addInvoice({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
    required String invoiceNumber,
    required String invoiceAmount,
    required String invoiceDate,
    required String dueDate,
    required String remarks,
    required MultiFilePickerModel uploadInvoicePhoto,
    required MultiFilePickerModel performaInvoicePhoto,
  }) async {
    if (uploadInvoicePhoto.fileNameList.isEmpty &&
        performaInvoicePhoto.fileNameList.isEmpty) {
      DialogHelper.showErrorMessage(
        context: context,
        title: 'Error',
        message: 'Invoice/Performa Invoice is required.',
      );
      Future.delayed(Duration(seconds: 1), () {
        goRouter.pop();
      });
      return;
    }

    DialogHelper.showProcessingOverlay(context);
    final Map<String, String> body = {
      "ProjectId": projectId.toString(),
      "MaterialRequisitionId": materialRequisitionId.toString(),
      "InvoiceNumber": invoiceNumber,
      "InvoiceDate": invoiceDate,
      "InvoiceAmount": invoiceAmount,
      "InvoiceDueDate": dueDate,
      "Remarks": remarks,
    };
    final List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < uploadInvoicePhoto.fileBytesList.length; i++) {
      if (uploadInvoicePhoto.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "UploadInvoiceURL",
        "value": uploadInvoicePhoto.fileBytesList[i],
        "fileName": uploadInvoicePhoto.fileNameList[i],
      });
    }
    for (int i = 0; i < performaInvoicePhoto.fileBytesList.length; i++) {
      if (performaInvoicePhoto.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "PerformaInvoiceURL",
        "value": performaInvoicePhoto.fileBytesList[i],
        "fileName": performaInvoicePhoto.fileNameList[i],
      });
    }
    var result = await invoiceRepository.addUpdateRequisitionInvoice(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        goRouter.pop();
        getInvoice(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
          context: context,
        );
        showSuccessMessage(context);
      },
    );
  }

  Future<void> deleteInvoice({
    required int projectId,
    required int materialRequisitionInvoiceId,
    required int materialRequisitionId,
    required String uniqueKey,
    required BuildContext context,
  }) async {
    var res = await DialogHelper.deleteDialog(
      context,
      'You are about to delete an invoice?',
      'Deleting this invoice will permanently remove its contents.',
    );
    if (!res) {
      return;
    }
    var result = await invoiceRepository.deleteRequisitionInvoice(
      projectId: projectId,
      materialRequisitionInvoiceId: materialRequisitionInvoiceId,
      uniqueKey: uniqueKey,
      materialRequisitionId: materialRequisitionId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        showSuccessMessage(context);
        getInvoice(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
          context: context,
        );
      },
    );
  }

  Future<void> addPayment({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
    required int materialRequisitionInvoiceId,
    required Map<String, dynamic> selectPaymentMode,
    required Map<String, dynamic> selectedBank,
    required String accountNumber,
    required String ifscCode,
    required Map<String, dynamic> selectPaymentType,
    required String amountPaid,
    required String tdsAmount,
    required String transactionNumber,
    required bool isAdvance,
    required MultiFilePickerModel transactionReceiptPhoto,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    emit(state.copyWith(isLoading: true));
    final Map<String, String> body = {
      "ProjectId": projectId.toString(),
      "MaterialRequisitionInvoiceId": materialRequisitionInvoiceId.toString(),
      "MaterialRequisitionId": materialRequisitionId.toString(),
      "PaymentMode": selectPaymentMode["DisplayName"],
      "BankListMasterId": selectedBank["zAttributesId"].toString(),
      "AccountNumber": accountNumber,
      "IFSCCode": ifscCode,
      "PaymentType": selectPaymentType["DisplayName"],
      "AmountPaid": amountPaid,
      "TDSAmount": tdsAmount,
      "TransactionNumber": transactionNumber,
      "IsAdvance": isAdvance.toString(),
    };
    final List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < transactionReceiptPhoto.fileBytesList.length; i++) {
      fileList.add({
        "key": "TransactionReceiptURL",
        "value": transactionReceiptPhoto.fileBytesList[i],
        "fileName": transactionReceiptPhoto.fileNameList[i],
      });
    }
    var result = await invoiceRepository.addUpdateRequisitionPayment(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        goRouter.pop();
        emit(state.copyWith(isLoading: false));
        getInvoice(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
          context: context,
        );
        showSuccessMessage(context);
      },
    );
  }

  Future<void> getPayment({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionInvoiceId,
    required int materialRequisitionId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    emit(state.copyWith(isLoading: true));
    var result = await invoiceRepository.getRequisitionPayment(
      projectId: projectId,
      materialRequisitionInvoiceId: materialRequisitionInvoiceId,
      materialRequisitionId: materialRequisitionId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            paymentList:
                response["data"] as List<MaterialRequisitionPaymentModel>,
          ),
        );
      },
    );
  }

  Future<List<VendorModel>> getFinalisedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
    required BuildContext context,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    emit(state.copyWith(isLoading: true));

    var result = await invoiceRepository.getFinalisedVendor(
      projectId: projectId,
      materialRequisitionId: materialRequisitionId,
      uniqueKey: uniqueKey,
    );

    goRouter.pop();

    List<VendorModel> vendors = [];

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        vendors =
            (response["data"] as List)
                .map((e) => VendorModel.fromJson(e as Map<String, dynamic>))
                .toList();
      },
    );

    return vendors;
  }
}
