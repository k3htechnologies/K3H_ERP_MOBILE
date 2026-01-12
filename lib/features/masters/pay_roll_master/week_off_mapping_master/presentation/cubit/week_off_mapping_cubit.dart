import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/respository/week_off_mapping_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_state.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/model/week_off_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_master/data/repository/week_off_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class WeekOffMappingMasterCubit extends Cubit<WeekOffMappingMasterState> {
  WeekOffMappingMasterCubit() : super(WeekOffMappingMasterState.initial());

  final WeekOffMappingMasterRepository _weekOffMasterMappingRepository =
      serviceLocator<WeekOffMappingMasterRepository>();

  final WeekOffMasterRepository _weekOffMasterRepository =
      serviceLocator<WeekOffMasterRepository>();

  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  final DepartmentMasterRepository _departmentMasterRepository =
      serviceLocator<DepartmentMasterRepository>();

  void resetState() {
    emit(WeekOffMappingMasterState.initial());
  }

  //SEARCH
  void searchWeekOffMapping(String value, BuildContext context) {
    emit(
      state.copyWith(
        weekOffMappingList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getWeekOffMappingList(context: context, pageNumber: 1);
  }

  //GET WEEK OFF MAPPING
  Future getWeekOffMappingList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "WeekOffPolicyName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await _weekOffMasterMappingRepository.getWeekOffMappingList(
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
        final List<WeekOffMappingModel> newData =
            List<WeekOffMappingModel>.from(response['data'] ?? []);

        final List<WeekOffMappingModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.weekOffMappingList, ...newData];

        emit(
          state.copyWith(
            weekOffMappingList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // ADD WEEK OFF MAPPING
  Future addWeekOffMapping({
    required BuildContext context,
    required String employeeId,
    required int weekOffMasterId,
    required String departmentMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "WeekOffPolicyMasterMappingId": 0,
      "EmployeeId": employeeId,
      "WeekOffPolicyMasterId": weekOffMasterId,
      "DepartmentMasterId": departmentMasterId,
    };
    var result = await _weekOffMasterMappingRepository.addUpdateWeekOffMapping(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final newResponse = WeekOffMappingModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        var list = [newResponse, ...state.weekOffMappingList];
        emit(
          state.copyWith(
            weekOffMappingList: list,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
        showSuccessMessage(
          context,
          subTitle: 'Week Off Mapping Added Successfully',
        );
      },
    );
  }

  //UPDATE WEEK OFF MAPPING
  Future updateWeekOffMapping({
    required int index,
    required BuildContext context,
    required String uniqueKey,
    required int weekOffMappingMasterId,
    required String employeeId,
    required int weekOffMasterId,
    required String departmentMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "WeekOffPolicyMasterMappingId": weekOffMappingMasterId,
      "UniqueKey": uniqueKey,
      "EmployeeId": employeeId,
      "WeekOffPolicyMasterId": weekOffMasterId,
      "DepartmentMasterId": departmentMasterId,
    };
    var result = await _weekOffMasterMappingRepository.addUpdateWeekOffMapping(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = WeekOffMappingModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.weekOffMappingList.isNotEmpty &&
            index < state.weekOffMappingList.length) {
          final updatedListModel = List<WeekOffMappingModel>.from(
            state.weekOffMappingList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(weekOffMappingList: updatedListModel));
        }

        showSuccessMessage(
          context,
          subTitle: "Week Off Mapping Updated Successfully",
        );
      },
    );
  }

  // DELETE WEEK OFF MAPPING
  Future deleteWeekOffMapping(
    int index,
    WeekOffMappingModel weekOffMapping,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _weekOffMasterMappingRepository.deleteWeekOffMapping(
      weekOffMappingId: weekOffMapping.weekOffPolicyMasterMappingId,
      uniqueKey: weekOffMapping.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        showSuccessMessage(
          context,
          subTitle: "Week Off Mapping Deleted Successfully",
        );
        getWeekOffMappingList(context: context, pageNumber: state.currentPage);
      },
    );
  }

  // EXPORT
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _weekOffMasterMappingRepository
        .getWeekOffMappingForExport(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          queryParams: {
            "ExportType": exportType,
            "WeekOffName": state.searchText,
          },
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "weekOff_mapping_${DateTime.now()}.pdf"
              : "weekOff_mapping_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // FETCH EMPLOYEES LIST FOR DROPDOWN
  Future<Map<String, dynamic>> fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"EmployeeName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees = response['data'] as List<UserModel>;

        return {
          "itemList":
              employees.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH WEEK OFF LIST FOR DROPDOWN
  Future<Map<String, dynamic>> fetchWeekOff(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _weekOffMasterRepository.getWeekOffList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"WeekOffPolicyName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final weekOffList = response['data'] as List<WeekOffMasterModel>;

        return {
          "itemList":
              weekOffList.map((weekOff) {
                return {
                  "zAttributesId": weekOff.weekOffPolicyMasterId,
                  "DisplayName": weekOff.weekOffPolicyName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH DEPARTMENT LIST FOR DROPDOWN
  Future<Map<String, dynamic>> fetchDepartment(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _departmentMasterRepository.getDepartmentList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"DepartmentName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final departments = response['data'] as List<DepartmentModel>;

        return {
          "itemList":
              departments.map((department) {
                return {
                  "zAttributesId": department.departmentMasterId,
                  "DisplayName": department.departmentName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }
}
