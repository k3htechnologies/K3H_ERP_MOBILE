import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/model/document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/repository/document_category.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'document_category_state.dart';

class DocumentCategoryCubit extends Cubit<DocumentCategoryState> {
  DocumentCategoryCubit() : super(DocumentCategoryState.initial());

  final DocumentCategoryRepository _documentCategoryRepository =
      serviceLocator<DocumentCategoryRepository>();

  // SEARCH CATEGORY
  Future searchCategory(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(
      state.copyWith(
        searchText: value,
        documentCategoryList: [],
        currentPage: 1,
      ),
    );
    await getDocumentCategoryList(context, 1, projectId);
  }

  // CLEAR DOCUMENT CATEGORY LIST
  void clearDocumentCategory() {
    try {
      emit(
        state.copyWith(
          documentCategoryList: [],
          currentPage: 1,
          totalNumberOfRecord: 0,
          isLoading: true,
          searchText: "",
        ),
      );
    } catch (e) {
      // Cubit is closed, ignore
    }
  }

  // GET DOCUMENT CATEGORY LIST
  Future getDocumentCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        DocumentCategoryCubit();
        emit(state.copyWith(isLoading: false, documentCategoryList: []));
      });
      return;
    }
    Map<String, dynamic> queryParams = {
      "ProjectDocumentCategory": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _documentCategoryRepository.getDocumentCategory(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<DocumentCategoryModel> newData =
            List<DocumentCategoryModel>.from(response['data'] ?? []);

        final List<DocumentCategoryModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.documentCategoryList, ...newData];
        emit(
          state.copyWith(
            documentCategoryList: updatedList,
            isLoading: false,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // DELETE DOCUMENT CATEGORY
  Future deleteDocumentCategory(
    int projectId,
    DocumentCategoryModel documentCategoryModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _documentCategoryRepository.deleteDocumentCategory(
      projectDocumentCategoryId:
          documentCategoryModel.projectDocumentCategoryId,
      uniqueKey: documentCategoryModel.uniquekey,
      projectId: projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        showSuccessMessage(
          context,
          subTitle: "Project Document Category Deleted Successfully",
        );

        getDocumentCategoryList(context, state.currentPage, projectId);
      },
    );
  }

  // ADD DOCUMENT CATEGORY
  Future addDocumentCategory({
    required BuildContext context,
    required int index,
    required int projectId,
    required String projectDocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentCategoryId": 0,
      "ProjectId": projectId,
      "ProjectDocumentCategory": projectDocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _documentCategoryRepository.addUpdateDocumentCategory(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        showSuccessMessage(
          context,
          subTitle: 'Project Document Category Added Successfully',
        );
        searchCategory(context, projectId, "");
      },
    );
  }

  //UPDATE DOCUMENT CATEGORY
  Future updateDocumentCategory({
    required int index,
    required BuildContext context,
    required String uniqueKey,
    required int projectDocumentCategoryId,
    required int projectId,
    required String projectDocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectDocumentCategoryId": projectDocumentCategoryId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "ProjectDocumentCategory": projectDocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _documentCategoryRepository.addUpdateDocumentCategory(
      body: body,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = response['data'][0] as DocumentCategoryModel;

        if (state.documentCategoryList.isNotEmpty &&
            index < state.documentCategoryList.length) {
          final updatedListModel = List<DocumentCategoryModel>.from(
            state.documentCategoryList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(documentCategoryList: updatedListModel));
        }

        showSuccessMessage(
          context,
          subTitle: "Project Document Category Updated Successfully",
        );
      },
    );
  }

  // EXPORT EXCEL PDF
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _documentCategoryRepository.exportDocumentCategory(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      queryParams:
          state.searchText != ""
              ? {
                "ProjectDocumentCategory": state.searchText,
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
              ? "Project Document Category Master ${DateTime.now()}.pdf"
              : "Project Document Category Master ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
