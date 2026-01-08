import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/repository/sub_material_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'sub_material_master_state.dart';

class SubMaterialMasterCubit extends Cubit<SubMaterialMasterState> {
  SubMaterialMasterCubit() : super(SubMaterialMasterState.initial());

  // REPOSITORY
  final SubMaterialMasterRepository _subMaterialMasterRepository =
      serviceLocator<SubMaterialMasterRepository>();

  // <---- GET SUB MATERIAL MASTER LIST ---->
  Future getSubMaterialMasterList(
    BuildContext context,
    int pageNumber,
    int pageSize,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {"SubMaterialName": state.searchText};
    var result = await _subMaterialMasterRepository.getSubMaterialList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<SubMaterialMasterModel> updatedList =
            pageNumber == 1 ? [] : List.from(state.subMaterialList);
        updatedList.addAll(
          (response['data'] as List).cast<SubMaterialMasterModel>(),
        );
        emit(
          state.copyWith(
            isLoading: false,
            subMaterialList: updatedList,
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

  // <---- SEARCH SUB MATERIAL ---->
  Future searchSubMaterial(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, subMaterialList: []));
    await getSubMaterialMasterList(context, 1, 10);
  }

  // <---- ADD SUB MATERIAL ---->
  Future addSubMaterialMaster({
    required BuildContext context,
    required String subMaterialName,
    required int materialMasterId,
    required int uomMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      "SubMaterialMasterId": 0,
      "SubMaterialName": subMaterialName,
      "MaterialMasterId": materialMasterId,
      "UomMasterId": uomMasterId,
    };
    var result = await _subMaterialMasterRepository.addUpdateSubMaterial(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        // Refresh the list from API to ensure consistency
        getSubMaterialMasterList(context, 1, 10);
        showSuccessMessage(
          context,
          subTitle: "Sub Material Added Successfully",
        );
      },
    );
  }

  // <---- UPDATE SUB MATERIAL ---->
  Future updateSubMaterialMaster({
    required BuildContext context,
    required int subMaterialMasterId,
    required String uniqueKey,
    required String subMaterialName,
    required int materialMasterId,
    required int uomMasterId,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> body = {
      "SubMaterialMasterId": subMaterialMasterId,
      "Uniquekey": uniqueKey,
      "SubMaterialName": subMaterialName,
      "MaterialMasterId": materialMasterId,
      "UomMasterId": uomMasterId,
    };
    var result = await _subMaterialMasterRepository.addUpdateSubMaterial(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final updatedList = List<SubMaterialMasterModel>.from(
          state.subMaterialList,
        );
        // Check if index is valid, otherwise refresh the list
        if (index >= 0 && index < updatedList.length) {
          updatedList[index] = (response['data'][0] as SubMaterialMasterModel);
          emit(state.copyWith(subMaterialList: updatedList));
        } else {
          // If index is invalid, refresh the list from API
          getSubMaterialMasterList(context, 1, 10);
        }
        showSuccessMessage(
          context,
          subTitle: "Sub Material Updated Successfully",
        );
        // Pop the edit screen after successful update
        goRouter.pop();
      },
    );
  }

  // <---- DELETE SUB MATERIAL ---->
  Future deleteSubMaterialMaster({
    required BuildContext context,
    required int subMaterialMasterId,
    required String uniqueKey,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _subMaterialMasterRepository.deleteSubMaterial(
      subMaterialMasterId: subMaterialMasterId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: "Sub Material Deleted Successfully",
        );
        if (index != null &&
            index >= 0 &&
            index < state.subMaterialList.length) {
          final updatedList = List<SubMaterialMasterModel>.from(
            state.subMaterialList,
          );
          updatedList.removeAt(index);
          emit(
            state.copyWith(
              subMaterialList: updatedList,
              totalNumberOfRecord: state.totalNumberOfRecord - 1,
              isLoading: false,
            ),
          );
        } else {
          // Refresh the list from API
          getSubMaterialMasterList(context, 1, pageSize);
        }
      },
    );
  }

  // <---- SORT SUB MATERIAL ---->
  Future sortSubMaterial(
    BuildContext context,
    String sortType,
    String sortOrder,
  ) async {
    emit(state.copyWith(isLoading: true, subMaterialList: []));
    Map<String, dynamic> queryParams = {
      "SubMaterialName": state.searchText,
      "SortBy":
          sortType == "Created Date"
              ? "CreatedDate"
              : sortType == "Modified Date"
              ? "ModifiedDate"
              : sortType == "Sub Material Name"
              ? "SubMaterialName"
              : "CreatedDate",
      "SortOrder": sortOrder,
    };
    var result = await _subMaterialMasterRepository.getSubMaterialList(
      pageNumber: 1,
      pageSize: 10,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<SubMaterialMasterModel> updatedList =
            (response['data'] as List).cast<SubMaterialMasterModel>();
        emit(
          state.copyWith(
            isLoading: false,
            subMaterialList: updatedList,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: 1,
          ),
        );
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _subMaterialMasterRepository.exportSubmaterial(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"SubMaterialName": state.searchText, "ExportType": exportType}
              : {"ExportType": exportType},
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
              ? "sub_material_${DateTime.now()}.pdf"
              : "sub_material_${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
