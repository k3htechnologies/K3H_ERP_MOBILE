import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/model/deduction_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/repository/deduction_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'deduction_master_state.dart';

class DeductionMasterCubit extends Cubit<DeductionMasterState> {
  DeductionMasterCubit() : super(DeductionMasterState.initial());

  final DeductionMasterRepository deductionMasterRepository =
      serviceLocator<DeductionMasterRepository>();

  void resetState() {
    emit(DeductionMasterState.initial());
  }

  void searchAssetMapping(String value, BuildContext context) {
    emit(
      state.copyWith(
        deductionList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getDeductionList(context: context, pageNumber: 1);
  }

  Future getDeductionList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "Name": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await deductionMasterRepository.getDeductionList(
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
        final List<DeductionMasterModel> newData =
            List<DeductionMasterModel>.from(response['data'] ?? []);

        final List<DeductionMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.deductionList, ...newData];

        emit(
          state.copyWith(
            deductionList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addDeductionMapping({
    required BuildContext context,
    required String name,
    required String type,
    required double value,
    required int branchMasterId,
    required int stateMasterId,
    required double minSalary,
    required double maxSalary,
    required String gender,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "DeductionMasterId": 0,
      "Name": name,
      "Type": type,
      "Value": value,
      "BranchMasterId": branchMasterId,
      "StateMasterId": stateMasterId,
      "MinSalary": minSalary,
      "MaxSalary": maxSalary,
      "Gender": gender,
    };
    var result = await deductionMasterRepository.addUpdateDeduction(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Deduction Added Successfully');
      },
    );
  }

  Future updateDeduction({
    required int index,
    required BuildContext context,
    required int deductionMasterId,
    required String uniqueKey,
    required String name,
    required String type,
    required double value,
    required int branchMasterId,
    required int stateMasterId,
    required double minSalary,
    required double maxSalary,
    required String gender,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "DeductionMasterId": deductionMasterId,
      "UniqueKey": uniqueKey,
      "Name": name,
      "Type": type,
      "Value": value,
      "BranchMasterId": branchMasterId,
      "StateMasterId": stateMasterId,
      "MinSalary": minSalary,
      "MaxSalary": maxSalary,
      "Gender": gender,
    };
    var result = await deductionMasterRepository.addUpdateDeduction(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = response['data'][0] as DeductionMasterModel;

        if (state.deductionList.isNotEmpty &&
            index < state.deductionList.length) {
          final updatedListModel = List<DeductionMasterModel>.from(
            state.deductionList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(deductionList: updatedListModel));
        }

        showSuccessMessage(context, subTitle: "Deduction Updated Successfully");
      },
    );
  }

  Future deleteDeduction(
    int index,
    DeductionMasterModel deductionMaster,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await deductionMasterRepository.deleteDeduction(
      deductionMasterId: deductionMaster.deductionMasterId,
      uniqueKey: deductionMaster.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<DeductionMasterModel>.from(
          state.deductionList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            deductionList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );

        showSuccessMessage(context, subTitle: "Deduction Deleted Successfully");
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await deductionMasterRepository.exportDeductions(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {"ExportType": exportType, "EmployeeName": state.searchText},
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
              ? "deduction_${DateTime.now()}.pdf"
              : "deduction_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future<void> applyFilterAndSort({
    required BuildContext context,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        deductionList: [],
        currentPage: 1,
      ),
    );

    await getDeductionList(context: context, pageNumber: 1);
  }
}
