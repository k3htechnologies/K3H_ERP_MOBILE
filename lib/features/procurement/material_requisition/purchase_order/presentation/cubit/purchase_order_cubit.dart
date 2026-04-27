import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
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

  Future resetState() async {
    emit(PurchaseOrderState.initial());
  }

  Future getPurchaseOrder({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    emit(state.copyWith(isLoading: true));
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
        final List<PurchaseOrderModel> newData = List<PurchaseOrderModel>.from(
          response['data'] ?? [],
        );
        emit(state.copyWith(purchaseOrderList: newData, isLoading: false));
      },
    );
  }

  Future addPurchaseOrder({
    required BuildContext context,
    required int projectId,
    required int materialRequisitionId,
    required PlatformFile purchaseOrder,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    List<Map<String, dynamic>> fileList = [];
    fileList.add({
      "key": "PurchaseOrderURL",
      "value": purchaseOrder.bytes,
      "fileName": purchaseOrder.name,
    });

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
      (response) {
        final List<PurchaseOrderModel> newData = List<PurchaseOrderModel>.from(
          response['data'] ?? [],
        );
        emit(state.copyWith(purchaseOrderList: newData));
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
        showSuccessMessage(context, subTitle: success['message']);
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
        goRouter.pop();
        emit(state.copyWith(purchaseOrderList: response['data']));
      },
    );
  }
}
