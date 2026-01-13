import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/data/repository/document.repository.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/model/document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/repository/document_category.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

part 'document_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  DocumentCubit() : super(DocumentState.initial());

  final DocumentCategoryRepository _documentCategoryRepository =
      serviceLocator<DocumentCategoryRepository>();
  final DocumentRepository _documentRepository =
      serviceLocator<DocumentRepository>();

  // <---- GET CATEGORY LIST ---->
  Future getCategoryList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    var result = await _documentCategoryRepository.getDocumentCategory(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        emit(
          state.copyWith(
            isLoading: false,
            documentCategoryModelList:
                response['data'] as List<DocumentCategoryModel>,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
            categoryIndex:
                (response['data'] as List<DocumentCategoryModel>).isEmpty
                    ? -1
                    : 0,
            projectDocumentCategoryId:
                (response['data'] as List<DocumentCategoryModel>).isEmpty
                    ? 0
                    : (response['data'] as List<DocumentCategoryModel>)
                        .first
                        .projectDocumentCategoryId,
          ),
        );
        if ((response['data'] as List<DocumentCategoryModel>).isNotEmpty) {
          getProjectDocumentList(context: context, pageNumber: 1);
        }
      },
    );
  }

  // <---- GET PROJECT DOCUMENT ---->
  Future getProjectDocumentList({
    required BuildContext context,
    required int pageNumber,
    int? projectDocumentId,
  }) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ProjectDocumentName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "ProjectDocumentCategoryId": state.projectDocumentCategoryId,
      "ProjectDocumentId": projectDocumentId,
    };

    var result = await _documentRepository.pullProjectDocument(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
      },
      (response) {
        List<DocumentModel> updatedList = [];
        updatedList.addAll(response['data'] as List<DocumentModel>);
        emit(
          state.copyWith(
            isLoading: false,
            documentList: updatedList,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  //UPDATE DOCUMENT IN CATEGORY
  Future updateDocumentInCategory({
    required int index,
    required BuildContext context,
    required int projectDocumentId,
    required String uniqueKey,
    required String projectDocumentName,
    required int projectId,
    required int projectDocumentCategoryId,
    DateTime? projectDocumentExpiryDate,
    String? projectDocumentStatus,
    String? projectDocumentRemark,
    MultiFilePickerModel? documents,
    required int isMaster,
  }) async {
    List<Map<String, dynamic>> fileList = [];
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentId": projectDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": projectId.toString(),
      "ProjectDocumentName": projectDocumentName,
      "ProjectDocumentCategoryId": projectDocumentCategoryId.toString(),
      "IsMaster": isMaster.toString(),
    };
    var addDocBody = {
      "ProjectDocumentExpiryDate":
          projectDocumentExpiryDate != null
              ? projectDocumentExpiryDate.toIso8601String()
              : '',
      "ProjectDocumentStatus": projectDocumentStatus ?? '',
      "ProjectDocumentRemark": projectDocumentRemark ?? '',
    };
    final bool isNewDocUpload =
        projectDocumentStatus != null && projectDocumentStatus.isNotEmpty;

    if (isNewDocUpload) {
      body.addAll(addDocBody);
    }
    if (documents != null) {
      for (int i = 0; i < documents.fileNameList.length; i++) {
        if (documents.fileNameList[i].contains("http")) {
          continue;
        }
        fileList.add({
          "key": "ProjectDocumentURL",
          "value": documents.fileBytesList[i],
          "fileName": documents.fileNameList[i],
        });
      }
    }

    var result = await _documentRepository.addUpdateDocument(
      body: body,
      fileList: fileList,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = response['data'][0] as DocumentModel;

        if (state.documentList.isNotEmpty &&
            index < state.documentList.length) {
          final updatedListModel = List<DocumentModel>.from(state.documentList);
          if (!isNewDocUpload) {
            updatedListModel[index] = updatedList;
          } else {
            updatedListModel[index] = updatedListModel[index].copyWith(
              approvalPendingProjectDocumentCount:
                  updatedListModel[index].approvalPendingProjectDocumentCount +
                  1,
              uploadedProjectDocumentCount:
                  updatedListModel[index].uploadedProjectDocumentCount + 1,
            );
          }

          emit(state.copyWith(documentList: updatedListModel));
        }

        showSuccessMessage(
          context,
          subTitle: "Project Document Updated Successfully",
        );
      },
    );
  }

  //ADD DOCUMENT TO CATEGORY
  Future addDocumentToCategory({
    required BuildContext context,
    required String projectDocumentName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentId": 0.toString(),
      "ProjectId": getProject().projectId.toString(),
      "ProjectDocumentName": projectDocumentName,
      "ProjectDocumentCategoryId":
          state
              .documentCategoryModelList[state.categoryIndex]
              .projectDocumentCategoryId
              .toString(),

      "IsMaster": 1.toString(),
    };

    var result = await _documentRepository.addUpdateDocument(
      body: body,
      fileList: [],
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = response['data'][0] as DocumentModel;
        var list = [updatedList, ...state.documentList];

        emit(state.copyWith(documentList: list));

        showSuccessMessage(
          context,
          subTitle: "Project Document Added Successfully",
        );
      },
    );
  }

  //UPDATE CATEGORY INDEX AND MAKE GET API CALL AS PER CATEGORY
  void onTabChanged(int index, BuildContext context) {
    emit(
      state.copyWith(
        categoryIndex: index,
        projectDocumentCategoryId:
            state.documentCategoryModelList[index].projectDocumentCategoryId,
      ),
    );
    getProjectDocumentList(context: context, pageNumber: 1);
  }

  // SEARCH BASED ON SHIFT
  void searchDocument(String value, BuildContext context) {
    emit(
      state.copyWith(
        documentList: [],
        isLoading: true,
        searchText: value,
        currentPage: 1,
      ),
    );
    getProjectDocumentList(context: context, pageNumber: 1);
  }
}
