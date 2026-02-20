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

class PaymentScheduleSummaryCubit extends Cubit<PaymentScheduleSummaryState> {
  PaymentScheduleSummaryCubit() : super(PaymentScheduleSummaryState.initial());

  // REPOSITORY
  final PaymentScheduleSummaryRepository _repository =
      serviceLocator<PaymentScheduleSummaryRepository>();

  // ------------------ ON TAB CHANGED ------------------
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
  }

  // ------------------ ON BUILDING CHANGED ------------------
  void onBuildingChanged(int buildingId, BuildContext context) {
    final ProjectInventoryStructure? selectedBuilding = state.buildingList
        .firstWhereOrNull((b) => b.buildingId == buildingId);

    // Update wing list based on selected building
    final List<String> wingList =
        selectedBuilding != null
            ? state.projectInventoryList
                .where((e) => e.buildingId == buildingId)
                .map((e) => e.wing ?? '')
                .toSet()
                .toList()
            : <String>[];

    emit(
      state.copyWith(
        selectedBuilding: selectedBuilding,
        wingList: wingList,
        selectedWing: wingList.isNotEmpty ? wingList.first : null,
      ),
    );
  }

  // ------------------ ON WING CHANGED ------------------
  void onWingChanged(String wing, BuildContext context) {
    emit(state.copyWith(selectedWing: wing));
  }

  // ------------------ GET PROJECT INVENTORY STRUCTURE ------------------
  Future getProjectInventoryStructure(
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
      ),
    );

    var result = await _repository.getProjectInventoryStructure(
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

        // Unique Building List
        final Map<int, ProjectInventoryStructure> uniqueBuildings = {};
        for (var item in newData) {
          uniqueBuildings[item.buildingId] = item;
        }

        // Unique Flat Configuration List
        final List<String> flatConfigs =
            newData.map((e) => e.flatConfiguration).toSet().toList();

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

  // ------------------ GET COST SHEET REPORT ------------------
  Future getCostSheetReport(
    BuildContext context,
    int pageNumber,
    int projectId,
    Map<String, dynamic> queryParams,
  ) async {
    emit(state.copyWith(isLoading: true, costSheetReportList: []));

    var result = await _repository.getCostSheetReport(
      pageNumber: pageNumber,
      pageSize: 500,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        // Assuming you have a CostSheetReport model
        final List<CostSheetReport> newData = List<CostSheetReport>.from(
          response['data'] ?? [],
        );

        emit(state.copyWith(costSheetReportList: newData, isLoading: false));
      },
    );
  }

  // ------------------ GET PAYMENT SCHEDULE MASTER REPORT ------------------
  Future getPaymentScheduleMasterReport(
    BuildContext context,
    int pageNumber,
    int projectId,
    Map<String, dynamic> queryParams,
  ) async {
    emit(state.copyWith(isLoading: true, paymentScheduleMasterReportList: []));

    var result = await _repository.getPaymentScheduleMasterReport(
      pageNumber: pageNumber,
      pageSize: 500,
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

        emit(
          state.copyWith(
            paymentScheduleMasterReportList: newData,
            isLoading: false,
          ),
        );
      },
    );
  }
}
