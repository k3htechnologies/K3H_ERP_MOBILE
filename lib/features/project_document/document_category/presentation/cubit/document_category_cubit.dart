import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/model/document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/repository/document_category.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

part 'document_category_state.dart';

class DocumentCategoryCubit extends Cubit<DocumentCategoryState> {
  DocumentCategoryCubit() : super(DocumentCategoryState.initial());
  
  final DocumentCategoryRepository _documentCategoryRepository =
  serviceLocator<DocumentCategoryRepository>();


  // <---- GET DOCUMENT CATEGORY LIST ---->
  Future getDocumentCategoryList(BuildContext context, int pageNumber,int projectId) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "DepartmentName": state.searchText,
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
        final List<DocumentCategoryModel> newData = List<DocumentCategoryModel>.from(
          response['data'] ?? [],
        );

        final List<DocumentCategoryModel> updatedList =
        pageNumber == 1 ? newData : [...state.documentCategoryList, ...newData];
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
  
}
