import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/repository/finalize_vendor.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/model/invoice.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/repository/invoice.repository.dart';
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
  final FinalizeVendorRepository finalizeVendorRepository =
      serviceLocator<FinalizeVendorRepository>();
  final InvoiceRepository invoiceRepository =
      serviceLocator<InvoiceRepository>();

  Future resetOverview() async {
    emit(state.copyWith(materialRequisitionOverview: null));
  }

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
        final List<MaterialRequisitionModel> newData =
            List<MaterialRequisitionModel>.from(response['data'] ?? []);
        final List<MaterialRequisitionModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.materialRequisitionList, ...newData];

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
  Future<void> getMaterialRequisitionDetailsById(
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

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<MaterialRequisitionModel> materialRequisitionList =
            response['data'] as List<MaterialRequisitionModel>;
        final materialRequisitionDetails =
            materialRequisitionList.isNotEmpty
                ? materialRequisitionList.first
                : null;

        emit(
          state.copyWith(
            isLoading: false,
            materialRequisitionOverview: materialRequisitionDetails,
          ),
        );
      },
    );
  }

  Future<void> getFinalizedVendor(
    BuildContext context,
    int projectId,
    int materialRequisitionId,
    String uniquekey,
  ) async {
    emit(state.copyWith(isLoading: true, finalizedVendor: null));

    var result = await finalizeVendorRepository.getSelectedVendorForCompare(
      projectId: projectId,
      materialRequisitionId: materialRequisitionId,
      uniquekey: uniquekey,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        final List<FinalizeVendorForComparisonModel> requisitionVendorList =
            response['data'] as List<FinalizeVendorForComparisonModel>;
        final finalizedVendorList =
            requisitionVendorList
                .where((vendor) => vendor.isFinalized == true)
                .toList();

        emit(
          state.copyWith(
            isLoading: false,
            finalizedVendor:
                finalizedVendorList.isNotEmpty
                    ? finalizedVendorList.first
                    : null,
          ),
        );
      },
    );
  }

  Future<List<InvoiceModel>> getInvoiceForOverview({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
    required BuildContext context,
  }) async {
    var result = await invoiceRepository.getRequisitionInvoice(
      projectId: projectId,
      materialRequisitionId: materialRequisitionId,
      uniqueKey: uniqueKey,
    );
    return result.fold(
      (failure) {
        return [];
      },
      (response) {
        return response["data"] as List<InvoiceModel>;
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

  Future copyMaterialRequisition({
    required BuildContext context,
    required int materialRequisitionId,
    required String uniqueKey,
    required int projectId,
    required String remarks,
    required List<MaterialRequisitionDetailModel> materialRequisitionDetailJSON,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "MaterialRequisitionId": materialRequisitionId.toString(),
      "ProjectId": projectId.toString(),
      "Remarks": remarks,
      "Uniquekey": uniqueKey,
      "IsCopy": "1",
      "IsSplit": "0",
      // NEED TO BE COMPLETED
      "MaterialRequisitionDetailJSON": jsonEncode(
        materialRequisitionDetailJSON
            .map(
              (e) => {
                'MaterialRequisitionDetailId': e.materialRequisitionDetailId,
                'SubMaterialMasterId': e.subMaterialMasterId,
                'MaterialQuantity': e.materialQuantity,
                'UomMasterId': e.uomMasterId,
                'RequiredDate': e.requiredDate.toIso8601String(),
              },
            )
            .toList(),
      ),
    };

    var updateResult = await _materialRequisitionRepository
        .addUpdateMaterialRequisition(body: requestBody, fileList: []);
    goRouter.pop();
    updateResult.fold(
      (failure) async {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context, subTitle: response['message']);
        getMaterialRequisitionList(context, 1, projectId);
      },
    );
  }

  Future splitMaterialRequisition({
    required BuildContext context,
    required int materialRequisitionId,
    required String uniqueKey,
    required int projectId,
    required String remarks,
    required Set<int> selectedIds,
    required List<MaterialRequisitionDetailModel> materialRequisitionDetailJSON,
  }) async {
    if (selectedIds.isEmpty) {
      showErrorMessage(
        context,
        "Validation",
        "Please select at least one item",
      );
      return;
    }

    DialogHelper.showProcessingOverlay(context);

    final selectedList =
        materialRequisitionDetailJSON
            .where((e) => selectedIds.contains(e.materialRequisitionDetailId))
            .map(
              (e) => {
                'MaterialRequisitionDetailId': e.materialRequisitionDetailId,
                'SubMaterialMasterId': e.subMaterialMasterId,
                'MaterialQuantity': e.materialQuantity,
                'UomMasterId': e.uomMasterId,
                'RequiredDate': e.requiredDate.toIso8601String(),
              },
            )
            .toList();

    final selectedMaterials = jsonEncode(selectedList);

    final Map<String, String> requestBody = {
      "MaterialRequisitionId": materialRequisitionId.toString(),
      "ProjectId": projectId.toString(),
      "Remarks": remarks,
      "Uniquekey": uniqueKey,
      "IsSplit": "1",
      "IsCopy": "0",
      "MaterialRequisitionDetailJSON": selectedMaterials,
    };

    final result = await _materialRequisitionRepository
        .addUpdateMaterialRequisition(body: requestBody, fileList: []);

    // close loader
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        goRouter.pop();
      },
      (response) {
        goRouter.pop();
        goRouter.pop();
        showSuccessMessage(context, subTitle: response['message']);
        getMaterialRequisitionList(context, 1, projectId);
      },
    );
  }
}
