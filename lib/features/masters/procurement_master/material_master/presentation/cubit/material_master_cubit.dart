import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/model/material_master.model.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/material_master/data/repository/material_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'material_master_state.dart';

class MaterialMasterCubit extends Cubit<MaterialMasterState> {
  MaterialMasterCubit() : super(MaterialMasterState.initial());

  // REPOSITORY
  final MaterialMasterRepository _materialMasterRepository =
      serviceLocator<MaterialMasterRepository>();

  // <---- SEARCH MATERIAL ---->
  Future searchMaterial(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, materialList: []));
    await getMaterialMasterList(context, 1, 20);
  }


  // <---- GET MATERIAL MASTER ---->
  Future getMaterialMasterList(
    BuildContext context,
    int pageNumber,
    int pageSize,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "MaterialName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _materialMasterRepository.getMaterialList(
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
        List<MaterialMasterModel> updatedList =
            pageNumber == 1 ? [] : List.from(state.materialList);
        updatedList.addAll(response['data'] as List<MaterialMasterModel>);
        emit(
          state.copyWith(
            isLoading: false,
            materialList: updatedList,
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

  // <---- ADD MATERIAL MASTER ---->
  Future addMaterialMaster({
    required BuildContext context,
    required String materialName,
    required String materialCode,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var resultBody = {
      "MaterialMasterId": 0,
      "MaterialCode": materialCode,
      "MaterialName": materialName,
    };
    var addResult = await _materialMasterRepository.addUpdateMaterial(
      body: resultBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop(); // Close processing overlay
        showSuccessMessage(context, subTitle: "Material Added Successfully");
      },
    );
  }

  // <---- UPDATE MATERIAL MASTER ---->
  Future updateMaterialMaster({
    required BuildContext context,
    required String materialName,
    required String materialCode,
    required String uniqueKey,
    required int materialMasterId,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var resultBody = {
      "MaterialMasterId": materialMasterId,
      "Uniquekey": uniqueKey,
      "MaterialCode": materialCode,
      "MaterialName": materialName,
    };
    var addResult = await _materialMasterRepository.addUpdateMaterial(
      body: resultBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedMaterial = response['data'][0] as MaterialMasterModel;

        if (state.materialList.isNotEmpty &&
            index < state.materialList.length) {
          final updatedList = List<MaterialMasterModel>.from(
            state.materialList,
          );
          updatedList[index] = updatedMaterial;
          emit(state.copyWith(materialList: updatedList, isLoading: false));
        }
        showSuccessMessage(context, subTitle: "Material Updated Successfully");
      },
    );
  }

  // <---- DELETE MATERIAL MASTER ---->
  Future deleteMaterialMaster({
    required BuildContext context,
    required int materialMasterId,
    required String uniqueKey,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _materialMasterRepository.deleteMaterial(
      materialMasterId: materialMasterId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: "Material Deleted Successfully");
        if (index != null && index >= 0 && index < state.materialList.length) {
          final updatedList = List<MaterialMasterModel>.from(
            state.materialList,
          );
          updatedList.removeAt(index);
          emit(state.copyWith(isLoading: false, materialList: updatedList));
        } else {
          getMaterialMasterList(context, state.currentPage, pageSize);
        }
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _materialMasterRepository.exportMaterial(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
          state.searchText != ""
              ? {"MaterialName": state.searchText, "ExportType": exportType}
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
              ? "Material Master ${DateTime.now()}.pdf"
              : "Material Master ${DateTime.now()}.xlsx",
        );

        showSuccessMessage(
          context,
          subTitle: 'Exported as $exportType Successfully',
        );
      },
    );
  }
}
