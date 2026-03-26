import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/repository/asset_master_mapping.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'asset_mapping_master_state.dart';

class AssetMappingMasterCubit extends Cubit<AssetMappingMasterState> {
  AssetMappingMasterCubit() : super(AssetMappingMasterState.initial());

  final AssetMasterMappingRepository assetMasterMappingRepository =
      serviceLocator<AssetMasterMappingRepository>();

  void resetState() {
    emit(AssetMappingMasterState.initial());
  }

  void searchAssetMapping(String value, BuildContext context) {
    emit(
      state.copyWith(
        assetMappingList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getAssetMappingList(context: context, pageNumber: 1);
  }

  Future getAssetMappingList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "AssetName": state.searchText,
      "EmployeeName": state.filterEmployeeName,
      // "Status": "Available",
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };

    var result = await assetMasterMappingRepository.getAssetMasterMappedList(
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
        final List<AssetMappingModel> newData = List<AssetMappingModel>.from(
          response['data'] ?? [],
        );

        final List<AssetMappingModel> updatedList =
            pageNumber == 1 ? newData : [...state.assetMappingList, ...newData];

        emit(
          state.copyWith(
            assetMappingList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future addAssetMapping({
    required BuildContext context,
    required int employeeId,
    required int assetMasterId,
    required DateTime assignedDate,
    required String conditionOnIssue,
    required String remarks,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "AssetMasterMappingId": 0,
      "EmployeeId": employeeId,
      "AssetMasterId": assetMasterId,
      "AssignedDate": assignedDate.toIso8601String(),
      "ReturnDate": '1997-01-01',
      "ConditionOnIssue": conditionOnIssue,
      "ConditionOnReturn": '',
      "Remarks": remarks,
    };
    var result = await assetMasterMappingRepository.addUpdateAssetMapping(
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
        showSuccessMessage(
          context,
          subTitle: 'Asset Mapping Added Successfully',
        );
      },
    );
  }

  Future updateAssetMapping({
    required int index,
    required BuildContext context,
    required int assetMasterMappingId,
    required String uniqueKey,
    required int employeeId,
    required int assetMasterId,
    required DateTime assignedDate,
    required DateTime? returnDate,
    required String conditionOnIssue,
    required String? conditionOnReturn,
    required String remarks,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "AssetMasterMappingId": assetMasterMappingId,
      "UniqueKey": uniqueKey,
      "EmployeeId": employeeId,
      "AssetMasterId": assetMasterId,
      "AssignedDate": assignedDate.toIso8601String(),
      "ReturnDate":
          returnDate != null ? returnDate.toIso8601String() : '1997-01-01',
      "ConditionOnIssue": conditionOnIssue,
      "ConditionOnReturn": conditionOnReturn,
      "Remarks": remarks,
    };
    var result = await assetMasterMappingRepository.addUpdateAssetMapping(
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
        if (response['data'] != null && response['data'].isNotEmpty) {
          final updatedList = AssetMappingModel.fromJson(
            response['data'][0] as Map<String, dynamic>,
          );

          if (state.assetMappingList.isNotEmpty &&
              index < state.assetMappingList.length) {
            final updatedListModel = List<AssetMappingModel>.from(
              state.assetMappingList,
            );
            updatedListModel[index] = updatedList;
            emit(state.copyWith(assetMappingList: updatedListModel));

            showSuccessMessage(
              context,
              subTitle: "Asset Mapping Updated Successfully",
            );
          }
        } else {
          final updatedListModel = List<AssetMappingModel>.from(
            state.assetMappingList,
          );
          updatedListModel.removeAt(index);
          emit(
            state.copyWith(
              assetMappingList: updatedListModel,
              totalNumberOfRecord: state.totalNumberOfRecord - 1,
            ),
          );

          showSuccessMessage(
            context,
            subTitle: "Asset return Successfully",
          );
        }
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await assetMasterMappingRepository
        .getAssetMasterMappedListForExport(
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
              ? "asset_mapping_${DateTime.now()}.pdf"
              : "asset_mapping_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  // APPLY FILTER AND SORT
  Future<void> applyFilterAndSort({
    required BuildContext context,
    required String filterEmployeeName,
    String? sortColumn,
    String? sortDirection,
  }) async {
    emit(
      state.copyWith(
        filterEmployeeName: filterEmployeeName,
        currentSortColumn: sortColumn ?? state.currentSortColumn,
        currentSortDirection: sortDirection ?? state.currentSortDirection,
        assetMappingList: [],
        currentPage: 1,
      ),
    );

    await getAssetMappingList(context: context, pageNumber: 1);
  }
}
