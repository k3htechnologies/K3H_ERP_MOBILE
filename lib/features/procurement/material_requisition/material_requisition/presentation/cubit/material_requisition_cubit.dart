import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
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
    var result = await _materialRequisitionRepository
        .getMaterialRequisitionList(
          pageNumber: pageNumber,
          pageSize: 10,
          projectId: projectId,
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
        materialRequisitionDetailJSON
            .map(
              (e) => {
                'MaterialRequisitionDetailId': e.materialRequisitionDetailId,
                'SubMaterialMasterId': e.subMaterialMasterId,
                'MaterialQuantity': e.materialQuantity,
                'UomMasterId': e.uomMasterId,
                'RequiredDate': formatDateTimeForApi(e.requiredDate),
              },
            )
            .toList(),
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
        //close verification popup
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: 'Channel Partner Added Successfully',
        );
        goRouter.pop();
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
        materialRequisitionDetailJSON
            .map(
              (e) => {
                'MaterialRequisitionDetailId': e.materialRequisitionDetailId,
                'SubMaterialMasterId': e.subMaterialMasterId,
                'MaterialQuantity': e.materialQuantity,
                'UomMasterId': e.uomMasterId,
                'RequiredDate': formatDateTimeForApi(e.requiredDate),
              },
            )
            .toList(),
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
        getMaterialRequisitionList(context, 1, projectId);
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: 'Channel Partner Added Successfully',
        );
        goRouter.pop();
      },
    );
  }

  Future deleteMaterialRequisition({
    required BuildContext context,
    required int materialRequisitionId,
    required String uniqueKey,
    required int projectId,
    required int pageNumber,
    required int pageSize,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _materialRequisitionRepository
        .deleteMaterialRequisition(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(context);
        getMaterialRequisitionList(context, pageNumber, projectId);
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
                "ChannelPartnerName": state.searchText,
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
}
