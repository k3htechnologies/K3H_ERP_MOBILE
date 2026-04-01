import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/inventory/data/repository/inventory.repository.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/data/repository/payment_schedule_scheme.repository.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_scheme/presentation/cubit/payment_schedule_scheme_state.dart';
import 'package:k3h_erp_app/features/inventory/data/model/project_inventory_structure.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class PaymentScheduleSchemeCubit extends Cubit<PaymentScheduleSchemeState> {
  PaymentScheduleSchemeCubit() : super(PaymentScheduleSchemeState.initial());

  // REPOSITORY
  final PaymentScheduleSchemeRepository _repository =
      serviceLocator<PaymentScheduleSchemeRepository>();
  final InventoryRepository _inventoryRepository =
      serviceLocator<InventoryRepository>();

  // SEARCH

  Future searchPaymentScheduleScheme(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: value, paymentScheduleSchemeList: []));
    await getPaymentScheduleSchemeList(context, 1, projectId);
  }

  // GET LIST

  Future getPaymentScheduleSchemeList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));

    Map<String, dynamic> queryParams = {
      "PaymentScheduleScheme": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await _repository.getPaymentScheduleSchemeList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<PaymentScheduleSchemeModel> newData =
            List<PaymentScheduleSchemeModel>.from(response['data'] ?? []);

        final updatedList =
            pageNumber == 1
                ? newData
                : [...state.paymentScheduleSchemeList, ...newData];

        emit(
          state.copyWith(
            paymentScheduleSchemeList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // ADD PAYMENT SCHEDULE SCHEME
  Future addPaymentScheduleScheme({
    required BuildContext context,
    required int projectId,
    required int buildingId,
    required int wingId,
    required String schemeName,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "PaymentScheduleSchemeMasterId": 0,
      "ProjectId": projectId,
      "InventoryBuildingId": buildingId,
      "InventoryFlatFloorBasementPodiumWingId": wingId,
      "PaymentScheduleScheme": schemeName,
      "OrderBy": orderBy,
    };

    var result = await _repository.addUpdatePaymentScheduleScheme(
      body: requestBody,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: "Payment Schedule Scheme Added Successfully!!!",
        );
        getPaymentScheduleSchemeList(context, 1, projectId);
      },
    );
  }

  // UPDATE PAYMENT SCHEDULE SCHEME
  Future updatePaymentScheduleScheme({
    required BuildContext context,
    required int paymentScheduleSchemeId,
    required String uniqueKey,
    required int buildingId,
    required int wingId,
    required String schemeName,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> requestBody = {
      "PaymentScheduleSchemeMasterId": paymentScheduleSchemeId,
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId,
      "InventoryBuildingId": buildingId,
      "InventoryFlatFloorBasementPodiumWingId": wingId,
      "PaymentScheduleScheme": schemeName,
      "OrderBy": 0,
    };

    var result = await _repository.addUpdatePaymentScheduleScheme(
      body: requestBody,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        final updatedItem = response['data'][0] as PaymentScheduleSchemeModel;

        if (state.paymentScheduleSchemeList.isNotEmpty &&
            index < state.paymentScheduleSchemeList.length) {
          final updatedList = List<PaymentScheduleSchemeModel>.from(
            state.paymentScheduleSchemeList,
          );

          updatedList[index] = updatedItem;

          emit(state.copyWith(paymentScheduleSchemeList: updatedList));
        }

        showSuccessMessage(
          context,
          subTitle: "Payment Schedule Scheme Updated Successfully!!!",
        );
      },
    );
  }

  // DELETE PAYMENT SCHEDULE SCHEME
  Future deletePaymentScheduleScheme(
    int index,
    PaymentScheduleSchemeModel paymentScheduleSchemeModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _repository.deletePaymentScheduleScheme(
      paymentScheduleSchemeId:
          paymentScheduleSchemeModel.paymentScheduleSchemeMasterId,
      uniqueKey: paymentScheduleSchemeModel.uniquekey,
      projectId: getProject().projectId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<PaymentScheduleSchemeModel>.from(
          state.paymentScheduleSchemeList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            paymentScheduleSchemeList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(
          context,
          subTitle: "Payment Schedule Scheme Deleted Successfully",
        );
      },
    );
  }

  // EXPORT PAYMENT SCHEDULE SCHEME

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);

    var result = await _repository.exportPaymentScheduleScheme(
      pageNumber: 1,
      projectId: getProject().projectId,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {
                "PaymentScheduleScheme": state.searchText,
                "ExportType": exportType,
              }
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
              ? "paymentScheduleScheme_${DateTime.now()}.pdf"
              : "paymentScheduleScheme_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // LOAD PROJECT INVENTORY
  Future<void> getProjectInventoryStructure(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        projectInventoryList: [],
        buildingList: [],
        wingList: [],
        selectedBuilding: null,
        selectedWing: null,
      ),
    );

    final result = await _inventoryRepository.getProjectInventoryStructure(
      pageNumber: pageNumber,
      pageSize: 100,
      projectId: projectId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ProjectInventoryStructure> newData =
            List<ProjectInventoryStructure>.from(response['data'] ?? []);

        final Map<int, ProjectInventoryStructure> uniqueBuildings = {};

        for (var item in newData) {
          uniqueBuildings[item.inventoryBuildingId] = item;
        }

        emit(
          state.copyWith(
            projectInventoryList: newData,
            buildingList: uniqueBuildings.values.toList(),
            wingList: [],
            selectedBuilding: null,
            selectedWing: null,
            isLoading: false,
          ),
        );
      },
    );
  }
}
