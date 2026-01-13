import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
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
          getProjectDocumentList(context, 1, 20, projectId);
        }
      },
    );
  }

  // <---- GET PROJECT DOCUMENT ---->
  Future getProjectDocumentList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ProjectDocumentName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "ProjectDocumentCategoryId": state.projectDocumentCategoryId,
    };

    var result = await _documentRepository.pullProjectDocument(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
      },
      (response) {
        List<DocumentModel> updatedList = List.from(state.documentList);
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
    required String uniqueKey,
    required int projectDocumentId,
    required int projectDocumentCategoryId,
    required int projectId,
    required String projectDocumentName,
  }) async {
    List<Map<String, dynamic>> fileList = [];

    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentId": projectDocumentId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": projectId.toString(),
      "ProjectDocumentName": projectDocumentName,
      "ProjectDocumentCategoryId": projectDocumentCategoryId.toString(),
      "IsMaster": 1.toString(),
    };

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
          updatedListModel[index] = updatedList;
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
    required int projectDocumentId,
    required int projectDocumentCategoryId,
    required int projectId,
    required String projectDocumentName,
  }) async {
    List<Map<String, dynamic>> fileList = [];

    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentId": 0.toString(),
      "ProjectId": projectId.toString(),
      "ProjectDocumentName": projectDocumentName,
      "ProjectDocumentCategoryId": projectDocumentCategoryId.toString(),

      "IsMaster": 1.toString(),
    };

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
    getProjectDocumentList(
      context,
      1,
      10,
      state.documentCategoryModelList[index].projectId,
    );
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
    getProjectDocumentList(context, 1, 10, getProject().projectId);
  }
}
