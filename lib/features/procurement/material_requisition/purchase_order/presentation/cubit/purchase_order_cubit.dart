import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/data/model/purchase_order.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/data/repository/purchase_order.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'purchase_order_state.dart';

class PurchaseOrderCubit extends Cubit<PurchaseOrderState> {
  PurchaseOrderCubit() : super(PurchaseOrderState.initial());
  PurchaseOrderRepository purchaseOrderRepository =
      serviceLocator<PurchaseOrderRepository>();

  Future getPurchaseOrder({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    var result = await purchaseOrderRepository.getPurchaseOrder(
      projectId: projectId,
      materialRequisitionId: materialRequisitionId,
      uniqueKey: uniqueKey,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(context);
      },
    );
  }

  Future addPurchaseOrder({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionId,
    required MultiFilePickerModel purchaseOrder,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < purchaseOrder.fileNameList.length; i++) {
      fileList.add({
        "key": "PurchaseOrderURL",
        "value": purchaseOrder.fileBytesList[i],
        "fileName": purchaseOrder.fileNameList[i],
      });
    }
    goRouter.pop();
    var result = await purchaseOrderRepository.addUpdatePurchaseOrder(
      body: {
        "ProjectId": projectId.toString(),
        "MaterialRequisitionId": materialRequisitionId.toString(),
      },
      fileList: fileList,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, "error", failure.message);
      },
      (success) {
        emit(state.copyWith(purchaseOrderList: success['data']));
        showSuccessMessage(context);
      },
    );
  }

  Future deletePurchaseOrder({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionPOId,
    required String uniqueKey,
    required int materialRequisitionId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await purchaseOrderRepository.deletePurchaseOrder(
      projectId: projectId,
      materialRequisitionPOId: materialRequisitionPOId,
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
        emit(state.copyWith(isLoading: false, purchaseOrderList: []));
        showSuccessMessage(context);
      },
    );
  }

  Future generatePurchaseOrder({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionDetailId,
    required String uniqueKey,
    required String remarks,
    required String termsCondition,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await purchaseOrderRepository.generatePurchaseOrder(
      body: {
        "ProjectId": projectId,
        "MaterialRequisitionId": materialRequisitionDetailId,
        "Uniquekey": uniqueKey,
        "Remarks": remarks,
        "TermsCondition": termsCondition,
      },
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        emit(state.copyWith(purchaseOrderList: response['data']));
      },
    );
  }
}
