import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/payment_schedule_master.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule/data/respository/payment_schedule.repository.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule/presentation/cubit/payment_schedule_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class PaymentScheduleMasterCubit extends Cubit<PaymentScheduleMasterState> {
  PaymentScheduleMasterCubit() : super(PaymentScheduleMasterState.initial());

  // ----------------------------------------------------------
  // REPOSITORIES
  // ----------------------------------------------------------
  final PaymentScheduleMasterRepository _repository =
      serviceLocator<PaymentScheduleMasterRepository>();

  // ----------------------------------------------------------
  // SEARCH
  // ----------------------------------------------------------
  Future searchPaymentScheduleMaster(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, paymentScheduleMasterList: []));
    await getPaymentScheduleMasterList(context, 1);
  }

  // ----------------------------------------------------------
  // GET LIST
  // ----------------------------------------------------------
  Future getPaymentScheduleMasterList(
    BuildContext context,
    int pageNumber,
  ) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "Stage": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await _repository.getPaymentScheduleMasterList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<PaymentScheduleMasterModel> newData =
            List<PaymentScheduleMasterModel>.from(response['data'] ?? []);

        final updatedList =
            pageNumber == 1
                ? newData
                : [...state.paymentScheduleMasterList, ...newData];

        emit(
          state.copyWith(
            paymentScheduleMasterList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // ADD / UPDATE
  // ----------------------------------------------------------
  Future addPaymentScheduleMaster({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required String stage,
    required String wing,
    required double paymentSchedulePercentage,
    required double cumulativePercentage,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "PaymentScheduleMasterId": 0,
      "ProjectId": projectId,
      "InventoryBuildingId": buildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
      "Stage": stage,
      "Wing": wing,
      "PaymentSchedulePercentage": paymentSchedulePercentage,
      "PaymentScheduleCummulativePercentage": cumulativePercentage,
    };

    var result = await _repository.addUpdatePaymentScheduleMaster(
      body: requestBody,
    );

    goRouter.pop();

    result.fold(
      (failure) => showErrorMessage(context, 'Error', failure.message),
      (response) => showSuccessMessage(
        context,
        subTitle: "Payment Schedule Master Added Successfully!!!",
      ),
    );
  }

  Future updatePaymentScheduleMaster({
    required BuildContext context,
    required int paymentScheduleMasterId,
    required String uniqueKey,
    required int buildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required String stage,
    required String wing,
    required double paymentSchedulePercentage,
    required double cumulativePercentage,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "PaymentScheduleMasterId": paymentScheduleMasterId,
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId,
      "InventoryBuildingId": buildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
      "Stage": stage,
      "Wing": wing,
      "PaymentSchedulePercentage": paymentSchedulePercentage,
      "PaymentScheduleCummulativePercentage": cumulativePercentage,
    };

    var result = await _repository.addUpdatePaymentScheduleMaster(
      body: requestBody,
    );

    goRouter.pop();

    result.fold(
      (failure) => showErrorMessage(context, 'Error', failure.message),
      (response) {
        final updatedItem = PaymentScheduleMasterModel.fromJson(
          response['data'][0],
        );

        if (state.paymentScheduleMasterList.isNotEmpty &&
            index < state.paymentScheduleMasterList.length) {
          final updatedList = List<PaymentScheduleMasterModel>.from(
            state.paymentScheduleMasterList,
          );
          updatedList[index] = updatedItem;
          emit(state.copyWith(paymentScheduleMasterList: updatedList));
        }

        showSuccessMessage(
          context,
          subTitle: "Payment Schedule Master Updated Successfully!!!",
        );
      },
    );
  }

  // ----------------------------------------------------------
  // EXPORT
  // ----------------------------------------------------------
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _repository.exportPaymentScheduleMaster(
      pageNumber: 1,
      projectId: getProject().projectId,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"Stage": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
    );

    goRouter.pop();

    result.fold(
      (failure) => showErrorMessage(context, 'Error', failure.message),
      (response) {
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "paymentScheduleMaster_${DateTime.now()}.pdf"
              : "paymentScheduleMaster_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
