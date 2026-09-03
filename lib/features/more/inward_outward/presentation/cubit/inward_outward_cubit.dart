import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/sender_detail.model.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/repository/inward_outward.repository.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class InwardOutwardCubit extends Cubit<InwardOutwardState> {
  InwardOutwardCubit() : super(InwardOutwardState.initial());

  final InwardOutwardRepository _repository =
      serviceLocator<InwardOutwardRepository>();

  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  void resetState() {
    emit(InwardOutwardState.initial());
  }

  void resetSearch() {
    emit(state.copyWith(searchText: ""));
  }

  Future<void> handleTabChange({
    required BuildContext context,
    required int currentTabIndex,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        inwardOutwardList: [],
        inwardOutwardCurrentPage: 1,
        inwardOutwardTotalRecords: 0,
        currentTabIndex: currentTabIndex,
        searchText: "",
        filterByDocumentType: "",
        filterByReceiverName: "",
        filterBySenderName: "",
        filterByDocumentTitle: "",
        filterBySenderMobileNumber: "",
        filterByReceiverMobileNumber: "",
        filterByStatus: "",
        filterByFromDate: null,
      ),
    );
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
    String? documentTitle,
    String? status,
    String? senderMobileNumber,
    String? receiverMobileNumber,
    DateTime? fromDate,
    DateTime? toDate,
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
          filterByDocumentTitle: "",
          filterByStatus: "",
          filterBySenderMobileNumber: "",
          filterByReceiverMobileNumber: "",
          filterByFromDate: null,
          filterByToDate: null,
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
          filterByDocumentTitle: documentTitle ?? state.filterByDocumentTitle,
          filterByStatus: status ?? state.filterByStatus,
          filterBySenderMobileNumber:
              senderMobileNumber ?? state.filterBySenderMobileNumber,
          filterByReceiverMobileNumber:
              receiverMobileNumber ?? state.filterByReceiverMobileNumber,
          filterByFromDate: fromDate ?? state.filterByFromDate,
          filterByToDate: toDate ?? state.filterByToDate,
          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
          inwardOutwardCurrentPage: 1,
        ),
      );
    }

    await handleApiCall(context: context);
  }

  Future<void> getInwardOutwardView(
    BuildContext context,
    int inwardOutwardId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getInwardOutwardList(
      pageNumber: 1,
      pageSize: 10,
      queryParams: {"InwardOutwardId": inwardOutwardId},
    );

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        emit(state.copyWith(isLoading: false, inwardOutwardDetails: null));
      },
      (response) {
        final List<InwardOutwardModel> newData = List<InwardOutwardModel>.from(
          response["data"] ?? [],
        );
        emit(
          state.copyWith(
            isLoading: false,
            inwardOutwardDetails: newData.isEmpty ? null : newData.first,
          ),
        );
      },
    );
  }

  Future getInwardOutwardList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getInwardOutwardList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {
        "SystemGeneratedCode": state.searchText,
        "SenderName": state.filterBySenderName,
        "ReceiverName": state.filterByReceiverName,
        "DocumentType": state.filterByDocumentType,
        "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
        "DocumentTitle": state.filterByDocumentTitle,
        "SenderMobileNumber": state.filterBySenderMobileNumber,
        "ReceiverMobileNumber": state.filterByReceiverMobileNumber,
        "DeliveryStatus": state.filterByStatus,
        "FromDate": state.filterByFromDate.apiDate,
        "ToDate": state.filterByToDate.apiDate,
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
        "SystemGeneratedCode": state.searchText,
        "SenderName": state.filterBySenderName,
        "ReceiverName": state.filterByReceiverName,
        "DocumentType": "Inward",
        "DocumentTitle": state.filterByDocumentTitle,
        "SenderMobileNumber": state.filterBySenderMobileNumber,
        "ReceiverMobileNumber": state.filterByReceiverMobileNumber,
        "DeliveryStatus": state.filterByStatus,
        "FromDate": state.filterByFromDate.apiDate,
        "ToDate": state.filterByToDate.apiDate,
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

  Future getOutwardList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getInwardOutwardList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: {
        "SystemGeneratedCode": state.searchText,
        "SenderName": state.filterBySenderName,
        "ReceiverName": state.filterByReceiverName,
        "DocumentType": "Outward",
        "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
        "DocumentTitle": state.filterByDocumentTitle,
        "SenderMobileNumber": state.filterBySenderMobileNumber,
        "ReceiverMobileNumber": state.filterByReceiverMobileNumber,
        "DeliveryStatus": state.filterByStatus,
        "FromDate": state.filterByFromDate.apiDate,
        "ToDate": state.filterByToDate.apiDate,
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

  Future deleteInwardOutward({
    required BuildContext context,
    required int inwardOutwardId,
    required String uniqueKey,
    required int index,
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
        final updatedList = List<InwardOutwardModel>.from(
          state.inwardOutwardList,
        );
        updatedList.removeAt(index);

        emit(
          state.copyWith(
            inwardOutwardList: updatedList,
            isLoading: false,
            inwardOutwardTotalRecords:
                state.inwardOutwardTotalRecords > 0
                    ? state.inwardOutwardTotalRecords - 1
                    : 0,
          ),
        );
        if (context.mounted) {
          showSuccessMessage(
            context,
            subTitle: response["message"] ?? "Deleted Successfully",
          );
        }
      },
    );
  }

  Future<List<SenderDetailModel>> fetchSenderReceiverByMobile(
    String? mobileNumber,
  ) async {
    final result = await _repository.getSenderReceiverByMobileNo(
      mobileNumber: mobileNumber ?? "",
    );

    return result.fold(
      (failure) => [],
      (response) => List<SenderDetailModel>.from(response["data"] ?? []),
    );
  }

  Future addInwardOutward({
    required BuildContext context,
    required String deliveryType,
    required String inwardOutwardDate,
    required String invoiceNumber,
    required String invoiceDate,
    required String senderName,
    required String senderAddress,
    required String senderMobileNumberCountryCode,
    required String senderMobileNumber,
    required String senderEmailId,
    required String receiverName,
    required String receiverAddress,
    required String receiverMobileNumber,
    required String receiverMobileNumberCountryCode,
    required String receiverEmailId,
    required MultiFilePickerModel documentURL,
    required String employeeId,
    required String documentType,
    required MultiFilePickerModel acknowledgementSignature,
    required String acknowledgementBy,
    required String handOverTo,
    required String handOverDate,
    required String handoverPersonMobileNumberCountryCode,
    required String handoverPersonMobileNumber,
    required String chequeNumber,
    required String documentTitle,
    required String documentDescription,
    required double amount,
    required String deliveryMode,
    required String deliveryStatus,
    required MultiFilePickerModel acknowledgementURL,
    required String acknowledgementRemark,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "InwardOutwardId": "0",
      "DeliveryType": deliveryType,
      "InwardOutwardDate": inwardOutwardDate,
      "InVoiceNumber": invoiceNumber,
      "InVoiceDate": invoiceDate,
      "SenderName": senderName,
      "SenderAddress": senderAddress,
      "SenderMobileNumberCountryCode": senderMobileNumberCountryCode,
      "SenderMobileNumber": senderMobileNumber,
      "SenderEmailId": senderEmailId,
      "ReceiverName": receiverName,
      "ReceiverAddress": receiverAddress,
      "ReceiverMobileNumberCountryCode": receiverMobileNumberCountryCode,
      "ReceiverMobileNumber": receiverMobileNumber,
      "ReceiverEmailId": receiverEmailId,
      "RemoveDocumentURL": documentURL.deletedFileList,
      "EmployeeId": employeeId,
      "DocumentType": documentType,
      "RemoveAcknowledgementSignatureURL":
          acknowledgementSignature.deletedFileList,
      "AcknowledgementBy": acknowledgementBy,
      "HandOverTo": handOverTo,
      "HandOverDate": handOverDate,
      "HandoverPersonMobileNumberCountryCode":
          handoverPersonMobileNumberCountryCode,
      "HandoverPersonMobileNumber": handoverPersonMobileNumber,
      "ChequeNumber": chequeNumber,
      "DocumentTitle": documentTitle,
      "DocumentDescription": documentDescription,
      "Amount": amount.toString(),
      "DeliveryMode": deliveryMode,
      "DeliveryStatus": deliveryStatus,
      "RemoveAcknowledgementURL": acknowledgementURL.deletedFileList,
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
    for (int i = 0; i < acknowledgementSignature.fileNameList.length; i++) {
      if (acknowledgementSignature.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "AcknowledgementSignatureURL",
        "value": acknowledgementSignature.fileBytesList[i],
        "fileName": acknowledgementSignature.fileNameList[i],
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
    required int index,
    required String deliveryType,
    required String inwardOutwardDate,
    required String invoiceNumber,
    required String invoiceDate,
    required String senderName,
    required String senderAddress,
    required String senderMobileNumberCountryCode,
    required String senderMobileNumber,
    required String senderEmailId,
    required String receiverName,
    required String receiverAddress,
    required String receiverMobileNumber,
    required String receiverMobileNumberCountryCode,
    required String receiverEmailId,
    required MultiFilePickerModel documentURL,
    required String employeeId,
    required String documentType,
    required MultiFilePickerModel acknowledgementSignature,
    required String acknowledgementBy,
    required String handOverTo,
    required String handOverDate,
    required String handoverPersonMobileNumberCountryCode,
    required String handoverPersonMobileNumber,
    required String chequeNumber,
    required String documentTitle,
    required String documentDescription,
    required double amount,
    required String deliveryMode,
    required String deliveryStatus,
    required MultiFilePickerModel acknowledgementURL,
    required String acknowledgementRemark,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> body = {
      "InwardOutwardId": inwardOutwardId.toString(),
      "UniqueKey": uniqueKey,
      "DeliveryType": deliveryType,
      "InwardOutwardDate": inwardOutwardDate,
      "InVoiceNumber": invoiceNumber,
      "InVoiceDate": invoiceDate,
      "SenderName": senderName,
      "SenderAddress": senderAddress,
      "SenderMobileNumberCountryCode": senderMobileNumberCountryCode,
      "SenderMobileNumber": senderMobileNumber,
      "SenderEmailId": senderEmailId,
      "ReceiverName": receiverName,
      "ReceiverAddress": receiverAddress,
      "ReceiverMobileNumberCountryCode": receiverMobileNumberCountryCode,
      "ReceiverMobileNumber": receiverMobileNumber,
      "ReceiverEmailId": receiverEmailId,
      "RemoveDocumentURL": documentURL.deletedFileList,
      "EmployeeId": employeeId,
      "DocumentType": documentType,
      "RemoveAcknowledgementSignatureURL":
          acknowledgementSignature.deletedFileList,
      "AcknowledgementBy": acknowledgementBy,
      "HandOverTo": handOverTo,
      "HandOverDate": handOverDate,
      "HandoverPersonMobileNumberCountryCode":
          handoverPersonMobileNumberCountryCode,
      "HandoverPersonMobileNumber": handoverPersonMobileNumber,
      "ChequeNumber": chequeNumber,
      "DocumentTitle": documentTitle,
      "DocumentDescription": documentDescription,
      "Amount": amount.toString(),
      "DeliveryMode": deliveryMode,
      "DeliveryStatus": deliveryStatus,
      "RemoveAcknowledgementURL": acknowledgementURL.deletedFileList,
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
    for (int i = 0; i < acknowledgementSignature.fileNameList.length; i++) {
      if (acknowledgementSignature.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "AcknowledgementSignatureURL",
        "value": acknowledgementSignature.fileBytesList[i],
        "fileName": acknowledgementSignature.fileNameList[i],
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
        goRouter.pop();
        final updatedInwardOutward =
            (response['data'] as List<InwardOutwardModel>).first;

        switch (state.currentTabIndex) {
          case 0:
            if (state.inwardOutwardList.isNotEmpty &&
                index < state.inwardOutwardList.length) {
              final updatedList = List<InwardOutwardModel>.from(
                state.inwardOutwardList,
              );

              updatedList[index] = updatedInwardOutward;

              emit(
                state.copyWith(
                  isLoading: false,
                  inwardOutwardList: updatedList,
                ),
              );
            }
            break;

          case 1:
            if (state.inwardOutwardList.isNotEmpty &&
                index < state.inwardOutwardList.length) {
              final updatedList = List<InwardOutwardModel>.from(
                state.inwardOutwardList,
              );

              updatedList[index] = updatedInwardOutward;

              emit(
                state.copyWith(
                  isLoading: false,
                  inwardOutwardList: updatedList,
                ),
              );
            }
            break;

          case 2:
            if (state.inwardOutwardList.isNotEmpty &&
                index < state.inwardOutwardList.length) {
              final updatedList = List<InwardOutwardModel>.from(
                state.inwardOutwardList,
              );

              updatedList[index] = updatedInwardOutward;

              emit(
                state.copyWith(
                  isLoading: false,
                  inwardOutwardList: updatedList,
                ),
              );
            }
            break;
          default:
            break;
        }

        if (context.mounted) {
          showSuccessMessage(
            context,
            subTitle:
                response["message"] ?? "Inward Outward Updated Successfully",
          );
        }
      },
    );
  }

  Future addRevertInwardOutward({
    required BuildContext context,
    required int inwardOutwardId,
    required String uniqueKey,
    required String revertDate,
    required String revertRemark,
    required int index,
    required MultiFilePickerModel revertDocumentURL,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "InwardOutwardRevertId": 0.toString(),
      "InwardOutwardId": inwardOutwardId.toString(),
      "UniqueKey": uniqueKey,
      "RevertDate": revertDate,
      "RevertRemark": revertRemark,
    };

    List<Map<String, dynamic>> fileList = [];

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
        final updatedInwardOutward =
            (response['data'] as List<InwardOutwardModel>).first;

        if (state.inwardOutwardList.isNotEmpty &&
            index < state.inwardOutwardList.length) {
          final updatedList = List<InwardOutwardModel>.from(
            state.inwardOutwardList,
          );

          updatedList[index] = updatedInwardOutward;

          emit(
            state.copyWith(isLoading: false, inwardOutwardList: updatedList),
          );
        }
        goRouter.pop();
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

  Future updateRevertInwardOutward({
    required BuildContext context,
    required int inwardOutwardRevertId,
    required int inwardOutwardId,
    required String uniqueKey,
    required String revertDate,
    required String revertRemark,
    required int index,
    required MultiFilePickerModel revertDocumentURL,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> body = {
      "InwardOutwardRevertId": inwardOutwardRevertId.toString(),
      "InwardOutwardId": inwardOutwardId.toString(),
      "UniqueKey": uniqueKey,
      "RevertDate": revertDate,
      "RevertRemark": revertRemark,
      "RemoveRevertDocumentURL": revertDocumentURL.deletedFileList,
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
        final updatedInwardOutward =
            (response['data'] as List<InwardOutwardModel>);

        emit(
          state.copyWith(
            isLoading: false,
            inwardOutwardDetails:
                updatedInwardOutward.isNotEmpty
                    ? updatedInwardOutward.first
                    : null,
          ),
        );

        goRouter.pop();
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

  Future deleteRevert({
    required BuildContext context,
    required int inwardOutwardRevertId,
    required int inwardOutwardId,
    required String uniqueKey,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _repository.deleteInwardOutwardRevert(
      inwardOutwardRevertId: inwardOutwardRevertId,
      inwardOutwardId: inwardOutwardId,
      uniqueKey: uniqueKey,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        final currentDetails = state.inwardOutwardDetails;

        if (currentDetails == null) return;

        final updatedRevertHistory = List<InwardOutwardRevertHistoryModel>.from(
          currentDetails.inwardOutwardRevertHistory,
        );

        if (index >= 0 && index < updatedRevertHistory.length) {
          updatedRevertHistory.removeAt(index);
        }

        final updatedInwardOutwardDetails = InwardOutwardModel(
          inwardOutwardId: currentDetails.inwardOutwardId,
          uniqueKey: currentDetails.uniqueKey,
          systemGeneratedCode: currentDetails.systemGeneratedCode,
          deliveryType: currentDetails.deliveryType,
          departmentName: currentDetails.departmentName,
          inwardOutwardDate: currentDetails.inwardOutwardDate,
          senderName: currentDetails.senderName,
          senderAddress: currentDetails.senderAddress,
          senderMobileNumber: currentDetails.senderMobileNumber,
          senderMobileNumberCountryCode:
              currentDetails.senderMobileNumberCountryCode,
          senderEmailId: currentDetails.senderEmailId,
          receiverName: currentDetails.receiverName,
          receiverAddress: currentDetails.receiverAddress,
          receiverMobileNumberCountryCode:
              currentDetails.receiverMobileNumberCountryCode,
          receiverMobileNumber: currentDetails.receiverMobileNumber,
          receiverEmailId: currentDetails.receiverEmailId,
          documentURL: currentDetails.documentURL,
          employeeId: currentDetails.employeeId,
          employeeNames: currentDetails.employeeNames,
          documentType: currentDetails.documentType,
          invoiceNumber: currentDetails.invoiceNumber,
          invoiceDate: currentDetails.invoiceDate,
          acknowledgementBy: currentDetails.acknowledgementBy,
          acknowledgementSignatureURL:
              currentDetails.acknowledgementSignatureURL,
          chequeNumber: currentDetails.chequeNumber,
          documentTitle: currentDetails.documentTitle,
          amount: currentDetails.amount,
          deliveryMode: currentDetails.deliveryMode,
          deliveryStatus: currentDetails.deliveryStatus,
          documentDescription: currentDetails.documentDescription,
          handOverTo: currentDetails.handOverTo,
          handOverDate: currentDetails.handOverDate,
          handoverPersonMobileNumberCountryCode:
              currentDetails.handoverPersonMobileNumberCountryCode,
          handoverPersonMobileNumber: currentDetails.handoverPersonMobileNumber,
          acknowledgementRemark: currentDetails.acknowledgementRemark,
          acknowledgementURL: currentDetails.acknowledgementURL,

          inwardOutwardRevertHistory: updatedRevertHistory,

          createdById: currentDetails.createdById,
          createdBy: currentDetails.createdBy,
          createdDate: currentDetails.createdDate,
          modifiedById: currentDetails.modifiedById,
          modifiedBy: currentDetails.modifiedBy,
          modifiedDate: currentDetails.modifiedDate,
        );

        emit(
          state.copyWith(
            inwardOutwardDetails: updatedInwardOutwardDetails,
            isLoading: false,
          ),
        );

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

  Future<Map<String, dynamic>> fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"EmployeeName": value, "isCheckPermission": false}
              : {"isCheckPermission": false},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees = response['data'] as List<UserModel>;

        return {
          "itemList":
              employees.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> queryParams = {"ExportType": exportType};

    if (state.searchText.isNotEmpty) {
      queryParams["SystemGeneratedCode"] = state.searchText;
    }

    switch (state.currentTabIndex) {
      case 1:
        queryParams["Type"] = "Inward";
        break;

      case 2:
        queryParams["Type"] = "Outward";
        break;
    }

    final result = await _repository.getInwardOutwardListForExport(
      pageNumber: 1,
      pageSize: state.inwardOutwardTotalRecords,
      queryParams: queryParams,
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
              ? "Inward Outward ${DateTime.now()}.pdf"
              : "Inward Outward ${DateTime.now()}.xlsx",
        );
      },
    );
  }

  int updateFilterCount(InwardOutwardState state) {
    final hasSort =
        state.currentSortColumn == "IO Code" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");

    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByDocumentType.trim().isNotEmpty,
      state.filterBySenderName.trim().isNotEmpty,
      state.filterByReceiverName.trim().isNotEmpty,
      state.filterByDocumentTitle.trim().isNotEmpty,
      state.filterByStatus.trim().isNotEmpty,
      state.filterBySenderMobileNumber.trim().isNotEmpty,
      state.filterByReceiverMobileNumber.trim().isNotEmpty,
      state.filterByFromDate != null,
      state.filterByToDate != null,
      hasSort,
    ]);
  }
}
