import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/repository/finalize_vendor.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/repository/material_requisition.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'material_requisition_state.dart';

class MaterialRequisitionCubit extends Cubit<MaterialRequisitionState> {
  MaterialRequisitionCubit() : super(MaterialRequisitionState.initial());

  // REPOSITORY
  final MaterialRequisitionRepository _materialRequisitionRepository =
      serviceLocator<MaterialRequisitionRepository>();
  FinalizeVendorRepository finalizeVendorRepository =
      serviceLocator<FinalizeVendorRepository>();

  void searchMaterialRequisition(
    BuildContext context,
    String searchText,
    int projectId,
  ) {
    emit(state.copyWith(searchText: searchText.trim()));
    getMaterialRequisitionList(context, 1, projectId);
  }

  Future getMaterialRequisitionList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }

    Map<String, dynamic> queryParams = {
      "SystemGeneratedCode": state.searchText,
    };
    var result = await _materialRequisitionRepository
        .getMaterialRequisitionList(
          pageNumber: pageNumber,
          pageSize: 10,
          projectId: projectId,
          queryParams: queryParams,
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<MaterialRequisitionModel> updatedList = List.from(
          state.materialRequisitionList,
        );
        updatedList = response['data'] as List<MaterialRequisitionModel>;
        emit(
          state.copyWith(
            materialRequisitionList: updatedList,
            isLoading: false,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  //  Needed for Overview
  Future<MaterialRequisitionModel?> getMaterialRequisitionDetailsById(
    BuildContext context,
    int pageNumber,
    int projectId,
    int materialRequisitionId,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await _materialRequisitionRepository
        .getMaterialRequisitionList(
          pageNumber: pageNumber,
          pageSize: 10,
          projectId: projectId,
          queryParams: {"MaterialRequisitionId": materialRequisitionId},
        );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        return null;
      },
      (response) {
        final List<MaterialRequisitionModel> materialRequisitionList =
            response['data'] as List<MaterialRequisitionModel>;
        final materialRequisitionDetails =
            materialRequisitionList.isNotEmpty
                ? materialRequisitionList.first
                : null;

        emit(state.copyWith(isLoading: false));
        return materialRequisitionDetails;
      },
    );
  }

  Future<List<RequisitionVendorModel>> getVendorForEnquiryList(
    BuildContext context,
    int projectId,
    int materialRequisitionId,
    String uniquekey,
  ) async {
    emit(state.copyWith(isLoading: true));

    var result = await finalizeVendorRepository.getSelectedVendor(
      projectId: projectId,
      materialRequisitionId: materialRequisitionId,
      uniquekey: uniquekey,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        return [];
      },
      (response) {
        showSuccessMessage(context);
        final List<RequisitionVendorModel> requisitionVendorList =
            response['data'] as List<RequisitionVendorModel>;

        emit(state.copyWith(isLoading: false));
        return requisitionVendorList.isNotEmpty ? requisitionVendorList : [];
      },
    );
  }

  Future addMaterialRequisition({
    required BuildContext context,
    required int projectId,
    required String remarks,
    required MultiFilePickerModel attachments,
    required List<MaterialRequisitionDetailModel> materialRequisitionDetailJSON,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> body = {
      "MaterialRequisitionId": 0.toString(),
      "ProjectId": projectId.toString(),
      "Remarks": remarks,
      "RemoveAttachmentsURL": attachments.deletedFileList,
      "MaterialRequisitionDetailJSON": jsonEncode(
        materialRequisitionDetailJSON.map((e) => e.toJsonPayload()).toList(),
      ),
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < attachments.fileBytesList.length; i++) {
      if (attachments.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "AttachmentsURL",
        "value": attachments.fileBytesList[i],
        "fileName": attachments.fileNameList[i],
      });
    }
    final result = await _materialRequisitionRepository
        .addUpdateMaterialRequisition(body: body, fileList: fileList);

    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        getMaterialRequisitionList(context, 1, projectId);
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future updateMaterialRequisition({
    required BuildContext context,
    required int materialRequisitionId,
    required String uniqueKey,
    required int projectId,
    required String remarks,
    required MultiFilePickerModel attachments,
    required List<MaterialRequisitionDetailModel> materialRequisitionDetailJSON,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> body = {
      "MaterialRequisitionId": materialRequisitionId.toString(),
      "ProjectId": projectId.toString(),
      "Remarks": remarks,
      "Uniquekey": uniqueKey,
      "RemoveAttachmentsURL": attachments.deletedFileList,
      "MaterialRequisitionDetailJSON": jsonEncode(
        materialRequisitionDetailJSON.map((e) => e.toJsonPayload()).toList(),
      ),
    };
    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < attachments.fileBytesList.length; i++) {
      if (attachments.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "AttachmentsURL",
        "value": attachments.fileBytesList[i],
        "fileName": attachments.fileNameList[i],
      });
    }

    var updateResult = await _materialRequisitionRepository
        .addUpdateMaterialRequisition(body: body, fileList: fileList);

    goRouter.pop();
    updateResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final updatedMaterialRequistion =
            response['data'][0] as MaterialRequisitionModel;

        if (state.materialRequisitionList.isNotEmpty &&
            index < state.materialRequisitionList.length) {
          final updatedList = List<MaterialRequisitionModel>.from(
            state.materialRequisitionList,
          );
          updatedList[index] = updatedMaterialRequistion;
          emit(
            state.copyWith(
              materialRequisitionList: updatedList,
              isLoading: false,
            ),
          );
        }
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop();
      },
    );
  }

  Future deleteMaterialRequisition({
    required BuildContext context,
    required int index,
    required MaterialRequisitionModel materialRequisitionModel,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _materialRequisitionRepository
        .deleteMaterialRequisition(
          projectId: materialRequisitionModel.projectId,
          materialRequisitionId: materialRequisitionModel.materialRequisitionId,
          uniqueKey: materialRequisitionModel.uniquekey,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final updatedMaterialRequisitionList =
            List<MaterialRequisitionModel>.from(state.materialRequisitionList);
        updatedMaterialRequisitionList.removeAt(index);

        emit(
          state.copyWith(
            materialRequisitionList: updatedMaterialRequisitionList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _materialRequisitionRepository.exportRequisition(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      queryParams:
          state.searchText != ""
              ? {
                "SystemGeneratedCode": state.searchText,
                "ExportType": exportType,
              }
              : {"ExportType": exportType},
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
              ? "Material Requisition ${DateTime.now()}.pdf"
              : "Material Requisition ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  void initializeMaterialList(
    List<MaterialRequisitionDetailModel> materialList,
  ) {
    emit(state.copyWith(materialList: materialList));
  }

  void addMaterial(MaterialRequisitionDetailModel material) {
    List<MaterialRequisitionDetailModel> existingMaterialList = List.from(
      state.materialList,
    );
    existingMaterialList.add(material);
    emit(state.copyWith(materialList: existingMaterialList));
  }

  Future<void> clearMaterialList() async {
    emit(state.copyWith(materialList: []));
  }

  void updateMaterialList(MaterialRequisitionDetailModel material, index) {
    List<MaterialRequisitionDetailModel> existingMaterialList = List.from(
      state.materialList,
    );
    existingMaterialList[index] = material;
    emit(state.copyWith(materialList: existingMaterialList));
  }

  void deleteMaterial(index) {
    List<MaterialRequisitionDetailModel> existingMaterialList = List.from(
      state.materialList,
    );
    existingMaterialList.removeAt(index);
    emit(state.copyWith(materialList: existingMaterialList));
  }
}
