import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/paid_brokerage_booking.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/repository/brokerage.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'brokerage_state.dart';

class BrokerageCubit extends Cubit<BrokerageState> {
  BrokerageCubit() : super(BrokerageState.initial());

  // REPOSITORIES
  final BrokerageRepository _brokerageRepository =
      serviceLocator<BrokerageRepository>();

  // <---- SEARCH BROKERAGE ---->
  Future searchBrokerage(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: value, brokerageList: []));
    await getBrokerageBookingList(context, 1, projectId);
  }

  Future resetSearch() async {
    emit(state.copyWith(searchText: ""));
  }

  Future searchInvoice(
    BuildContext context,
    String value,
    int projectId,
    int bookingId,
    int index,
  ) async {
    if (index == 0) {
      emit(
        state.copyWith(
          searchText: value,
          brokerageInvoiceList: [],
          isLoading: true,
        ),
      );

      await getBrokerageInvoiceList(context, 1, projectId, bookingId);
    } else {
      emit(
        state.copyWith(
          searchText: value,
          brokeragePaidList: [],
          isLoading: true,
        ),
      );
      await getBrokeragePaidList(context, 1, projectId, bookingId);
    }
  }

  // <---- GET BROKERAGE BOOKING LIST ---->
  Future getBrokerageBookingList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ChannelPartnerName": state.searchText,
      "ChannelPartnerMobileNumber": state.filterCpMobileNo,
      "ChannelPartnerCompanyName": state.filterCpCompany,
      "ApplicantMobileNumber": state.filterApplicantMobileNo,
      "ApplicantName": state.filterApplicantName,
      "Wing": state.filterWing,
      "Flat": state.filterFlat,
      "Floor": state.filterFloor,
      if (state.filterAgreementValue != 0)
        "AgreementValue": state.filterAgreementValue,
      "BookingType": state.filterBookingType,
      "FromDate": state.filterByFromDate,
      "ToDate": state.filterByToDate,
      "ProjectId": projectId,
    };
    var result = await _brokerageRepository.getBrokerageBookingList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<BrokerageModel> newData = List<BrokerageModel>.from(
          response['data'] ?? [],
        );

        final List<BrokerageModel> updatedList =
            pageNumber == 1 ? newData : [...state.brokerageList, ...newData];
        emit(
          state.copyWith(
            brokerageList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- GET BROKERAGE INVOICE LIST ---->
  Future getBrokerageInvoiceList(
    BuildContext context,
    int pageNumber,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _brokerageRepository.pullBrokerageInvoice(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      bookingId: bookingId,
      queryParams: {"InvoiceNumber": state.searchText},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<BrokerageInvoiceModel> newData =
            List<BrokerageInvoiceModel>.from(response['data'] ?? []);

        final List<BrokerageInvoiceModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.brokerageInvoiceList, ...newData];
        emit(
          state.copyWith(
            brokerageInvoiceList: updatedList,
            isLoading: false,
            totalNumberOfRecordInvoice: response["totalNumberOfRecord"],
            currentPageInvoice: pageNumber,
          ),
        );
      },
    );
  }

  // ADD BROKERAGE INVOICE
  Future addBrokerageInvoice({
    required BuildContext context,
    required String bookingId,
    required String projectId,
    required String invoiceNumber,
    required String invoiceDate,
    required String bankListMasterId,
    required String accountName,
    required String accountNumber,
    required String iFSCCode,
    required String invoiceAmount,
    required String dueDate,
    required String remark,
    required MultiFilePickerModel invoiceFiles,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "BrokerageInvoiceId": "0",
      "BookingId": bookingId,
      "ProjectId": projectId,
      "InvoiceNumber": invoiceNumber,
      "InvoiceDate": invoiceDate,
      "BankListMasterId": bankListMasterId,
      "AccountName": accountName,
      "AccountNumber": accountNumber,
      "IFSCCode": iFSCCode,
      "InvoiceAmount": invoiceAmount,
      "DueDate": dueDate,
      "Remark": remark,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < invoiceFiles.fileNameList.length; i++) {
      if (invoiceFiles.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "UploadInvoiceURL",
        "value": invoiceFiles.fileBytesList[i],
        "fileName": invoiceFiles.fileNameList[i],
      });
    }

    var updateResult = await _brokerageRepository.addUpdateBrokerageInvoice(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: "Invoice Added Successfully");
        getBrokerageInvoiceList(
          context,
          1,
          int.parse(projectId),
          int.parse(bookingId),
        );
      },
    );
  }

  // UPDATE BROKERAGE INVOICE
  Future updateBrokerageInvoice({
    required BuildContext context,
    required String brokerageInvoiceId,
    required String uniquekey,
    required String bookingId,
    required String projectId,
    required String invoiceNumber,
    required String invoiceDate,
    required String bankListMasterId,
    required String accountName,
    required String accountNumber,
    required String iFSCCode,
    required String invoiceAmount,
    required String dueDate,
    required String remark,
    required MultiFilePickerModel invoiceFiles,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "BrokerageInvoiceId": brokerageInvoiceId,
      "Uniquekey": uniquekey,
      "BookingId": bookingId,
      "ProjectId": projectId,
      "InvoiceNumber": invoiceNumber,
      "InvoiceDate": invoiceDate,
      "BankListMasterId": bankListMasterId,
      "AccountName": accountName,
      "AccountNumber": accountNumber,
      "IFSCCode": iFSCCode,
      "InvoiceAmount": invoiceAmount,
      "DueDate": dueDate,
      "Remark": remark,
      "RemoveUploadInvoiceURL": invoiceFiles.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < invoiceFiles.fileNameList.length; i++) {
      if (invoiceFiles.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "UploadInvoiceURL",
        "value": invoiceFiles.fileBytesList[i],
        "fileName": invoiceFiles.fileNameList[i],
      });
    }

    var updateResult = await _brokerageRepository.addUpdateBrokerageInvoice(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedBrokerageInvoice =
            response['data'][0] as BrokerageInvoiceModel;
        if (state.brokerageInvoiceList.isNotEmpty &&
            index < state.brokerageInvoiceList.length) {
          final updatedList = List<BrokerageInvoiceModel>.from(
            state.brokerageInvoiceList,
          );
          updatedList[index] = updatedBrokerageInvoice;
          emit(state.copyWith(brokerageInvoiceList: updatedList));
        }
        showSuccessMessage(context, subTitle: "Invoice Updated Successfully");
      },
    );
  }

  // <---- DELETE BROKERAGE INVOICE ---->
  Future deleteBrokerageInvoice({
    required BuildContext context,
    required BrokerageInvoiceModel brokerage,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _brokerageRepository.deleteBrokerageInvoice(
      projectId: brokerage.projectId,
      brokerageInvoiceId: brokerage.brokerageInvoiceId,
      bookingId: brokerage.bookingId,
      uniqueKey: brokerage.uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: 'Invoice Deleted Successfully');
        final updatedList = List<BrokerageInvoiceModel>.from(
          state.brokerageInvoiceList,
        );
        updatedList.removeAt(index);

        emit(
          state.copyWith(
            brokerageInvoiceList: updatedList,
            totalNumberOfRecordInvoice:
                state.totalNumberOfRecordInvoice > 0
                    ? state.totalNumberOfRecordInvoice - 1
                    : 0,
          ),
        );
      },
    );
  }

  // <---- GET PAID BROKERAGE LIST ---->
  Future getBrokeragePaidList(
    BuildContext context,
    int pageNumber,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _brokerageRepository.pullPaidBrokerageBooking(
      pageNumber: pageNumber,
      pageSize: 10,
      bookingId: bookingId,
      projectId: projectId,
      queryParams: {"InvoiceNumber": state.searchText},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<PaidBrokerageBookingModel> newData =
            List<PaidBrokerageBookingModel>.from(response['data'] ?? []);

        final List<PaidBrokerageBookingModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.brokeragePaidList, ...newData];
        emit(
          state.copyWith(
            brokeragePaidList: updatedList,
            isLoading: false,
            totalNumberOfRecordPaid: response["totalNumberOfRecord"],
            currentPagePaid: pageNumber,
          ),
        );
      },
    );
  }

  // ADD BROKERAGE PAYMENT
  Future addBrokeragePayment({
    required BuildContext context,
    required String bookingId,
    required String projectId,
    required String brokerageInvoiceId,
    required String paymentMode,
    required String bankListMasterId,
    required String paymentType,
    required String amountPaid,
    required String tDSAmount,
    required String transactionNumber,
    required MultiFilePickerModel transactionReceiptFiles,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "PaidBrokerageBookingId": "0",
      "BookingId": bookingId,
      "ProjectId": projectId,
      "BrokerageInvoiceId": brokerageInvoiceId,
      "PaymentMode": paymentMode,
      "BankListMasterId": bankListMasterId,
      "PaymentType": paymentType,
      "AmountPaid": amountPaid,
      "TDSAmount": tDSAmount,
      "TransactionNumber": transactionNumber,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < transactionReceiptFiles.fileNameList.length; i++) {
      if (transactionReceiptFiles.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "TransactionReceiptURL",
        "value": transactionReceiptFiles.fileBytesList[i],
        "fileName": transactionReceiptFiles.fileNameList[i],
      });
    }

    var updateResult = await _brokerageRepository.addUpdatePaidBrokerageBooking(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: "Payment Added Successfully");
      },
    );
  }

  // UPDATE BROKERAGE INVOICE
  Future updateBrokeragePayment({
    required BuildContext context,
    required String paidBrokerageBookingId,
    required String uniquekey,
    required String bookingId,
    required String projectId,
    required String brokerageInvoiceId,
    required String paymentMode,
    required String bankListMasterId,
    required String paymentType,
    required String amountPaid,
    required String tDSAmount,
    required String transactionNumber,
    required MultiFilePickerModel transactionReceiptFiles,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "PaidBrokerageBookingId": paidBrokerageBookingId,
      "Uniquekey": uniquekey,
      "BookingId": bookingId,
      "ProjectId": projectId,
      "BrokerageInvoiceId": brokerageInvoiceId,
      "PaymentMode": paymentMode,
      "BankListMasterId": bankListMasterId,
      "PaymentType": paymentType,
      "AmountPaid": amountPaid,
      "TDSAmount": tDSAmount,
      "TransactionNumber": transactionNumber,
      "RemoveTransactionReceiptURL": transactionReceiptFiles.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < transactionReceiptFiles.fileNameList.length; i++) {
      if (transactionReceiptFiles.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "TransactionReceiptURL",
        "value": transactionReceiptFiles.fileBytesList[i],
        "fileName": transactionReceiptFiles.fileNameList[i],
      });
    }

    var updateResult = await _brokerageRepository.addUpdatePaidBrokerageBooking(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedBrokeragePayment =
            response['data'][0] as PaidBrokerageBookingModel;
        if (state.brokeragePaidList.isNotEmpty &&
            index < state.brokeragePaidList.length) {
          final updatedList = List<PaidBrokerageBookingModel>.from(
            state.brokeragePaidList,
          );
          updatedList[index] = updatedBrokeragePayment;
          emit(state.copyWith(brokeragePaidList: updatedList));
        }
        showSuccessMessage(context, subTitle: "Payment Updated Successfully");
      },
    );
  }

  // <---- DELETE BROKERAGE PAYMENT ---->
  Future deleteBrokeragePayment({
    required BuildContext context,
    required PaidBrokerageBookingModel payment,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _brokerageRepository.deletePaidBrokerageBooking(
      projectId: payment.projectId,
      paidBrokerageBookingId: payment.paidBrokerageBookingId,
      bookingId: payment.bookingId,
      brokerageInvoiceId: payment.brokerageInvoiceId,
      uniqueKey: payment.uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: 'Payment Deleted Successfully');
        final updatedList = List<PaidBrokerageBookingModel>.from(
          state.brokeragePaidList,
        );
        updatedList.removeAt(index);

        emit(
          state.copyWith(
            brokeragePaidList: updatedList,
            totalNumberOfRecordPaid:
                state.totalNumberOfRecordPaid > 0
                    ? state.totalNumberOfRecordPaid - 1
                    : 0,
          ),
        );
      },
    );
  }

  void applyFilterAndSort({
    required BuildContext context,
    required int projectId,
    required String filterCpCompany,
    required String filterCpMobileNo,
    required String filterApplicantName,
    required String filterApplicantMobileNo,
    required String filterWing,
    required String filterFlat,
    required String filterFloor,
    required double filterAgreementValue,
    required String filterBookingType,
    required DateTime? filterByFromDate,
    required DateTime? filterByToDate,
  }) {
    emit(
      state.copyWith(
        filterCpCompany: filterCpCompany,
        filterCpMobileNo: filterCpMobileNo,
        filterApplicantName: filterApplicantName,
        filterApplicantMobileNo: filterApplicantMobileNo,
        filterWing: filterWing,
        filterFlat: filterFlat,
        filterFloor: filterFloor,
        filterAgreementValue: filterAgreementValue,
        filterBookingType: filterBookingType,
        filterByFromDate: filterByFromDate,
        filterByToDate: filterByToDate,
      ),
    );

    getBrokerageBookingList(context, 1, projectId);
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _brokerageRepository.exportBrokerageBooking(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      queryParams:
          state.searchText != ""
              ? {"ApplicantName": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Brokerage Booking ${DateTime.now()}.pdf"
              : "Brokerage Booking ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
