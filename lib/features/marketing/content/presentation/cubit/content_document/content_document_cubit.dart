import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/marketing/content/data/model/content_document.model.dart';
import 'package:k3h_erp_app/features/marketing/content/data/repository/content_repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'content_document_state.dart';

class ContentDocumentCubit extends Cubit<ContentDocumentState> {
  ContentDocumentCubit() : super(ContentDocumentState.initial());

  final ContentRepository _contentRepository =
  serviceLocator<ContentRepository>();

  // <---- RESET STATE ---->
  void resetState() {
    emit(ContentDocumentState.initial());
  }
  

  // <---- GET MARKETING CONTENT LIST ---->
  Future getContentDocumentList(
      BuildContext context,
      int pageNumber,
      int pageSize,
      int projectId,
      int marketingContentFolderId,
      ) async {
    emit(state.copyWith(isLoading: true));

    var result = await _contentRepository.getMarketingContentList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
      marketingContentFolderId: marketingContentFolderId,
      queryParams: {
        "Title": state.searchText,
        "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      },
    );
    result.fold(
          (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
          (response) {
        List<ContentDocumentModel> updatedList = List.from(
          state.marketingContentDocumentList,
        );
        updatedList = response['data'] as List<ContentDocumentModel>;
        emit(
          state.copyWith(
            isLoading: false,
            marketingContentDocumentList: updatedList,
            totalNumberOfRecord:
            response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                ? state.totalNumberOfRecord - 1
                : response['totalNumberOfRecord'],
            currentPage: pageNumber,
            selectedFolderCount: 0,
          ),
        );
      },
    );
  }

  // <---- ADD MARKETING CONTENT --->
  Future<bool> addMarketingContent(
      BuildContext context, {
        required int projectId,
        required int marketingContentFolderId,
        required String title,
        required String remark,
        required MultiFilePickerModel marketingContentDocument,
      }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "MarketingContentId": "0",
      "ProjectId": projectId.toString(),
      "MarketingContentFolderId": marketingContentFolderId.toString(),
      "Title": title,
      "Remark": remark,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < marketingContentDocument.fileNameList.length; i++) {
      if (marketingContentDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "MarketingContentURL",
        "value": marketingContentDocument.fileBytesList[i],
        "fileName": marketingContentDocument.fileNameList[i],
      });
    }

    var addResult = await _contentRepository.addUpdateContentDocument(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    return addResult.fold(
          (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return false;
      },
          (response) {
        var list = [
          response['data'][0] as ContentDocumentModel,
          ...state.marketingContentDocumentList,
        ];

        emit(
          state.copyWith(
            marketingContentDocumentList: list,
            totalNumberOfRecord:
            state.totalNumberOfRecord == -1
                ? 1
                : state.totalNumberOfRecord + 1,
          ),
        );
        goRouter.pop();
        showSuccessMessage(context);

        // Return true to indicate document was added successfully
        // This will be used by the folder screen to refresh the list
        return true;
      },
    );
  }

  // <---- UPDATE MARKETING CONTENT --->
  Future<void> updateMarketingContent(
      BuildContext context, {
        required int projectId,
        required int marketingContentFolderId,
        required int marketingContentId,
        required String uniqueKey,
        required String title,
        required String remark,
        required MultiFilePickerModel marketingContentDocument,
        required int index,
      }) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, String> requestBody = {
      "MarketingContentId": marketingContentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": projectId.toString(),
      "MarketingContentFolderId": marketingContentFolderId.toString(),
      "Title": title,
      "Remark": remark,
      "RemoveMarketingContentURL": marketingContentDocument.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < marketingContentDocument.fileNameList.length; i++) {
      if (marketingContentDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "MarketingContentURL",
        "value": marketingContentDocument.fileBytesList[i],
        "fileName": marketingContentDocument.fileNameList[i],
      });
    }

    var updateResult = await _contentRepository.addUpdateContentDocument(
      body: requestBody,
      fileList: fileList,
    );
    goRouter.pop();
    updateResult.fold(
          (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
          (response) {
        goRouter.pop();

        List<ContentDocumentModel> list = List.from(
          state.marketingContentDocumentList,
        );
        list[index] = (response['data'][0] as ContentDocumentModel);
        emit(
          state.copyWith(
            marketingContentDocumentList: list,
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  // <---- DELETE MARKETING CONTENT ---->
  Future<bool> deleteMarketingContent({
    required BuildContext context,
    required int marketingContentId,
    required int marketingContentFolderId,
    required int projectId,
    required String uniqueKey,
    required int pageNumber,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _contentRepository.deleteMarketingContent(
      marketingContentFolderId: marketingContentFolderId,
      marketingContentId: marketingContentId,
      projectId: projectId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    return deleteResult.fold(
          (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return false;
      },
          (response) {
        showSuccessMessage(context);
        if (index != null) {
          final updatedList = List<ContentDocumentModel>.from(
            state.marketingContentDocumentList,
          );
          updatedList.removeAt(index);
          emit(
            state.copyWith(
              marketingContentDocumentList: updatedList,
              totalNumberOfRecord:
              state.totalNumberOfRecord > 0
                  ? state.totalNumberOfRecord - 1
                  : 0,
            ),
          );
        } else {
          getContentDocumentList(
            context,
            pageNumber,
            pageSize,
            projectId,
            marketingContentFolderId,
          );
        }
        return true;
      },
    );
  }

  // <---- SEARCH LITIGATION ---->
  Future searchContentDocument(
      BuildContext context,
      String value,
      int projectId,
      int marketingContentFolderId,
      ) async {
    emit(state.copyWith(searchText: value, marketingContentDocumentList: []));
    await getContentDocumentList(
      context,
      1,
      10,
      projectId,
      marketingContentFolderId,
    );
  }

  // <---- SORT CONTENT DOCUMENT ---->
  Future sortContentDocument(
      BuildContext context,
      String value,
      String direction,
      int projectId,
      int marketingContentFolderId,
      ) async {
    emit(
      state.copyWith(
        currentSortColumn: value,
        currentSortDirection: direction,
        marketingContentDocumentList: [],
      ),
    );
    await getContentDocumentList(
      context,
      1,
      10,
      projectId,
      marketingContentFolderId,
    );
  }
}
