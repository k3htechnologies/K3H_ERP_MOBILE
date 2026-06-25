import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/model/leave_credit_configuration_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/repository/leave_credit_configuration_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/repository/leave_type_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'leave_credit_configuration_master_state.dart';

class LeaveCreditConfigurationMasterCubit
    extends Cubit<LeaveCreditConfigurationMasterState> {
  LeaveCreditConfigurationMasterCubit()
    : super(LeaveCreditConfigurationMasterState.initial());

  // REPOSITORY
  final LeaveCreditConfigurationMasterRepository
  _leaveCreditConfigurationMasterRepository =
      serviceLocator<LeaveCreditConfigurationMasterRepository>();
  final LeaveTypeMasterRepository _leaveTypeMasterRepository =
      serviceLocator<LeaveTypeMasterRepository>();

  // HELPER METHOD
  String getEncodedList(List<dynamic> list) {
    String encodedList = jsonEncode(list);
    return encodedList;
  }

  // <---- SEARCH DEPARTMENT ---->
  Future searchLeaveCreditConfiguration(
    BuildContext context,
    String value,
  ) async {
    emit(
      state.copyWith(searchText: value, leaveCreditConfigurationMasterList: []),
    );
    await getLeaveCreditConfigurationList(context, 1);
  }

  // <---- GET DEPARTMENT LIST ---->
  Future getLeaveCreditConfigurationList(
    BuildContext context,
    int pageNumber,
  ) async {
    emit(state.copyWith(isLoading: true));
    var queryParams = {
      "DepartmentName": state.searchText,
      if (state.filterDesignationName.isNotEmpty)
        "DesignationName": state.filterDesignationName,
    };
    if (state.filterFromLeaveCreditDate != null) {
      queryParams["StartDate"] =
          state.filterFromLeaveCreditDate!.toIso8601String();
    }

    if (state.filterToLeaveCreditDate != null) {
      queryParams["EndDate"] = state.filterToLeaveCreditDate!.toIso8601String();
    }
    var result = await _leaveCreditConfigurationMasterRepository
        .getLeaveCreditConfigurationList(
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
        final List<LeaveCreditConfigurationMasterModel> newData =
            List<LeaveCreditConfigurationMasterModel>.from(
              response['data'] ?? [],
            );

        final List<LeaveCreditConfigurationMasterModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.leaveCreditConfigurationMasterList, ...newData];
        emit(
          state.copyWith(
            leaveCreditConfigurationMasterList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD LEAVE CREDIT DEBIT MASTER ---->
  Future addLeaveCreditConfigurationMaster({
    required BuildContext context,
    required String leavePeriodMode,
    required DateTime financialYearStartDate,
    required DateTime financialYearEndDate,
    required int departmentMasterId,
    required String designationIds,
    required List<dynamic> leaveBalanceTypeList,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "LeaveCreditConfigurationId": 0,
      "LeavePeriodMode": leavePeriodMode,
      "FinancialYearStartDate": financialYearStartDate.toIso8601String(),
      "FinancialYearEndDate": financialYearEndDate.toIso8601String(),
      "DepartmentMasterId": departmentMasterId,
      "DesignationId": designationIds,
      "LeaveTypebalanceJSONList": getEncodedList(leaveBalanceTypeList),
    };
    var addResult = await _leaveCreditConfigurationMasterRepository
        .addUpdateLeaveCreditConfigurationMaster(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        // Refresh the list to show the newly added item
        getLeaveCreditConfigurationList(context, 1);
        showSuccessMessage(context, subTitle: 'Added Successfully!!!');
      },
    );
  }

  // <---- UPDATE LEAVE CREDIT DEBIT MASTER ---->
  Future updateLeaveCreditConfigurationMaster({
    required BuildContext context,
    required int leaveCreditConfigurationId,
    required String uniquekey,
    required String leavePeriodMode,
    required DateTime financialYearStartDate,
    required DateTime financialYearEndDate,
    required int departmentMasterId,
    required String designationIds,
    required List<dynamic> leaveBalanceTypeList,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "LeaveCreditConfigurationId": leaveCreditConfigurationId,
      "Uniquekey": uniquekey,
      "LeavePeriodMode": leavePeriodMode,
      "FinancialYearStartDate": financialYearStartDate.toIso8601String(),
      "FinancialYearEndDate": financialYearEndDate.toIso8601String(),
      "DepartmentMasterId": departmentMasterId,
      "DesignationId": designationIds,
      "LeaveTypebalanceJSONList": getEncodedList(leaveBalanceTypeList),
    };
    var updateResult = await _leaveCreditConfigurationMasterRepository
        .addUpdateLeaveCreditConfigurationMaster(body: requestBody);
    goRouter.pop();
    updateResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        final updatedLeaveCreditConfiguration =
            response['data'][0] as LeaveCreditConfigurationMasterModel;

        if (state.leaveCreditConfigurationMasterList.isNotEmpty &&
            index < state.leaveCreditConfigurationMasterList.length) {
          final updatedList = List<LeaveCreditConfigurationMasterModel>.from(
            state.leaveCreditConfigurationMasterList,
          );
          updatedList[index] = updatedLeaveCreditConfiguration;

          emit(
            state.copyWith(
              leaveCreditConfigurationMasterList: updatedList,
              isLoading: false,
            ),
          );
        } else {
          getLeaveCreditConfigurationList(context, 1);
        }

        showSuccessMessage(context, subTitle: 'Updated Successfully!!!');
      },
    );
  }

  // <---- DELETE DEPARTMENT ---->
  Future deleteLeaveCreditConfigurationMaster({
    required BuildContext context,
    required int leaveCreditConfigurationId,
    required String uniqueKey,
    required int pageNumber,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _leaveCreditConfigurationMasterRepository
        .deleteLeaveCreditConfiguration(
          leaveCreditConfigurationId: leaveCreditConfigurationId,
          uniqueKey: uniqueKey,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Department Deleted Successfully!!!',
        );
        if (index != null) {
          final updatedList = List<DepartmentModel>.from(state.departmentList);
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              departmentList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getLeaveCreditConfigurationList(context, state.currentPage);
        }
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _leaveCreditConfigurationMasterRepository
        .exportLeaveCreditConfiguration(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          queryParams:
              state.searchText != ""
                  ? {
                    "DepartmentName": state.searchText,
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
              ? "leave_credit_debit_${DateTime.now()}.pdf"
              : "leave_credit_debit_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // <---- GET LEAVE TYPE LIST ---->
  Future<void> getLeaveTypeList(
    BuildContext context,
    int pageNumber,
    int pageSize,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _leaveTypeMasterRepository.getLeaveTypeList(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final newData = List<LeaveTypeModel>.from(response['data']);

        final List<LeaveTypeModel> updatedList =
            pageNumber == 1 ? newData : [...state.leaveTypeList, ...newData];

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            leaveTypeList: updatedList,
            totalNumberOfRecord: totalCount,
          ),
        );
      },
    );
  }

  Future<void> applyFilterAndSort({
    required BuildContext context,
    required String filterDepartmentName,
    required String filterDesignationName,
    required DateTime? filterFromLeaveCreditDate,
    required DateTime? filterToLeaveCreditDate,
  }) async {
    emit(
      state.copyWith(
        searchText: filterDepartmentName,
        filterDesignationName: filterDesignationName,
        filterFromLeaveCreditDate: filterFromLeaveCreditDate,
        filterToLeaveCreditDate: filterToLeaveCreditDate,
        leaveCreditConfigurationMasterList: [],
        currentPage: 1,
      ),
    );

    await getLeaveCreditConfigurationList(context, 1);
  }

  int updateLeaveCreditConfigurationFilterCount(
    LeaveCreditConfigurationMasterState state,
  ) {
    final hasDateFilter =
        state.filterFromLeaveCreditDate != null &&
        state.filterToLeaveCreditDate != null;

    final isValidDateRange =
        hasDateFilter &&  
        !state.filterFromLeaveCreditDate!.isAfter(
          DateTime(
            state.filterToLeaveCreditDate!.year,
            state.filterToLeaveCreditDate!.month,
            state.filterToLeaveCreditDate!.day,
          ),
        );

    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterDesignationName.trim().isNotEmpty,
      isValidDateRange,
    ]);
  }
}
