import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/repository/branch_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'branch_master_state.dart';

class BranchMasterCubit extends Cubit<BranchMasterState> {
  BranchMasterCubit() : super(BranchMasterState.initial());

  final BranchMasterRepository _branchMasterRepository =
      serviceLocator<BranchMasterRepository>();

  // <---- RESET STATE ---->
  void resetState() {
    emit(BranchMasterState.initial());
  }

  // <---- SEARCH BRANCH (same as AssetMapping) ---->
  void searchBranch(String value, BuildContext context) {
    emit(
      state.copyWith(
        branchList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );

    getBranchList(context: context, pageNumber: 1);
  }

  // <---- GET BRANCH LIST ---->
  Future getBranchList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    final queryParams = {
      "BranchName": state.searchText,
      "BranchCode": state.filterBranchCode,
      "Location": state.filterBranchLocation,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    final result = await _branchMasterRepository.getBranchList(
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
        final List<BranchMasterModel> newData = List<BranchMasterModel>.from(
          response['data'] ?? [],
        );

        final List<BranchMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.branchList, ...newData];

        emit(
          state.copyWith(
            branchList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD BRANCH ---->
  Future addBranchMaster({
    required BuildContext context,
    required String branchCode,
    required String branchName,
    required String location,
    required bool isHeadOffice,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final body = {
      "BranchMasterId": 0,
      "BranchCode": branchCode,
      "BranchName": branchName,
      "Location": location,
      "IsHeadOffice": isHeadOffice,
    };

    final result = await _branchMasterRepository.addUpdateBranch(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Branch Added Successfully');
      },
    );
  }

  // <---- UPDATE BRANCH ---->
  Future updateBranchMaster({
    required BuildContext context,
    required int branchMasterId,
    required String uniqueKey,
    required String branchCode,
    required String branchName,
    required String location,
    required bool isHeadOffice,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final body = {
      "BranchMasterId": branchMasterId,
      "Uniquekey": uniqueKey,
      "BranchCode": branchCode,
      "BranchName": branchName,
      "Location": location,
      "IsHeadOffice": isHeadOffice,
    };

    final result = await _branchMasterRepository.addUpdateBranch(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        final updatedDepartment = response['data'][0] as BranchMasterModel;

        if (state.branchList.isNotEmpty && index < state.branchList.length) {
          final updatedList = List<BranchMasterModel>.from(state.branchList);
          updatedList[index] = updatedDepartment;
          emit(state.copyWith(branchList: updatedList, isLoading: false));
        }

        showSuccessMessage(context, subTitle: 'Branch Updated Successfully');
      },
    );
  }

  // <---- DELETE BRANCH ---->
  Future deleteBranchMaster({
    required BuildContext context,
    required int branchMasterId,
    required String uniqueKey,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _branchMasterRepository.deleteBranch(
      branchMasterId: branchMasterId,
      uniqueKey: uniqueKey,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (success) {
        final updatedList = List<BranchMasterModel>.from(state.branchList);
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            branchList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: 'Branch Deleted Successfully');
      },
    );
  }

  // <---- EXPORT ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _branchMasterRepository.exportBranch(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {"ExportType": exportType, "BranchName": state.searchText},
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
              ? "branch_${DateTime.now()}.pdf"
              : "branch_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future<void> applyFilterAndSort({
    required BuildContext context,
    required String filterBranchCode,
    required String filterBranchLocation,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        filterBranchCode: filterBranchCode,
        filterBranchLocation: filterBranchLocation,
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        branchList: [],
        currentPage: 1,
      ),
    );

    await getBranchList(context: context, pageNumber: 1);
  }
}
