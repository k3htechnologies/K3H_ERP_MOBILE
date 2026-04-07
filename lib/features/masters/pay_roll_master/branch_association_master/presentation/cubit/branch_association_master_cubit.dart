import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/model/branch_association_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/repository/branch_association_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'branch_association_master_state.dart';

class BranchAssociationMasterCubit extends Cubit<BranchAssociationMasterState> {
  BranchAssociationMasterCubit()
    : super(BranchAssociationMasterState.initial());

  final BranchAssociationMasterRepository branchAssociationMasterRepository =
      serviceLocator<BranchAssociationMasterRepository>();

  void resetState() {
    emit(BranchAssociationMasterState.initial());
  }

  void branchAssociationMaster(String value, BuildContext context) {
    emit(
      state.copyWith(
        branchAssociationList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getBranchAssociationList(context: context, pageNumber: 1);
  }

  Future getBranchAssociationList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "EmployeeName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await branchAssociationMasterRepository
        .getBranchAssociationList(
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
        final List<BranchAssociationModel> newData =
            List<BranchAssociationModel>.from(response['data'] ?? []);

        final List<BranchAssociationModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.branchAssociationList, ...newData];

        emit(
          state.copyWith(
            branchAssociationList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addBranchAssociation({
    required BuildContext context,
    required int branchMasterId,
    required int employeeId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "BranchAssociationsId": 0,
      "BranchMasterId": branchMasterId.toString(),
      "EmployeeId": employeeId,
    };
    var result = await branchAssociationMasterRepository
        .addUpdateBranchAssociation(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: 'Branch Association Added Successfully',
        );
      },
    );
  }

  Future updateBranchAssociation({
    required int index,
    required BuildContext context,
    required int branchMasterId,
    required int employeeId,
    required int branchAssociationsId,
    required String uniqueKey,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "BranchAssociationsId": branchAssociationsId,
      "UniqueKey": uniqueKey,
      "BranchMasterId": branchMasterId.toString(),
      "EmployeeId": employeeId,
    };
    var result = await branchAssociationMasterRepository
        .addUpdateBranchAssociation(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final updatedList = response['data'][0] as BranchAssociationModel;

        if (state.branchAssociationList.isNotEmpty &&
            index < state.branchAssociationList.length) {
          final updatedListModel = List<BranchAssociationModel>.from(
            state.branchAssociationList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(branchAssociationList: updatedListModel));
        }

        showSuccessMessage(
          context,
          subTitle: "Branch Association Updated Successfully",
        );
        goRouter.pop();
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await branchAssociationMasterRepository
        .exportBranchAssociation(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          queryParams: {"ExportType": exportType},
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "branch_association_${DateTime.now()}.pdf"
              : "branch_association_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future deleteBranchAssociation(
    int index,
    BranchAssociationModel branchAssociation,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await branchAssociationMasterRepository
        .deleteBranchAssociation(
          branchAssociationId: branchAssociation.branchAssociationsId,
          uniqueKey: branchAssociation.uniquekey,
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<BranchAssociationModel>.from(
          state.branchAssociationList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            branchAssociationList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );

        showSuccessMessage(
          context,
          subTitle: "Branch Association deleted successfully",
        );
      },
    );
  }

  // APPLY FILTER AND SORT - BRANCH ASSOCIATION
  Future<void> applyFilterAndSort({
    required BuildContext context,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        branchAssociationList: [],
        currentPage: 1,
      ),
    );

    await getBranchAssociationList(context: context, pageNumber: 1);
  }
}
