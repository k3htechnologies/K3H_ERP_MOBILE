import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/cost_sheet.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/payment_schedule_master_report.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/project_inventory_structure.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/repository/payment_schedule_summary.repository.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/presentation/cubit/payment_schedule_summary_state.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class PaymentScheduleSummaryCubit extends Cubit<PaymentScheduleSummaryState> {
  PaymentScheduleSummaryCubit() : super(PaymentScheduleSummaryState.initial());

  final PaymentScheduleSummaryRepository _repository =
      serviceLocator<PaymentScheduleSummaryRepository>();

  // ------------------ TAB CHANGED ------------------
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

  // ------------------ BUILDING CHANGED ------------------
  void onBuildingChanged(int buildingId) {
    final selectedBuilding = state.buildingList.firstWhereOrNull(
      (e) => e.buildingId == buildingId,
    );
    if (selectedBuilding == null) return;
    if (state.selectedBuilding?.buildingId == buildingId) return;

    final filteredInventory =
        state.projectInventoryList
            .where((e) => e.buildingId == buildingId)
            .toList();

    final List<String> wings =
        filteredInventory
            .map((e) => e.wing)
            .where((e) => e.isNotEmpty)
            .cast<String>()
            .toSet()
            .toList();

    emit(
      state.copyWith(
        selectedBuilding: selectedBuilding,
        wingList: wings,
        selectedWing: null,
        // reset pagination when building changes
        paymentScheduleCurrentPage: 1,
        paymentScheduleTotalRecords: 0,
        costSheetCurrentPage: 1,
        costSheetTotalRecords: 0,
      ),
    );
  }

  // ------------------ WING CHANGED ------------------
  void onWingChanged(
    String wing,
    BuildContext context,
    TextEditingController rateController,
  ) async {
    if (state.selectedWing == wing || state.isLoading!) return;

    emit(state.copyWith(selectedWing: wing));

    if (state.selectedBuilding == null) return;

    final rate = int.tryParse(rateController.text.trim()) ?? 0;

    final queryParams = {
      "Wing": wing,
      "BuildingId": state.selectedBuilding!.buildingId,
      "Rate": rate,
      "PaymentScheduleMasterId": 0,
      "FlatConfiguration": state.selectedFlatConfiguration,
    };

    await fetchData(context, 1, queryParams);
  }

  // ------------------ FLAT CONFIGURATION CHANGED ------------------
  void onFlatConfigurationChanged(
    String config,
    BuildContext context,
    TextEditingController rateController,
  ) async {
    if (state.selectedFlatConfiguration == config || state.isLoading!) return;

    emit(state.copyWith(selectedFlatConfiguration: config));

    if (state.selectedBuilding == null || state.selectedWing == null) return;

    final rate = int.tryParse(rateController.text.trim()) ?? 0;

    final queryParams = {
      "Wing": state.selectedWing,
      "BuildingId": state.selectedBuilding!.buildingId,
      "Rate": rate,
      "PaymentScheduleMasterId": 0,
      "FlatConfiguration": config,
    };

    await fetchData(context, 1, queryParams);
  }

  // ------------------ RATE CHANGED ------------------
  void onRateChanged(String val, BuildContext context) {
    if (state.selectedBuilding == null ||
        state.selectedWing == null ||
        state.isLoading!) {
      return;
    }
    final rate = int.tryParse(val.trim()) ?? 0;

    final queryParams = {
      "Wing": state.selectedWing,
      "BuildingId": state.selectedBuilding!.buildingId,
      "Rate": rate,
      "PaymentScheduleMasterId": 0,
      "FlatConfiguration": state.selectedFlatConfiguration,
    };

    fetchData(context, 1, queryParams);
  }

  // ------------------ FETCH DATA ------------------
  Future<void> fetchData(
    BuildContext context,
    int pageNumber,
    Map<String, dynamic> queryParams,
  ) async {
    if (state.currentTabIndex == 1) {
      await getPaymentScheduleMasterReport(
        context,
        pageNumber,
        getProject().projectId,
        queryParams,
      );
    } else {
      await getCostSheetReport(
        context,
        pageNumber,
        getProject().projectId,
        queryParams,
      );
    }
  }

  // ------------------ GET PAYMENT SCHEDULE MASTER REPORT ------------------
  Future<void> getPaymentScheduleMasterReport(
    BuildContext context,
    int pageNumber,
    int projectId,
    Map<String, dynamic> queryParams,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getPaymentScheduleMasterReport(
      pageNumber: pageNumber,
      pageSize: 100,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<PaymentScheduleMasterReport> newData =
            List<PaymentScheduleMasterReport>.from(response['data'] ?? []);

        final List<PaymentScheduleMasterReport> updatedList =
            pageNumber == 1
                ? newData
                : [...state.paymentScheduleReportList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            paymentScheduleReportList: updatedList,
            paymentScheduleCurrentPage: pageNumber,
            paymentScheduleTotalRecords: response["totalNumberOfRecord"] ?? 0,
          ),
        );
      },
    );
  }

  // ------------------ GET COST SHEET REPORT ------------------
  Future<void> getCostSheetReport(
    BuildContext context,
    int pageNumber,
    int projectId,
    Map<String, dynamic> queryParams,
  ) async {
    final List<CostSheetReport> existingData =
        pageNumber == 1
            ? <CostSheetReport>[]
            : List<CostSheetReport>.from(state.costSheetReportList);

    emit(state.copyWith(isLoading: true, costSheetReportList: existingData));

    final result = await _repository.getCostSheetReport(
      pageNumber: pageNumber,
      pageSize: 20,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<CostSheetReport> newData = List<CostSheetReport>.from(
          response['data'] ?? [],
        );

        final combinedData = [...existingData, ...newData];

        emit(
          state.copyWith(
            costSheetReportList: combinedData,
            isLoading: false,
            costSheetCurrentPage: pageNumber,
            costSheetTotalRecords: response['totalNumberOfRecord'] ?? 0,
          ),
        );
      },
    );
  }

  // ------------------ GET PROJECT INVENTORY ------------------
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
        flatConfigurationList: [],
        wingList: [],
        selectedBuilding: null,
        selectedWing: null,
        paymentScheduleCurrentPage: 1,
        paymentScheduleTotalRecords: 0,
        costSheetCurrentPage: 1,
        costSheetTotalRecords: 0,
      ),
    );

    final result = await _repository.getProjectInventoryStructure(
      pageNumber: pageNumber,
      pageSize: 10,
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
          uniqueBuildings[item.buildingId] = item;
        }

        final List<String> flatConfigs =
            newData
                .map((e) => e.flatConfiguration)
                .where((e) => e.trim().isNotEmpty)
                .map((e) => e.trim())
                .toSet()
                .toList();

        emit(
          state.copyWith(
            projectInventoryList: newData,
            buildingList: uniqueBuildings.values.toList(),
            flatConfigurationList: flatConfigs,
            selectedFlatConfiguration:
                flatConfigs.isNotEmpty ? flatConfigs.first : '',
            isLoading: false,
          ),
        );
      },
    );
  }

  // ------------------ CLEAR COST SHEET ------------------
  void clearCostSheetList() {
    emit(
      state.copyWith(
        costSheetReportList: [],
        costSheetCurrentPage: 1,
        costSheetTotalRecords: 0,
      ),
    );
  }
}
