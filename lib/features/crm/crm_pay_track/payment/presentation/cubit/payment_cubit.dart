// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger_summary.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/repository/payment.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_state.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/repository/other_charges.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

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

  // PROJECT MASTER REPO
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
  // <---- GET PAY TRACK LIST ---->
  Future getPaymentScheduleList(
    BuildContext context,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await paymentRepository.getPayTrackPaymentScheduleList(
      bookingId: bookingId,
      projectId: projectId,
      queryParams: {"IsCheckPermission": true},
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
      "PaymentScheduleDemandType": paymentScheduleDemandType,
    };

    var addResult = await paymentRepository
        .addUpdatePayTrackPaymentScheduleDemand(body: requestBody);
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
            paymentLedger: [
              response['data'][0] as PayTrackPaymentLedgerModel,
              ...state.paymentLedger,
            ],
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  // <---- GET PAYMENT LEDGER LIST ---->
  Future getPaymentLedgerList(
    BuildContext context,
    int bookingId,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await paymentRepository.getPayTrackPayTrackPaymentLedgerList(
      bookingId: bookingId,
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        // Always replace list to avoid duplicates on mobile refresh/approval
        final updatedList =
            response['data'] as List<PayTrackPaymentLedgerModel>;
        emit(state.copyWith(isLoading: false, paymentLedger: updatedList));
      },
    );
  }

  // <---- GET PAYMENT LEDGER SUMMARY LIST ---->
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
        // Always replace list to avoid duplicates on mobile refresh/approval
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

  // <---- ADD PAYMENT LEDGER ---->
  Future addPaymentLedgerMaster({
    required BuildContext context,
    required String bookingId,
    required String projectId,
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
      "BookingId": bookingId,
      "ProjectId": projectId,
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
            paymentLedger: [
              response['data'][0] as PayTrackPaymentLedgerModel,
              ...state.paymentLedger,
            ],
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  // <---- DELETE LEDGER ---->
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
        return;
      },
      (response) {
        showSuccessMessage(context);
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

  // <---- OTHER CHARGES DROPDOWN ---->
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
        return {
          "itemList": List<Map<String, dynamic>>.from(
            (response['data'] as List<dynamic>)
                .map(
                  (e) => {
                    "zAttributesId": e.otherChargesId,
                    "DisplayName": e.chargeName,
                  },
                )
                .toList(),
          ),
          "totalNumberOfRecord": response["totalNumberOfRecord"],
        };
      },
    );
  }

  // <---- BANK DROPDOWN ---->
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

  // <---- PROJECT WISE BANK DROPDOWN ---->\
  Future<Map<String, dynamic>> getProjectWithBankDropdown(
    int pageNumber, {
    String? value,
  }) async {
    ProjectModel project = getProject();

    var result = await _projectMasterRepository.getProjectWithBankDetails(
      projectId: project.projectId,
    );

    return result.fold(
      (failure) {
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        final data = response["data"] as List<dynamic>? ?? [];

        return {
          "itemList": List<Map<String, dynamic>>.from(
            data.map(
              (e) => {
                "zAttributesId": e["ProjectWithBankDetailsId"],
                "ProjectWithBankDetailsId": e["ProjectWithBankDetailsId"],
                "BankListMasterId": e["BankListMasterId"],
                "DisplayName": "${e["BankName"]} - ${e["NatureOfAccount"]}",
                "AccountHolderName": e["BeneficiaryAccountHolderName"],
                "AccountNumber": e["AccountNumber"],
                "Branch": e["Branch"],
                "IFSCCode": e["IFSCCode"],
                "AcType": e["AcType"],
              },
            ),
          ),
          "totalNumberOfRecord": data.length,
        };
      },
    );
  }

  // <---- ADD UPDATE PAYMENT LEDGER APPROVAL ---->
  // ? Note : Following binding is not complete.
  // Future<bool> addUpdatePaymentLedgerApproval({
  //   required BuildContext context,
  //   required PayTrackPaymentLedgerModel paymentLedger,
  //   required String remark,
  //   required bool isApproved,
  // }) async {
  //   DialogHelper.showProcessingOverlay(context);
  //   Map<String, dynamic> request = {
  //     "ProjectId": paymentLedger.projectId,
  //     "ModuleName": "PAY TRACK LEDGER APPROVAL",
  //     "Id": paymentLedger.payTrackPaymentLedgerId,
  //     "SubId": 0,
  //     "SubSubId": 0,
  //     "SubSubSubId": 0,
  //     "IsApproved": isApproved,
  //     "Remarks": remark,
  //   };
  //   var result;
  //   goRouter.pop();
  //   return result.fold(
  //     (failure) {
  //       emit(state.copyWith(isLoading: false));
  //       showErrorMessage(context, 'Error', failure.message);
  //       return false;
  //     },
  //     (response) async {
  //       await showSuccessMessage(context);
  //       if (context.mounted) {
  //         await getPaymentLedgerList(
  //           context,
  //           paymentLedger.bookingId,
  //           paymentLedger.projectId,
  //         );
  //       }
  //       return true;
  //     },
  //   );
  // }

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
}
