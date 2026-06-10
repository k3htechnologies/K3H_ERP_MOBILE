import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
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

  Future<List<InvoiceModel>> getInvoice({
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
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
        return [];
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            invoiceList: response["data"] as List<InvoiceModel>,
          ),
        );
        return response["data"] as List<InvoiceModel>;
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
    required int materialRequisitionGRNId,
    required MultiFilePickerModel uploadInvoicePhoto,
    required MultiFilePickerModel performaInvoicePhoto,
    required MultiFilePickerModel measurementReportPhoto,
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
      "MaterialRequisitionGRNId": materialRequisitionGRNId.toString(),
    };
    List<Map<String, dynamic>> fileList = [];
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
    for (int i = 0; i < measurementReportPhoto.fileBytesList.length; i++) {
      if (measurementReportPhoto.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "MeasurementReportURL",
        "value": measurementReportPhoto.fileBytesList[i],
        "fileName": measurementReportPhoto.fileNameList[i],
      });
    }

    var result = await invoiceRepository.addUpdateRequisitionInvoice(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        goRouter.pop();
        await getInvoice(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
          context: context,
        );
        if (context.mounted) {
          final grnCubit = context.read<GrnCubit>();

          await grnCubit.getAllGRNList(
            context: context,
            materialRequisitionId: materialRequisitionId,
            uniqueKey: uniqueKey,
            projectId: projectId,
          );
        }
        if (context.mounted) {
          showSuccessMessage(context);
        }
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
      "PaymentMode": selectPaymentMode["DisplayName"].toString(),
      "BankListMasterId": selectedBank["zAttributesId"].toString(),
      "AccountNumber": accountNumber,
      "IFSCCode": ifscCode,
      "PaymentType": selectPaymentType["DisplayName"].toString(),
      "AmountPaid": amountPaid.isEmpty ? "0" : amountPaid,
      "TDSAmount": tdsAmount.isEmpty ? "0" : tdsAmount,
      "TransactionNumber": transactionNumber,
      "IsAdvance": isAdvance.toString(),
    };
    List<Map<String, dynamic>> fileList = [];
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
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        goRouter.pop();
        emit(state.copyWith(isLoading: false));
        await getInvoice(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
          context: context,
        );
        if (context.mounted) {
          final grnCubit = context.read<GrnCubit>();

          await grnCubit.getAllGRNList(
            context: context,
            materialRequisitionId: materialRequisitionId,
            uniqueKey: uniqueKey,
            projectId: projectId,
          );
        }
        if (context.mounted) {
          showSuccessMessage(context);
        }
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
        showErrorMessage(context, "Error", failure.message);
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
        showErrorMessage(context, "Error", failure.message);
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
