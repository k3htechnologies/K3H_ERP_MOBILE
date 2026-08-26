import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/finance/document/data/model/term_sheet_documents.model.dart';
import 'package:k3h_erp_app/features/finance/document/data/repository/document.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'documents_state.dart';

class DocumentsCubit extends Cubit<DocumentsState> {
  DocumentsCubit() : super(DocumentsState.inital());

  // REPOSITORY
  final DocumentsRepository _documentsRepository =
      serviceLocator<DocumentsRepository>();

  Future<void> getTermSheetDocumentList(
    BuildContext context,
    int pageNumber, {
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
  }) async {
    emit(state.copywith(isLoading: true));

    final Map<String, dynamic> queryParams = {
      "IsCheckPermission": true,
      "ProjectId": projectId,
      "TermSheetId": termSheetId,
      "TermSheetDetailsId": termSheetDetailsId,
    };

    final result = await _documentsRepository.getTermSheetDocumentList(
      pageSize: 10,
      pageNumber: pageNumber,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copywith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final logs = response['data'] as List<TermSheetDocumentModel>;
        final List<TermSheetDocumentModel> updatedList =
            pageNumber == 1 ? logs : [...state.termSheetDocumentList, ...logs];
        emit(
          state.copywith(
            termSheetDocumentList: updatedList,
            termSheetDocumentOverview: logs.isNotEmpty ? logs.first : null,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            currentPage: pageNumber,
            isLoading: false,
          ),
        );
      },
    );

    emit(state.copywith(isLoading: false));
  }

  Future<void> addTermSheetDocument({
    required BuildContext context,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
    required String documentName,
    required String remark,
    required MultiFilePickerModel file,
    required bool isSubmittedOriginalDocument,
    required bool isCollectedOriginalDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final body = <String, String>{
      "TermSheetId": termSheetId.toString(),
      "TermSheetDetailsId": termSheetDetailsId.toString(),
      "ProjectId": projectId.toString(),
      "DocumentName": documentName,
      "DocumentRemark": remark,
      "IsCollectedOriginalDocument": isCollectedOriginalDocument.toString(),
      "IsSubmittedOriginalDocument": isSubmittedOriginalDocument.toString(),
    };

    debugPrint("DOCUMENT BODY: $body");

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < file.fileNameList.length; i++) {
      if (file.fileNameList[i].startsWith("http")) {
        continue;
      }

      fileList.add({
        "key": "DocumentURL",
        "value": file.fileBytesList[i],
        "fileName": file.fileNameList[i],
      });
    }

    final result = await _documentsRepository.addUpdateTermSheetDocument(
      body: body,
      fileList: fileList,
    );

    if (context.mounted) {
      goRouter.pop();
    }

    result.fold(
      (failure) {
        if (context.mounted) {
          showErrorMessage(context, "Error", failure.message);
        }
      },
      (response) async {
        if (context.mounted) {
          showSuccessMessage(context, subTitle: response["message"]);
        }
        await getTermSheetDocumentList(
          context,
          1,
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
        );

        if (context.mounted) {
          goRouter.pop();
        }
      },
    );
  }

  Future<void> updateTermSheetDocument({
    required BuildContext context,
    required int termSheetDocumentId,
    required String uniquekey,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
    required String documentName,
    required String remark,
    required MultiFilePickerModel file,
    required bool isSubmittedOriginalDocument,
    required bool isCollectedOriginalDocument,
    DateTime? collectedOriginalDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final body = <String, String>{
      "TermSheetDocumentId": termSheetDocumentId.toString(),
      "Uniquekey": uniquekey,
      "TermSheetId": termSheetId.toString(),
      "TermSheetDetailsId": termSheetDetailsId.toString(),
      "ProjectId": projectId.toString(),
      "DocumentName": documentName,
      "DocumentRemark": remark,
      "IsCollectedOriginalDocument": isCollectedOriginalDocument.toString(),
      "IsSubmittedOriginalDocument": isSubmittedOriginalDocument.toString(),
    };
    if (collectedOriginalDate != null) {
      body["CollectedOriginalDocumentDate"] = collectedOriginalDate.apiDate!;
    }
    debugPrint("DOCUMENT BODY: $body");

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < file.fileNameList.length; i++) {
      if (file.fileNameList[i].startsWith("http")) {
        continue;
      }

      fileList.add({
        "key": "DocumentURL",
        "value": file.fileBytesList[i],
        "fileName": file.fileNameList[i],
      });
    }

    final result = await _documentsRepository.addUpdateTermSheetDocument(
      body: body,
      fileList: fileList,
    );

    if (context.mounted) {
      goRouter.pop();
    }

    result.fold(
      (failure) {
        if (context.mounted) {
          showErrorMessage(context, "Error", failure.message);
        }
      },
      (response) async {
        if (context.mounted) {
          showSuccessMessage(context, subTitle: response["message"]);
        }
        await getTermSheetDocumentList(
          context,
          1,
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
        );

        if (context.mounted) {
          goRouter.pop();
        }
      },
    );
  }

  Future<void> deleteTermSheetDocument({
    required BuildContext context,
    required int termSheetDocumentId,
    required String uniquekey,
    required int termSheetId,
    required int termSheetDetailsId,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _documentsRepository.deleteTermSheetDocument(
      termSheetDocumentId: termSheetDocumentId,
      uniquekey: uniquekey,
      termSheetId: termSheetId,
      termSheetDetailsId: termSheetDetailsId,
      projectId: projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["message"]);
        await getTermSheetDocumentList(
          context,
          1,
          projectId: projectId,
          termSheetId: termSheetId,
          termSheetDetailsId: termSheetDetailsId,
        );
      },
    );
  }
}
