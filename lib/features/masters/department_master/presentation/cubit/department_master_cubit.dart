import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'department_master_state.dart';

class DepartmentMasterCubit extends Cubit<DepartmentMasterState> {
  DepartmentMasterCubit() : super(DepartmentMasterState.initial());

  final DepartmentMasterRepository _departmentMasterRepository =
      serviceLocator<DepartmentMasterRepository>();

  // <---- GET DEPARTMENT LIST ---->
  Future getDepartmentList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "DepartmentName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _departmentMasterRepository.getDepartmentList(
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
        final List<DepartmentModel> newData = List<DepartmentModel>.from(
          response['data'] ?? [],
        );

        final List<DepartmentModel> updatedList =
            pageNumber == 1 ? newData : [...state.departmentList, ...newData];
        emit(
          state.copyWith(
            departmentList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD DEPARTMENT ---->
  Future addDepartmentMaster({
    required BuildContext context,
    required String departmentCode,
    required String departmentName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "DepartmentMasterId": 0,
      "DepartmentCode": departmentCode,
      "DepartmentName": departmentName,
    };
    var addResult = await _departmentMasterRepository.addUpdateDepartment(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final newDepartment = response['data'][0] as DepartmentModel;

        // Try to update parent cubit first (when called from AddDepartmentScreen)
        var list = [newDepartment, ...state.departmentList];
        emit(
          state.copyWith(
            departmentList: list,
            totalNumberOfRecord:
                state.totalNumberOfRecord == -1
                    ? 1
                    : state.totalNumberOfRecord + 1,
          ),
        );

        showSuccessMessage(
          context,
          subTitle: 'Department Added Successfully!!!',
        );
      },
    );
  }

  // <---- UPDATE DEPARMTENT ---->
  Future updateDepartmentMaster({
    required BuildContext context,
    required int departmentMasterId,
    required String uniqueKey,
    required String departmentCode,
    required String departmentName,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "DepartmentMasterId": departmentMasterId,
      "Uniquekey": uniqueKey,
      "DepartmentCode": departmentCode,
      "DepartmentName": departmentName,
    };
    var addResult = await _departmentMasterRepository.addUpdateDepartment(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedDepartment = response['data'][0] as DepartmentModel;

        if (state.departmentList.isNotEmpty &&
            index < state.departmentList.length) {
          final updatedList = List<DepartmentModel>.from(state.departmentList);
          updatedList[index] = updatedDepartment;
          emit(state.copyWith(departmentList: updatedList, isLoading: false));
        }

        showSuccessMessage(
          context,
          subTitle: 'Department Updated Successfully!!!',
        );
      },
    );
  }

  // <---- DELETE DEPARTMENT ---->
  Future deleteDepartmentMaster({
    required BuildContext context,
    required int departmentMasterId,
    required String uniqueKey,
    required int pageNumber,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _departmentMasterRepository.deleteDepartment(
      departmentMasterId: departmentMasterId,
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

          emit(state.copyWith(departmentList: updatedList));
        } else {
          getDepartmentList(context, state.currentPage);
        }
      },
    );
  }

  // <---- SEARCH DEPARTMENT ---->
  Future searchDepartment(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, departmentList: []));
    await getDepartmentList(context, 1);
  }

  // <---- SORT DEPARTMENT ---->
  Future sortDepartment(
    BuildContext context,
    String value,
    String direction,
  ) async {
    emit(
      state.copyWith(
        currentSortColumn: value,
        currentSortDirection: direction,
        departmentList: [],
      ),
    );
    await getDepartmentList(context, 1);
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _departmentMasterRepository.exportDepartment(
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
              ? "department_${DateTime.now()}.pdf"
              : "department_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
