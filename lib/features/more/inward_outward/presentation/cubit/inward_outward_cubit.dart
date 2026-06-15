import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/repository/inward_outward.repository.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class InwardOutwardCubit extends Cubit<InwardOutwardState> {
  InwardOutwardCubit() : super(InwardOutwardState.initial());

  final InwardOutwardRepository _repository =
      serviceLocator<InwardOutwardRepository>();

  void resetSearch() {
    emit(state.copyWith(searchText: ""));
  }

  Future<void> handleTabChange({
    required BuildContext context,
    required int currentTabIndex,
  }) async {
    emit(state.copyWith(currentTabIndex: currentTabIndex));
    await handleApiCall(context: context);
  }

  Future<void> handleApiCall({required BuildContext context}) async {
    switch (state.currentTabIndex) {
      case 0:
        getInwardOutwardList(context, 1);
        break;
      case 1:
        getInwardList(context, 1);
      case 2:
        getOutwardList(context, 1);
      default:
        break;
    }
  }

  Future searchInwardOutward(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, inwardOutwardList: []));

    await handleApiCall(context: context);
  }

  Future applyInwardOutwardFilterAndSort({
    required BuildContext context,
    String? documentId,
    String? senderName,
    String? receiverName,
    String? documentType,
    String? sortColumn,
    String? sortDirection,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterBySenderName: "",
          filterByReceiverName: "",
          filterByDocumentType: "",
          currentSortColumn: "",
          currentSortDirection: "",
          inwardOutwardCurrentPage: 1,
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: documentId ?? state.searchText,
          filterBySenderName: senderName ?? state.filterBySenderName,
          filterByReceiverName: receiverName ?? state.filterByReceiverName,
          filterByDocumentType: documentType ?? state.filterByDocumentType,
          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
          inwardOutwardCurrentPage: 1,
        ),
      );
    }

    await handleApiCall(context: context);
  }

  Future getInwardOutwardList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getInwardOutwardList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {
        "DocumentId": state.searchText,
        "SenderName": state.filterBySenderName,
        "ReceiverName": state.filterByReceiverName,
        "DocumentType": state.filterByDocumentType,
        "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      },
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<InwardOutwardModel> newData = List<InwardOutwardModel>.from(
          response["data"] ?? [],
        );

        final updatedList =
            pageNumber == 1
                ? newData
                : [...state.inwardOutwardList, ...newData];

        emit(
          state.copyWith(
            inwardOutwardList: updatedList,
            inwardOutwardTotalRecords: response["totalNumberOfRecord"] ?? 0,
            inwardOutwardCurrentPage: pageNumber,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future getInwardList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getInwardOutwardList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {
        "DocumentId": state.searchText,
        "SenderName": state.filterBySenderName,
        "ReceiverName": state.filterByReceiverName,
        "DocumentType": "Inward",
        "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      },
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<InwardOutwardModel> newData = List<InwardOutwardModel>.from(
          response["data"] ?? [],
        );

        final updatedList =
            pageNumber == 1 ? newData : [...state.inwardList, ...newData];

        emit(
          state.copyWith(
            inwardList: updatedList,
            inwardTotalRecords: response["totalNumberOfRecord"] ?? 0,
            inwardCurrentPage: pageNumber,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future getOutwardList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getInwardOutwardList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {
        "DocumentId": state.searchText,
        "SenderName": state.filterBySenderName,
        "ReceiverName": state.filterByReceiverName,
        "DocumentType": "Outward",
        "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      },
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final List<InwardOutwardModel> newData = List<InwardOutwardModel>.from(
          response["data"] ?? [],
        );

        final updatedList =
            pageNumber == 1 ? newData : [...state.outwardList, ...newData];

        emit(
          state.copyWith(
            outwardList: updatedList,
            outwardTotalRecords: response["totalNumberOfRecord"] ?? 0,
            outwardCurrentPage: pageNumber,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future deleteInwardOutward({
    required BuildContext context,
    required int inwardOutwardId,
    required String uniqueKey,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _repository.deleteInwardOutward(
      inwardOutwardId: inwardOutwardId,
      uniqueKey: uniqueKey,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        await getInwardOutwardList(context, 1);

        if (context.mounted) {
          showSuccessMessage(
            context,
            subTitle: response["message"] ?? "Deleted Successfully",
          );
        }
      },
    );
  }

  Future<List<InwardOutwardModel>> fetchSenderReceiverByMobile(
    String? mobileNumber,
  ) async {
    final result = await _repository.getSenderReceiverByMobileNo(
      mobileNumber: mobileNumber ?? "",
    );

    return result.fold(
      (failure) => [],
      (response) => List<InwardOutwardModel>.from(response["data"] ?? []),
    );
  }

  Future addInwardOutward({
    required BuildContext context,
    required String deliveryType,
    required String inwardOutwardDate,
    required String inwardNumber,
    required String invoiceNumber,
    required String invoiceDate,
    required String senderName,
    required String senderAddress,
    required String senderMobileNo,
    required String senderEmailId,
    required String receiverName,
    required String receiverAddress,
    required String receiverMobileNo,
    required String receiverEmailId,
    required MultiFilePickerModel documentURL,
    required String removeDocumentURL,
    required String employeeId,
    required String documentType,
    required MultiFilePickerModel receiversSignature,
    required String removeReceiversSignature,
    required String receivedBy,
    required String handOverTo,
    required String handOverDate,
    required String chequeNo,
    required String documentTitle,
    required String priority,
    required String documentDescription,
    required double amount,
    required String deliveryMode,
    required String deliveryStatus,
    required MultiFilePickerModel acknowledgementURL,
    required String removeAcknowledgementURL,
    required String acknowledgementRemark,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "InwardOutwardId": "0",
      "DeliveryType": deliveryType,
      "InwardOutwardDate": inwardOutwardDate,
      "InwardNumber": inwardNumber,
      "InVoiceNumber": invoiceNumber,
      "InVoiceDate": invoiceDate,
      "SenderName": senderName,
      "SenderAddress": senderAddress,
      "SenderMobileNo": senderMobileNo,
      "SenderEmailId": senderEmailId,
      "ReceiverName": receiverName,
      "ReceiverAddress": receiverAddress,
      "ReceiverMobileNo": receiverMobileNo,
      "ReceiverEmailId": receiverEmailId,
      "RemoveDocumentURL": removeDocumentURL,
      "EmployeeId": employeeId,
      "DocumentType": documentType,
      "RemoveReceiversSignature": removeReceiversSignature,
      "ReceivedBy": receivedBy,
      "HandOverTo": handOverTo,
      "HandOverDate": handOverDate,
      "ChequeNo": chequeNo,
      "DocumentTitle": documentTitle,
      "Priority": priority,
      "DocumentDescription": documentDescription,
      "Amount": amount.toString(),
      "DeliveryMode": deliveryMode,
      "DeliveryStatus": deliveryStatus,
      "RemoveAcknowledgementURL": removeAcknowledgementURL,
      "AcknowledgementRemark": acknowledgementRemark,
    };

    List<Map<String, dynamic>> fileList = [];

    // DocumentURL
    for (int i = 0; i < documentURL.fileNameList.length; i++) {
      if (documentURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "DocumentURL",
        "value": documentURL.fileBytesList[i],
        "fileName": documentURL.fileNameList[i],
      });
    }

    // ReceiversSignature
    for (int i = 0; i < receiversSignature.fileNameList.length; i++) {
      if (receiversSignature.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "ReceiversSignature",
        "value": receiversSignature.fileBytesList[i],
        "fileName": receiversSignature.fileNameList[i],
      });
    }

    // AcknowledgementURL
    for (int i = 0; i < acknowledgementURL.fileNameList.length; i++) {
      if (acknowledgementURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "AcknowledgementURL",
        "value": acknowledgementURL.fileBytesList[i],
        "fileName": acknowledgementURL.fileNameList[i],
      });
    }

    final result = await _repository.addUpdateInwardOutward(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        await getInwardOutwardList(context, 1);

        if (context.mounted) {
          showSuccessMessage(
            context,
            subTitle:
                response["message"] ?? "Inward Outward Added Successfully",
          );
        }

        goRouter.pop();
      },
    );
  }

  Future updateInwardOutward({
    required BuildContext context,
    required int inwardOutwardId,
    required String uniqueKey,
    required String deliveryType,
    required String inwardOutwardDate,
    required String inwardNumber,
    required String invoiceNumber,
    required String invoiceDate,
    required String senderName,
    required String senderAddress,
    required String senderMobileNo,
    required String senderEmailId,
    required String receiverName,
    required String receiverAddress,
    required String receiverMobileNo,
    required String receiverEmailId,
    required MultiFilePickerModel documentURL,
    required String removeDocumentURL,
    required String employeeId,
    required String documentType,
    required MultiFilePickerModel receiversSignature,
    required String removeReceiversSignature,
    required String receivedBy,
    required String handOverTo,
    required String handOverDate,
    required String chequeNo,
    required String documentTitle,
    required String priority,
    required String documentDescription,
    required double amount,
    required String deliveryMode,
    required String deliveryStatus,
    required MultiFilePickerModel acknowledgementURL,
    required String removeAcknowledgementURL,
    required String acknowledgementRemark,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "InwardOutwardId": inwardOutwardId.toString(),
      "UniqueKey": uniqueKey,
      "DeliveryType": deliveryType,
      "InwardOutwardDate": inwardOutwardDate,
      "InwardNumber": inwardNumber,
      "InVoiceNumber": invoiceNumber,
      "InVoiceDate": invoiceDate,
      "SenderName": senderName,
      "SenderAddress": senderAddress,
      "SenderMobileNo": senderMobileNo,
      "SenderEmailId": senderEmailId,
      "ReceiverName": receiverName,
      "ReceiverAddress": receiverAddress,
      "ReceiverMobileNo": receiverMobileNo,
      "ReceiverEmailId": receiverEmailId,
      "RemoveDocumentURL": removeDocumentURL,
      "EmployeeId": employeeId,
      "DocumentType": documentType,
      "RemoveReceiversSignature": removeReceiversSignature,
      "ReceivedBy": receivedBy,
      "HandOverTo": handOverTo,
      "HandOverDate": handOverDate,
      "ChequeNo": chequeNo,
      "DocumentTitle": documentTitle,
      "Priority": priority,
      "DocumentDescription": documentDescription,
      "Amount": amount.toString(),
      "DeliveryMode": deliveryMode,
      "DeliveryStatus": deliveryStatus,
      "RemoveAcknowledgementURL": removeAcknowledgementURL,
      "AcknowledgementRemark": acknowledgementRemark,
    };

    List<Map<String, dynamic>> fileList = [];

    // DocumentURL
    for (int i = 0; i < documentURL.fileNameList.length; i++) {
      if (documentURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "DocumentURL",
        "value": documentURL.fileBytesList[i],
        "fileName": documentURL.fileNameList[i],
      });
    }

    // ReceiversSignature
    for (int i = 0; i < receiversSignature.fileNameList.length; i++) {
      if (receiversSignature.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "ReceiversSignature",
        "value": receiversSignature.fileBytesList[i],
        "fileName": receiversSignature.fileNameList[i],
      });
    }

    // AcknowledgementURL
    for (int i = 0; i < acknowledgementURL.fileNameList.length; i++) {
      if (acknowledgementURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "AcknowledgementURL",
        "value": acknowledgementURL.fileBytesList[i],
        "fileName": acknowledgementURL.fileNameList[i],
      });
    }

    final result = await _repository.addUpdateInwardOutward(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        await getInwardOutwardList(context, 1);

        if (context.mounted) {
          showSuccessMessage(
            context,
            subTitle:
                response["message"] ?? "Inward Outward Updated Successfully",
          );
        }

        goRouter.pop();
      },
    );
  }

  Future addUpdateInwardOutwardRevert({
    required BuildContext context,
    required int inwardOutwardRevertId,
    required int inwardOutwardId,
    required String uniqueKey,
    required String revertDate,
    required String revertRemark,
    required MultiFilePickerModel revertDocumentURL,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "InwardOutwardRevertId": inwardOutwardRevertId.toString(),
      "InwardOutwardId": inwardOutwardId.toString(),
      "UniqueKey": uniqueKey,
      "RevertDate": revertDate,
      "RevertRemark": revertRemark,
    };

    List<Map<String, dynamic>> fileList = [];

    // RevertDocumentURL
    for (int i = 0; i < revertDocumentURL.fileNameList.length; i++) {
      if (revertDocumentURL.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "RevertDocumentURL",
        "value": revertDocumentURL.fileBytesList[i],
        "fileName": revertDocumentURL.fileNameList[i],
      });
    }

    final result = await _repository.addUpdateInwardOutwardRevert(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        await getInwardOutwardList(context, 1);

        if (context.mounted) {
          showSuccessMessage(
            context,
            subTitle:
                response["message"] ?? "Inward Outward Reverted Successfully",
          );
        }
      },
    );
  }
}
