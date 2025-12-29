import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/datasource/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'bank_list_master_state.dart';

class BankListMasterCubit extends Cubit<BankListMasterState> {
  BankListMasterCubit() : super(BankListMasterState.initial());

  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  Future getBankList(BuildContext context, int pageNumber, int pageSize) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"BankName": state.searchText};
    var result = await _employeeMasterRepository.getBankList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      query: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        final mappedList = dataList
            .map((e) => BankListMasterModel.fromJson(e as Map<String, dynamic>))
            .toList();
        List<BankListMasterModel> updatedList = pageNumber == 1
            ? mappedList
            : [...state.bankList, ...mappedList];
        emit(
          state.copyWith(
            isLoading: false,
            bankList: updatedList,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- SEARCH BANK ---->
  Future searchBank(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, bankList: []));
    await getBankList(context, 1, 20);
  }
}
