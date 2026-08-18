// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger_summary.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_schedule_demand_summary.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/repository/payment.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_state.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/repository/other_charges.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentState.initial());

  // ACCOUNT REPOSITORY
  final PaymentRepository paymentRepository =
      serviceLocator<PaymentRepository>();

  // OTHER CHARGES
  final OtherChargesRepository _otherChargesRepository =
      serviceLocator<OtherChargesRepository>();

  // EMPLOYEE MASTER REPO
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  void search({
    required BuildContext context,
    required String searchText,
    required int bookingId,
    required int projectId,
    required int selectedTab,
  }) {
    emit(state.copyWith(searchText: searchText));

    if (selectedTab == 0) {
      getPaymentScheduleList(
        context,
        projectId,
        bookingId,
        searchText: searchText,
      );
    } else {
      getPaymentLedgerList(
        context,
        bookingId,
        projectId,
        searchText: searchText,
      );
    }
  }

  double get totalPaymentScheduleAmount {
    return state.payTrackPaymentScheduleList.fold(
      0.0,
      (sum, item) =>
          sum +
          item.paymentScheduleAmount +
          item.paymentScheduleGstAmount +
          item.paymentScheduleTdsAmount,
    );
  }

  double get totalAgreementAmount {
    return state.payTrackPaymentScheduleList.fold(
      0.0,
      (sum, item) => sum + item.paymentScheduleAmount,
    );
  }

  double get totalAmount {
    return state.payTrackPaymentScheduleList.fold(
      0.0,
      (sum, item) =>
          sum +
          item.paymentScheduleAmount +
          item.paymentScheduleGstAmount +
          item.paymentScheduleTdsAmount,
    );
  }

  String apiDemandType(String value) {
    switch (value.trim().toLowerCase()) {
      case "demand":
        return "Demand Letter";
      case "reminder":
        return "Reminder Letter";
      default:
        return value;
    }
  }

  Future getPaymentScheduleList(
    BuildContext context,
    int projectId,
    int bookingId, {
    String searchText = "",
  }) async {
    emit(state.copyWith(isLoading: true));

    var result = await paymentRepository.getPayTrackPaymentScheduleList(
      bookingId: bookingId,
      projectId: projectId,
      queryParams: {"IsCheckPermission": true, "Name": searchText},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            payTrackPaymentScheduleList: response['data'],
          ),
        );
      },
    );
  }

  Future addDemandDraft({
    required BuildContext context,
    required int bookingPaymentScheduleId,
    required int bookingId,
    required int projectId,
    required String paymentScheduleDemandType,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "BookingPaymentScheduleId": bookingPaymentScheduleId.toString(),
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "PaymentScheduleDemandType": apiDemandType(paymentScheduleDemandType),
    };
    var addResult = await paymentRepository
        .addUpdatePayTrackPaymentScheduleDemand(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) async {
        if (!context.mounted) return;

        showSuccessMessage(context, subTitle: response["message"]);

        await getPaymentScheduleList(context, projectId, bookingId);
      },
    );
  }

  // <---- GET PAYMENT LEDGER LIST ---->
  Future getPaymentLedgerList(
    BuildContext context,
    int bookingId,
    int projectId, {
    String searchText = "",
  }) async {
    emit(state.copyWith(isLoading: true));
    var result = await paymentRepository.getPayTrackPayTrackPaymentLedgerList(
      bookingId: bookingId,
      projectId: projectId,
      queryParams: {"PaymentFor": searchText},
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final updatedList =
            response['data'] as List<PayTrackPaymentLedgerModel>;
        emit(state.copyWith(isLoading: false, paymentLedger: updatedList));
      },
    );
  }

  // GET PAYMENT LEDGER SUMMARY LIST
  Future getPaymentLedgerSummaryList(
    BuildContext context,
    int bookingId,
    int projectId,
    String paymentFor,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await paymentRepository
        .getPayTrackPayTrackPaymentLedgerSummaryList(
          bookingId: bookingId,
          projectId: projectId,
          paymentFor: paymentFor,
        );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final updatedList =
            response['data'] as List<PayTrackPaymentLedgerSummaryModel>;
        emit(
          state.copyWith(
            isLoading: false,
            payTrackPaymentLedgerSummaryList: updatedList,
          ),
        );
      },
    );
  }

  Future getPayTrackPaymentScheduleDemandSummaryList(
    BuildContext context,
    int bookingId,
    int projectId,
    int bookingPaymentScheduleId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await paymentRepository
        .getPayTrackPaymentScheduleDemandSummaryList(
          bookingId: bookingId,
          projectId: projectId,
          bookingPaymentScheduleId: bookingPaymentScheduleId,
          queryParams: {"IsCheckPermission": true},
        );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final updatedList =
            response['data'] as List<PayTrackPaymentScheduleDemandSummaryModel>;
        emit(
          state.copyWith(
            isLoading: false,
            payTrackPaymentScheduleDemandSummaryModel: updatedList,
          ),
        );
      },
    );
  }

  // <---- ADD PAYMENT LEDGER ---->
  Future addPaymentLedgerMaster({
    required BuildContext context,
    required int bookingId,
    required int projectId,
    required String bookingOtherChargesId,
    required String paymentFor,
    required String paymentMode,
    required String paymentReceivedFrom,
    required String bankListMasterId,
    required String projectBankListMasterId,
    required String receivedAmount,
    required String transactionChequeDemandDraftNumber,
    required String transactionChequeDemandDraftDate,

    required MultiFilePickerModel selectedChequeUrl,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "PayTrackPaymentLedgerId": "0",
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "BookingOtherChargesId": bookingOtherChargesId,
      "PaymentFor": paymentFor,
      "PaymentMode": paymentMode,
      "PaymentReceivedFrom": paymentReceivedFrom,
      "BankListMasterId": bankListMasterId,
      "ProjectBankListMasterId": projectBankListMasterId,
      "ReceivedAmount": receivedAmount,
      "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
      "TransactionChequeDemandDraftDate": transactionChequeDemandDraftDate,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < selectedChequeUrl.fileNameList.length; i++) {
      if (selectedChequeUrl.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "TransactionChequeDemandDraftURL",
        "value": selectedChequeUrl.fileBytesList[i],
        "fileName": selectedChequeUrl.fileNameList[i],
      });
    }

    var addResult = await paymentRepository.addUpdatePayTrackPaymentLedger(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        emit(
          state.copyWith(
            payTrackPaymentLedgerSummaryList: [
              response['data'][0] as PayTrackPaymentLedgerSummaryModel,
              ...state.payTrackPaymentLedgerSummaryList,
            ],
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
        getPaymentLedgerList(context, bookingId, projectId);
        getPaymentLedgerSummaryList(context, bookingId, projectId, paymentFor);
      },
    );
  }

  // <---- ADD PAYMENT LEDGER ---->
  Future updatePaymentLedgerMaster({
    required BuildContext context,
    required int bookingId,
    required int projectId,
    required String payTrackPaymentLedgerId,
    required String uniquekey,
    required String bookingOtherChargesId,
    required String paymentFor,
    required String paymentMode,
    required String paymentReceivedFrom,
    required String bankListMasterId,
    required String projectBankListMasterId,
    required String receivedAmount,
    required String transactionChequeDemandDraftNumber,
    required String transactionChequeDemandDraftDate,

    required MultiFilePickerModel selectedChequeUrl,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "PayTrackPaymentLedgerId": payTrackPaymentLedgerId.toString(),
      "Uniquekey": uniquekey,
      "BookingId": bookingId.toString(),
      "ProjectId": projectId.toString(),
      "BookingOtherChargesId": bookingOtherChargesId,
      "PaymentFor": paymentFor,
      "PaymentMode": paymentMode,
      "PaymentReceivedFrom": paymentReceivedFrom,
      "BankListMasterId": bankListMasterId,
      "ProjectBankListMasterId": projectBankListMasterId,
      "ReceivedAmount": receivedAmount,
      "TransactionChequeDemandDraftNumber": transactionChequeDemandDraftNumber,
      "TransactionChequeDemandDraftDate": transactionChequeDemandDraftDate,
      "RemoveTransactionChequeDemandDraftURL":
          selectedChequeUrl.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < selectedChequeUrl.fileBytesList.length; i++) {
      fileList.add({
        "key": "TransactionChequeDemandDraftURL",
        "value": selectedChequeUrl.fileBytesList[i],
        "fileName": selectedChequeUrl.fileNameList[i],
      });
    }
    var addResult = await paymentRepository.addUpdatePayTrackPaymentLedger(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        showSuccessMessage(context, subTitle: response['message']);
        getPaymentLedgerList(context, bookingId, projectId);
        getPaymentLedgerSummaryList(context, bookingId, projectId, paymentFor);
      },
    );
  }

  // DELETE LEDGER
  Future deletePayTrackPaymentLedger({
    required BuildContext context,
    required int payTrackPaymentLedgerId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await paymentRepository.deletePayTrackPaymentLedger(
      projectId: projectId,
      payTrackPaymentLedgerId: payTrackPaymentLedgerId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(context, subTitle: response["message"]);

        goRouter.pop(true);

        if (index != null) {
          final updatedList = List<PayTrackPaymentLedgerModel>.from(
            state.paymentLedger,
          );
          updatedList.removeAt(index);
          emit(state.copyWith(paymentLedger: updatedList));
        } else {
          getPaymentLedgerList(context, bookingId, projectId);
        }
      },
    );
  }

  // OTHER CHARGES DROPDOWN
  Future<Map<String, dynamic>> getOtherChargesList(
    int pageNumber,
    int projectId, {
    String? value,
  }) async {
    var result = await _otherChargesRepository.getOtherChargesList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: {'ChargeName': value ?? ''},
    );
    return result.fold(
      (failure) {
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        final data = response['data'] as List<OtherChargeModel>;

        emit(state.copyWith(otherChargesList: data));

        return {
          "itemList":
              data
                  .map(
                    (e) => {
                      "zAttributesId": e.otherChargesId,
                      "DisplayName": e.chargeName,
                    },
                  )
                  .toList(),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  // BANK DROPDOWN
  Future<Map<String, dynamic>> getBankList(
    int pageNumber, {
    String? value,
  }) async {
    var result = await _employeeMasterRepository.getBankList(
      pageNumber: pageNumber,
      pageSize: 10,
      query: {'BankName': value ?? ''},
    );
    return result.fold(
      (failure) {
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        return {
          "itemList": List<Map<String, dynamic>>.from(
            (response['data'] as List<dynamic>)
                .map(
                  (e) => {
                    "zAttributesId": e["ProjectWithBankDetailsId"],
                    "DisplayName": e["BankNameWithCode"],
                  },
                )
                .toList(),
          ),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  // <---- EXPORT PAYMENT LEDGER ---->
  Future exportPaymentLedger(
    BuildContext context,
    int bookingId,
    int projectId,
    String projectName,
    String exportType,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await paymentRepository.exportPaymentLedger(
      bookingId: bookingId,
      projectId: projectId,
      queryParams: {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "${projectName}_payment_ledger_${DateTime.now()}.pdf"
              : "${projectName}_payment_ledger_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future exportPaymentSchedule(
    BuildContext context,
    int bookingId,
    int projectId,
    String projectName,
    String exportType,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await paymentRepository.exportPaymentSchedule(
      bookingId: bookingId,
      projectId: projectId,
      queryParams: {"ExportType": exportType},
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "${projectName}_payment_schedule_${DateTime.now()}.pdf"
              : "${projectName}_payment_schedule_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
