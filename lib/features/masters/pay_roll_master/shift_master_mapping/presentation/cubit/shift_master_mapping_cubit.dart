import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/repository/shift_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master_mapping/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master_mapping/data/repository/shift_master_mapping.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master_mapping/presentation/cubit/shift_master_mapping_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class ShiftMappingMasterCubit extends Cubit<ShiftMappingMasterState> {
  ShiftMappingMasterCubit() : super(ShiftMappingMasterState.initial());

  final ShiftMappingMasterRepository _shiftMasterMappingRepository =
      serviceLocator<ShiftMappingMasterRepository>();

  final ShiftMasterRepository _shiftMasterRepository =
      serviceLocator<ShiftMasterRepository>();

  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  final DepartmentMasterRepository _departmentMasterRepository =
      serviceLocator<DepartmentMasterRepository>();

  void resetState() {
    emit(ShiftMappingMasterState.initial());
  }

  //SEARCH
  void searchShiftMapping(String value, BuildContext context) {
    emit(
      state.copyWith(
        ShiftMappingList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getShiftMappingList(context: context, pageNumber: 1);
  }

  //GET SHIFT MAPPING
  Future getShiftMappingList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "ShiftName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await _shiftMasterMappingRepository.getShiftMasterMappedList(
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
        final List<ShiftMappingModel> newData = List<ShiftMappingModel>.from(
          response['data'] ?? [],
        );

        final List<ShiftMappingModel> updatedList =
            pageNumber == 1 ? newData : [...state.shiftMappingList, ...newData];

        emit(
          state.copyWith(
            ShiftMappingList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // ADD SHIFT MAPPING
  Future addShiftMapping({
    required BuildContext context,
    required String employeeId,
    required int shiftMasterId,
    required String departmentMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ShiftManagementMasterMappingId": 0,
      "EmployeeId": employeeId,
      "ShiftManagementMasterId": shiftMasterId,
      "DepartmentMasterId": departmentMasterId,
    };
    var result = await _shiftMasterMappingRepository.addUpdateShiftMapping(
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
        final newResponse = ShiftMappingModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        var list = [newResponse, ...state.shiftMappingList];
        emit(
          state.copyWith(
            ShiftMappingList: list,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
        showSuccessMessage(
          context,
          subTitle: 'Shift Mapping Added Successfully',
        );
      },
    );
  }

  //UPDATE SHIFT MAPPING
  Future updateShiftMapping({
    required int index,
    required BuildContext context,
    required String uniqueKey,
    required int shiftMappingMasterId,
    required String employeeId,
    required int shiftMasterId,
    required String departmentMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ShiftManagementMasterMappingId": shiftMappingMasterId,
      "UniqueKey": uniqueKey,
      "EmployeeId": employeeId,
      "ShiftManagementMasterId": shiftMasterId,
      "DepartmentMasterId": departmentMasterId,
    };
    var result = await _shiftMasterMappingRepository.addUpdateShiftMapping(
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
        final updatedList = ShiftMappingModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.shiftMappingList.isNotEmpty &&
            index < state.shiftMappingList.length) {
          final updatedListModel = List<ShiftMappingModel>.from(
            state.shiftMappingList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(ShiftMappingList: updatedListModel));
        }

        showSuccessMessage(
          context,
          subTitle: "Shift Mapping Updated Successfully",
        );
      },
    );
  }

  // DELETE SHIFT MAPPING
  Future deleteShiftMapping(
    int index,
    ShiftMappingModel ShiftMapping,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _shiftMasterMappingRepository.deleteShiftMapping(
      shiftMasterMappingId: ShiftMapping.shiftMappingMasterId,
      uniqueKey: ShiftMapping.uniqueKey,
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
          subTitle: "Shift Mapping Deleted Successfully",
        );
        getShiftMappingList(context: context, pageNumber: state.currentPage);
      },
    );
  }

  // EXPORT
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _shiftMasterMappingRepository
        .getShiftMasterMappedListForExport(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          queryParams: {
            "ExportType": exportType,
            "EmployeeName": state.searchText,
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
              ? "Shift_mapping_${DateTime.now()}.pdf"
              : "Shift_mapping_${DateTime.now()}.xlsx",
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

  // FETCH SHIFT LIST FOR DROPDOWN
  Future<Map<String, dynamic>> fetchShift(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _shiftMasterRepository.getShiftList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"ShiftName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final shift = response['data'] as List<ShiftMasterModel>;

        return {
          "itemList":
              shift.map((employee) {
                return {
                  "zAttributesId": employee.shiftManagementMasterId,
                  "DisplayName": employee.shiftName,
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
        final department = response['data'] as List<DepartmentModel>;

        return {
          "itemList":
              department.map((employee) {
                return {
                  "zAttributesId": employee.departmentMasterId,
                  "DisplayName": employee.departmentName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }
}
