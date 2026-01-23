import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'leave_credit_debit_master_state.dart';

class LeaveCreditDebitMasterCubit extends Cubit<LeaveCreditDebitMasterState> {
  LeaveCreditDebitMasterCubit() : super(LeaveCreditDebitMasterState.initial());

  // REPOSITORY
  final DepartmentMasterRepository _departmentMasterRepository =
      serviceLocator<DepartmentMasterRepository>();
  final DesignationMasterRepository _designationMasterRepository =
      serviceLocator<DesignationMasterRepository>();

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
