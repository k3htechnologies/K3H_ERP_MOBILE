import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/data/model/specification_master.model.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/data/repository/specification_master.repository.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/presentation/cubit/specification_master_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

class SpecificationMasterCubit extends Cubit<SpecificationMasterState> {
  SpecificationMasterCubit() : super(SpecificationMasterState.initial());
  // REPOSITORIES
  final SpecificationMasterRepository _specificationMasterRepository =
      serviceLocator<SpecificationMasterRepository>();
  // SEARCH SPECIFICATION
  Future searchSpecification(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, specificationList: []));
    await getSpecificationList(context, 1);
  }

  onTabChange(BuildContext context, String tabName) async {
    emit(
      state.copyWith(
        currentTabName: tabName,
        searchText: "",
        specificationList: [],
        childrenMap: {},
        loadingIds: {},
      ),
    );
    await getSpecificationList(context, 1);
  }

  // GET SPECIFICATION LIST
  Future getSpecificationList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "CategoryName": state.searchText,
      "LevelType": state.currentTabName,
    };
    var result = await _specificationMasterRepository.pullSpecificationMaster(
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
        final List<SpecificationMasterModel> newData =
            List<SpecificationMasterModel>.from(response['data'] ?? []);
        final List<SpecificationMasterModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.specificationList, ...newData];
        emit(
          state.copyWith(
            specificationList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  Future<void> getSpecificationViewList(
    BuildContext context,
    int specificationMasterId,
    int pageNumber,
  ) async {
    final key = specificationMasterId.toString();
    emit(state.copyWith(loadingIds: {...state.loadingIds, key}));
    Map<String, dynamic> queryParams = {
      "SpecificationMasterId": specificationMasterId,
      "LevelType": state.currentTabName,
      "IsCheckPermission": true,
      "IsExpandChild": true,
    };
    var result = await _specificationMasterRepository.pullSpecificationMaster(
      pageNumber: pageNumber,
      pageSize: 1000,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            loadingIds: Set<String>.from(state.loadingIds)..remove(key),
          ),
        );
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<SpecificationMasterModel> newData =
            List<SpecificationMasterModel>.from(response['data'] ?? []);
        // explicit type fixes the List<dynamic> error
        final List<SpecificationMasterModel> updatedList =
            pageNumber == 1
                ? newData
                : <SpecificationMasterModel>[
                  ...(state.childrenMap[key] ?? <SpecificationMasterModel>[]),
                  ...newData,
                ];
        emit(
          state.copyWith(
            childrenMap: {...state.childrenMap, key: updatedList},
            loadingIds: Set<String>.from(state.loadingIds)..remove(key),
          ),
        );
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, 'Error', 'No Data Found');
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    var result = await _specificationMasterRepository
        .pullSpecificationMasterForExport(
          pageNumber: 1,
          pageSize: state.totalNumberOfRecord,
          queryParams: {
            "CategoryName": state.searchText,
            "ExportType": exportType,
            "LevelType": state.currentTabName,
            "IsCheckPermission": true,
            "IsExpandChild": true,
          },
        );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Specification Master ${DateTime.now()}.pdf"
              : "Specification Master ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
