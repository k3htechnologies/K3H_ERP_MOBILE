import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/data/model/payment_schedule.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/data/respository/payment_schedule.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule/presentation/cubit/payment_schedule_state.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class PaymentScheduleCubit extends Cubit<PaymentScheduleMasterState> {
  PaymentScheduleCubit() : super(PaymentScheduleMasterState.initial());

  // REPOSITORIES
  final PaymentScheduleRepository _repository =
      serviceLocator<PaymentScheduleRepository>();

  void reset() {
    emit(state.copyWith(isLoading: false));
  }

  // SEARCH
  Future searchPaymentScheduleMaster(
    BuildContext context,
    String value, {
    required PaymentScheduleSchemeModel scheme,
  }) async {
    emit(state.copyWith(searchText: value, paymentScheduleMasterList: []));
    await getPaymentScheduleMasterList(context, 1, scheme: scheme);
  }

  // GET LIST
  Future getPaymentScheduleMasterList(
    BuildContext context,
    int pageNumber, {
    required PaymentScheduleSchemeModel scheme,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "Stage": state.searchText,
      "PaymentScheduleSchemeMasterId": scheme.paymentScheduleSchemeMasterId,
      "InventoryBuildingId": scheme.inventoryBuildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          scheme.inventoryFlatFloorBasementPodiumWingId,
    };

    var result = await _repository.getPaymentScheduleMasterList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: scheme.projectId,
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
            totalCumulativePercentage: calculateTotalCumulative(updatedList),
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  double calculateTotalCumulative(List<PaymentScheduleMasterModel> list) {
    return list.fold(0.0, (sum, item) => sum + item.paymentSchedulePercentage);
  }

  // ADD / UPDATE
  Future addPaymentScheduleMaster({
    required BuildContext context,
    required int buildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required String stage,
    required double paymentSchedulePercentage,
    required PaymentScheduleSchemeModel scheme,
  }) async {
    final double cumulativePercentage =
        state.totalCumulativePercentage + paymentSchedulePercentage;

    if (cumulativePercentage > 100) {
      showErrorMessage(
        context,
        'Error',
        'Total cumulative percentage cannot exceed 100%',
      );
      return;
    }

    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "PaymentScheduleMasterId": 0,
      "ProjectId": getProject().projectId,
      "InventoryBuildingId": buildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
      "Stage": stage,
      "PaymentSchedulePercentage": paymentSchedulePercentage,
      "PaymentCummulativePercentage": cumulativePercentage,
      "PaymentScheduleSchemeMasterId": scheme.paymentScheduleSchemeMasterId,
    };

    var result = await _repository.addUpdatePaymentScheduleMaster(
      body: requestBody,
    );

    goRouter.pop();

    result.fold(
      (failure) => showErrorMessage(context, 'Error', failure.message),
      (response) {
        showSuccessMessage(
          context,
          subTitle: "Payment Schedule added successfully",
        );

        getPaymentScheduleMasterList(context, 1, scheme: scheme);

        goRouter.pop();
      },
    );
  }

  Future updatePaymentScheduleMaster({
    required BuildContext context,
    required int paymentScheduleMasterId,
    required String uniqueKey,
    required int buildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required String stage,
    required double paymentSchedulePercentage,
    required int index,
    required int paymentScheduleSchemeMasterId,
  }) async {
    final oldPercentage =
        state.paymentScheduleMasterList[index].paymentSchedulePercentage;

    final double cumulativePercentage =
        state.totalCumulativePercentage -
        oldPercentage +
        paymentSchedulePercentage;

    if (cumulativePercentage > 100) {
      showErrorMessage(
        context,
        'Error',
        'Total cumulative percentage cannot exceed 100%',
      );
      return;
    }
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "PaymentScheduleMasterId": paymentScheduleMasterId,
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId,
      "InventoryBuildingId": buildingId,
      "InventoryFlatFloorBasementPodiumWingId":
          inventoryFlatFloorBasementPodiumWingId,
      "Stage": stage,
      "PaymentSchedulePercentage": paymentSchedulePercentage,
      "PaymentCummulativePercentage": cumulativePercentage,
      "PaymentScheduleSchemeMasterId": paymentScheduleSchemeMasterId,
    };

    var result = await _repository.addUpdatePaymentScheduleMaster(
      body: requestBody,
    );

    goRouter.pop();

    result.fold(
      (failure) => showErrorMessage(context, 'Error', failure.message),
      (response) {
        final updatedItem = response['data'][0] as PaymentScheduleMasterModel;

        final updatedList = List<PaymentScheduleMasterModel>.from(
          state.paymentScheduleMasterList,
        );

        updatedList[index] = updatedItem;

        emit(
          state.copyWith(
            paymentScheduleMasterList: updatedList,
            totalCumulativePercentage: cumulativePercentage,
          ),
        );

        showSuccessMessage(
          context,
          subTitle: "Payment Schedule updated successfully",
        );

        goRouter.pop();
      },
    );
  }

  // <---- DELETE PAYMENT SCHEDULE  ---->
  Future deletePaymentSchedule(
    int index,
    PaymentScheduleMasterModel paymentScheduleMasterModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _repository.deletePaymentSchedule(
      paymentScheduleId: paymentScheduleMasterModel.paymentScheduleMasterId,
      uniqueKey: paymentScheduleMasterModel.uniquekey,
      projectId: getProject().projectId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<PaymentScheduleMasterModel>.from(
          state.paymentScheduleMasterList,
        );
        updatedList.removeAt(index);

        final newTotal = updatedList.fold(
          0.0,
          (sum, item) => sum + item.paymentSchedulePercentage,
        );

        emit(
          state.copyWith(
            paymentScheduleMasterList: updatedList,
            totalCumulativePercentage: newTotal,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(
          context,
          subTitle: "Payment Schedule Master Deleted Successfully",
        );
      },
    );
  }

  void selectScheme(PaymentScheduleSchemeModel scheme) {
    emit(
      state.copyWith(
        selectedScheme: scheme,
        paymentScheduleMasterList: [],
        totalCumulativePercentage: 0.0,
        currentPage: 1,
      ),
    );
  }

  void clearSelectedScheme() {
    emit(
      state.copyWith(
        selectedScheme: null,
        paymentScheduleMasterList: [],
        totalCumulativePercentage: 0.0,
        currentPage: 1,
      ),
    );
  }

  // EXPORT
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
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
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
