import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/repository/grn.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'grn_state.dart';

class GrnCubit extends Cubit<GrnState> {
  GrnCubit() : super(GrnState.initial());
  GrnRepository grnRepository = serviceLocator<GrnRepository>();

  Future getAllGRNList({
    required BuildContext context,
    required int materialRequisitionId,
    required String uniqueKey,
    required int projectId,
  }) async {
    var result = await grnRepository.getGRNList(
      materialRequisitionId: materialRequisitionId,
      uniqueyKey: uniqueKey,
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        emit(state.copyWith(allGRNList: success['data'], isLoading: false));
      },
    );
  }

  Future addGRN({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionId,
    required List<MaterialRequisitionDetailGrnDatum>
    materialRequisitionDetailGRNJSON,
    required String challanNumber,
    required String vehicleNumber,
    required String remark,
    required MultiFilePickerModel challan,
    required String materialRequisitonUniqueKey,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectId": projectId.toString(),
      "MaterialRequisitionId": materialRequisitionId.toString(),
      "MaterialRequisitionDetailGRNJSON": jsonEncode(
        materialRequisitionDetailGRNJSON.map((e) => e.toJsonPayload()).toList(),
      ),
      "ChallanNumber": challanNumber,
      "VehicleNumber": vehicleNumber,
      "Remarks": remark,
      "MaterialRequisitionGRNId": "0",
      "RemoveUploadChallanURL": challan.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < challan.fileBytesList.length; i++) {
      fileList.add({
        "key": "UploadChallanURL",
        "value": challan.fileBytesList[i],
        "fileName": challan.fileNameList[i],
      });
    }
    var result = await grnRepository.addUpdateGRN(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        goRouter.pop();
        showSuccessMessage(context);
        getAllGRNList(
          context: context,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: materialRequisitonUniqueKey,
          projectId: projectId,
        );
      },
    );
  }

  Future updateGRN({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionId,
    required int materialRequisitionGRNId,
    required List<MaterialRequisitionDetailGrnDatum>
    materialRequisitionDetailGRNJSON,
    required String challanNumber,
    required String vehicleNumber,
    required String remark,
    required MultiFilePickerModel challan,
    required String materialRequisitonUniqueKey,
    required int index,
    required String uniquekey,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectId": projectId.toString(),
      "MaterialRequisitionId": materialRequisitionId.toString(),
      "MaterialRequisitionDetailGRNJSON": jsonEncode(
        materialRequisitionDetailGRNJSON.map((e) => e.toJsonPayload()).toList(),
      ),
      "ChallanNumber": challanNumber,
      "VehicleNumber": vehicleNumber,
      "Remarks": remark,
      "MaterialRequisitionGRNId": materialRequisitionGRNId.toString(),
      "RemoveUploadChallanURL": challan.deletedFileList,
      "Uniquekey": uniquekey,
    };

    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < challan.fileBytesList.length; i++) {
      fileList.add({
        "key": "UploadChallanURL",
        "value": challan.fileBytesList[i],
        "fileName": challan.fileNameList[i],
      });
    }
    var result = await grnRepository.addUpdateGRN(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final updatedMaterialRequistion = response['data'][0] as GRNModel;

        if (state.allGRNList.isNotEmpty && index < state.allGRNList.length) {
          final updatedList = List<GRNModel>.from(state.allGRNList);
          updatedList[index] = updatedMaterialRequistion;
          emit(state.copyWith(allGRNList: updatedList, isLoading: false));
        }
        showSuccessMessage(context, subTitle: response['message']);
        goRouter.pop();
      },
    );
  }

  Future deleteGRN({
    required BuildContext context,
    required int materialRequisitionGRNId,
    required String uniqueKey,
    required int materialRequisitionId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await grnRepository.deleteGRN(
      materialRequisitionGRNId: materialRequisitionGRNId,
      uniqueKey: uniqueKey,
      materialRequisitionId: materialRequisitionId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, 'error', failure.message);
        return;
      },
      (success) {
        emit(state.copyWith(isLoading: false, allGRNList: []));
        showSuccessMessage(context);
      },
    );
  }

  Future<List<MaterialRequisitionDetailModel>?> getGRNSummary(
    BuildContext context,
    int materialRequisitionId,
    String uniqueKey,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await grnRepository.getGRNSummary(
      materialRequisitionId: materialRequisitionId,
      uniqueyKey: uniqueKey,
    );
    goRouter.pop();
    return result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return null;
      },
      (data) {
        return data["data"] as List<MaterialRequisitionDetailModel>;
      },
    );
  }

  Future resetState() async {
    emit(GrnState.initial());
  }

  void initializeMaterialList(
    List<MaterialRequisitionDetailGrnDatum> materialList,
  ) {
    emit(state.copyWith(materialList: materialList));
  }

  void addMaterial(MaterialRequisitionDetailGrnDatum material) {
    List<MaterialRequisitionDetailGrnDatum> existingMaterialList = List.from(
      state.materialList,
    );
    existingMaterialList.add(material);
    emit(state.copyWith(materialList: existingMaterialList));
  }

  Future<void> clearMaterialList() async {
    emit(state.copyWith(materialList: []));
  }

  void updateMaterialList(MaterialRequisitionDetailGrnDatum material, index) {
    List<MaterialRequisitionDetailGrnDatum> existingMaterialList = List.from(
      state.materialList,
    );
    existingMaterialList[index] = material;
    emit(state.copyWith(materialList: existingMaterialList));
  }

  void deleteMaterial(index) {
    List<MaterialRequisitionDetailGrnDatum> existingMaterialList = List.from(
      state.materialList,
    );
    existingMaterialList.removeAt(index);
    emit(state.copyWith(materialList: existingMaterialList));
  }
}
