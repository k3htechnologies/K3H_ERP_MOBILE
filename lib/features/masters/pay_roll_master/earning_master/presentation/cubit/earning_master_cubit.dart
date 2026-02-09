import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/model/earning_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/repository/earning_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'earning_master_state.dart';

class EarningMasterCubit extends Cubit<EarningMasterState> {
  EarningMasterCubit() : super(EarningMasterState.initial());

  final EarningMasterRepository earningMasterRepository =
      serviceLocator<EarningMasterRepository>();

  void resetState() {
    emit(EarningMasterState.initial());
  }

  void searchEarning(String value, BuildContext context) {
    emit(
      state.copyWith(
        earningList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getEarningList(context: context, pageNumber: 1);
  }

  Future getEarningList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "Name": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await earningMasterRepository.getEarningsList(
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
        final List<EarningMasterModel> newData = List<EarningMasterModel>.from(
          response['data'] ?? [],
        );

        final List<EarningMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.earningList, ...newData];

        emit(
          state.copyWith(
            earningList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addEarning({
    required BuildContext context,
    required int branchMasterId,
    required String earningName,
    required String earningType,
    required double value,
    required double minSalary,
    required double maxSalary,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "EarningMasterId": 0,
      "BranchMasterId": branchMasterId,
      "Name": earningName,
      "Type": earningType,
      "Value": value,
      "MinSalary": minSalary,
      "MaxSalary": maxSalary,
    };
    var result = await earningMasterRepository.addUpdateEarning(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Earning Added Successfully');
      },
    );
  }

  Future updateEarning({
    required int index,
    required BuildContext context,
    required int earningMasterId,
    required int branchMasterId,
    required String uniqueKey,
    required String earningName,
    required String earningType,
    required double value,
    required double minSalary,
    required double maxSalary,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "EarningMasterId": earningMasterId,
      "UniqueKey": uniqueKey,
      "BranchMasterId": branchMasterId,
      "Name": earningName,
      "Type": earningType,
      "Value": value,
      "MinSalary": minSalary,
      "MaxSalary": maxSalary,
    };
    var result = await earningMasterRepository.addUpdateEarning(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = response['data'][0] as EarningMasterModel;

        if (state.earningList.isNotEmpty && index < state.earningList.length) {
          final updatedListModel = List<EarningMasterModel>.from(
            state.earningList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(earningList: updatedListModel));
        }

        showSuccessMessage(context, subTitle: "Earning Updated Successfully");
      },
    );
  }

  Future deleteEarning(
    int index,
    EarningMasterModel earningMaster,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await earningMasterRepository.deleteEarning(
      earningMasterId: earningMaster.earningMasterId,
      uniqueKey: earningMaster.uniquekey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<EarningMasterModel>.from(state.earningList);
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            earningList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: "Earning Deleted Successfully");
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await earningMasterRepository.exportEarnings(
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
              ? "earning_${DateTime.now()}.pdf"
              : "earning_${DateTime.now()}.xlsx",
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
        earningList: [],
        currentPage: 1,
      ),
    );

    await getEarningList(context: context, pageNumber: 1);
  }
}
