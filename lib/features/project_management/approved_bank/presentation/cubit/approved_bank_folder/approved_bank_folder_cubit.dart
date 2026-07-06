import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_folder.model.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/repository/approved_bank.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'approved_bank_folder_state.dart';

class ApprovedBankFolderCubit extends Cubit<ApprovedBankFolderState> {
  ApprovedBankFolderCubit() : super(ApprovedBankFolderState.initial());

  final ApprovedBankRepository _approvedBankRepository =
      serviceLocator<ApprovedBankRepository>();

  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // GET APPROVED BANK FOLDER LIST
  Future getApprovedBankFolderList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true, approvedBankFolderList: []));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    Map<String, dynamic> queryParams = {"BankName": state.searchTextFolder};
    var result = await _approvedBankRepository.getApprovedBankFolderList(
      pageSize: pageSize,
      pageNumber: pageNumber,
      projectId: projectId,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<ApprovedBankFolderModel> updatedList = List.from(
          state.approvedBankFolderList,
        );
        updatedList.addAll(response['data'] as List<ApprovedBankFolderModel>);
        emit(
          state.copyWith(isLoading: false, approvedBankFolderList: updatedList),
        );
      },
    );
  }

  // GET BANK LIST
  Future getBankList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    var result = await _employeeMasterRepository.getBankList(
      pageNumber: pageNumber,
      pageSize: 20,
      query: {'BankName': state.searchTextBank},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<BankListMasterModel> newData =
            response['data'] as List<BankListMasterModel>;

        final List<BankListMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.bankList, ...newData];

        emit(
          state.copyWith(
            bankList: updatedList,
            isLoading: false,
            totalNumberOfRecordBank: response["totalNumberOfRecord"],
            currentPageBank: pageNumber,
          ),
        );
      },
    );
  }

  // SEARCH FOLDER
  Future searchFolder(BuildContext context, String value, int projectId) async {
    emit(state.copyWith(searchTextFolder: value, approvedBankFolderList: []));
    await getApprovedBankFolderList(context, 1, 1000, projectId);
  }

  Future searchBank(BuildContext context, String value, int projectId) async {
    emit(
      state.copyWith(searchTextBank: value, bankList: [], currentPageBank: 1),
    );
    await getBankList(context, 1);
  }

  // ADD APPROVED BANK FOLDER
  Future addApproveBankFolder({
    required BuildContext context,
    required int projectId,
    required String bankListMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "ApprovedBankFolderId": 0,
      "ProjectId": projectId,
      "BankListMasterId": bankListMasterId.toString(),
    };
    var addResult = await _approvedBankRepository.addUpdateApprovedBankFolder(
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
        showSuccessMessage(context);
      },
    );
  }

  // DELETE APPROVED BANK FOLDER
  Future deleteApprovedBankFolder({
    required BuildContext context,
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
    required int pageNumber,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _approvedBankRepository.deleteApprovedBankFolder(
      approvedBankFolderId: approvedBankFolderId,
      projectId: projectId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context);
        if (index != null) {
          final updatedList = List<ApprovedBankFolderModel>.from(
            state.approvedBankFolderList,
          );
          updatedList.removeAt(index);

          emit(state.copyWith(approvedBankFolderList: updatedList));
        } else {
          getApprovedBankFolderList(context, pageNumber, pageSize, projectId);
        }
      },
    );
  }
}
