import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/data/model/leave_credit_debit_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/data/repository/leave_credit_debit_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/model/leave_type_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/repository/leave_type_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'leave_credit_debit_master_state.dart';

class LeaveCreditDebitMasterCubit extends Cubit<LeaveCreditDebitMasterState> {
  LeaveCreditDebitMasterCubit() : super(LeaveCreditDebitMasterState.initial());

  // REPOSITORY
  final LeaveCreditDebitMasterRepository _leaveCreditDebitMasterRepository =
      serviceLocator<LeaveCreditDebitMasterRepository>();
  final DepartmentMasterRepository _departmentMasterRepository =
      serviceLocator<DepartmentMasterRepository>();
  final DesignationMasterRepository _designationMasterRepository =
      serviceLocator<DesignationMasterRepository>();
  final LeaveTypeMasterRepository _leaveTypeMasterRepository =
      serviceLocator<LeaveTypeMasterRepository>();

  // HELPER METHOD
  String getEncodedList(List<dynamic> list) {
    String encodedList = jsonEncode(list);
    return encodedList;
  }

  // <---- SEARCH DEPARTMENT ---->
  Future searchLeaveCreditDebit(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, leaveCreditDebitMasterList: []));
    await getLeaveCreditDebitList(context, 1);
  }

  // <---- GET DEPARTMENT LIST ---->
  Future getLeaveCreditDebitList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    var queryParams = {"DepartmentName": state.searchText};
    var result = await _leaveCreditDebitMasterRepository
        .getLeaveCreditDebitList(
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
        final List<LeaveCreditDebitMasterModel> newData =
            List<LeaveCreditDebitMasterModel>.from(response['data'] ?? []);

        final List<LeaveCreditDebitMasterModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.leaveCreditDebitMasterList, ...newData];
        emit(
          state.copyWith(
            leaveCreditDebitMasterList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD LEAVE CREDIT DEBIT MASTER ---->
  Future addLeaveCreditDebitMaster({
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
    var addResult = await _leaveCreditDebitMasterRepository
        .addUpdateLeaveCreditDebitMaster(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        // Refresh the list to show the newly added item
        getLeaveCreditDebitList(context, 1);
        showSuccessMessage(context, subTitle: 'Added Successfully!!!');
      },
    );
  }

  // <---- UPDATE LEAVE CREDIT DEBIT MASTER ---->
  Future updateLeaveCreditDebitMaster({
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
    var updateResult = await _leaveCreditDebitMasterRepository
        .addUpdateLeaveCreditDebitMaster(body: requestBody);
    goRouter.pop();
    updateResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedLeaveCreditDebit = LeaveCreditDebitMasterModel.fromJson(
          response['data'][0],
        );

        if (state.leaveCreditDebitMasterList.isNotEmpty &&
            index < state.leaveCreditDebitMasterList.length) {
          final updatedList = List<LeaveCreditDebitMasterModel>.from(
            state.leaveCreditDebitMasterList,
          );
          updatedList[index] = updatedLeaveCreditDebit;
          emit(
            state.copyWith(
              leaveCreditDebitMasterList: updatedList,
              isLoading: false,
            ),
          );
        } else {
          getLeaveCreditDebitList(context, 1);
        }

        showSuccessMessage(context, subTitle: 'Updated Successfully!!!');
      },
    );
  }

  // <---- DELETE DEPARTMENT ---->
  Future deleteLeaveCreditDebitMaster({
    required BuildContext context,
    required int leaveCreditConfigurationId,
    required String uniqueKey,
    required int pageNumber,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _leaveCreditDebitMasterRepository
        .deleteLeaveCreditDebit(
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
          getLeaveCreditDebitList(context, state.currentPage);
        }
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _leaveCreditDebitMasterRepository.exportLeaveCreditDebit(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"DepartmentName": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
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
        showErrorMessage(context, "Error Message", failure.message);
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
            departmentTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- GET DEPARTMENT LIST ---->
  Future<void> getDepartmentList(
    BuildContext context,
    int pageNumber,
    int pageSize,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _departmentMasterRepository.getDepartmentList(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final newData = List<DepartmentModel>.from(response['data']);

        final List<DepartmentModel> updatedList =
            pageNumber == 1 ? newData : [...state.departmentList, ...newData];

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            departmentList: updatedList,
            departmentTotalCount: totalCount,
          ),
        );
      },
    );
  }

  // <---- GET DESIGNATION LIST ---->
  Future<void> getDesignationList(
    BuildContext context,
    int pageNumber,
    int pageSize,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _designationMasterRepository.getDesignationList(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error Message", failure.message);
      },
      (response) {
        final newData = List<DesignationMasterModel>.from(response['data']);

        final List<DesignationMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.designationList, ...newData];

        final totalCount = response['totalNumberOfRecord'] ?? 0;

        emit(
          state.copyWith(
            isLoading: false,
            designationList: updatedList,
            designationTotalCount: totalCount,
          ),
        );
      },
    );
  }
}
