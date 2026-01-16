import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/repository/document_category.repository.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/cubit/rera_document_category_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class RERADocumentCategoryCubit extends Cubit<RERADocumentCategoryState> {
  RERADocumentCategoryCubit() : super(RERADocumentCategoryState.initial());

  final RERADocumentCategoryRepository _reraDocumentCategoryRepository =
      serviceLocator<RERADocumentCategoryRepository>();

  // <---- GET RERA DOCUMENT CATEGORY LIST ---->
  Future getRERADocumentCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ProjectRERADocumentCategory": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _reraDocumentCategoryRepository.getReraDocumentCategory(
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
        final List<RERADocumentCategoryModel> newData =
            List<RERADocumentCategoryModel>.from(response['data'] ?? []);

        final List<RERADocumentCategoryModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.reraDocumentCategoryList, ...newData];
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

  // <---- SEARCH CATEGORY ---->
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
    await getRERADocumentCategoryList(context, 1, projectId);
  }

  // <---- CLEAR RERA DOCUMENT CATEGORY LIST ---->
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

  // <---- DELETE RERA DOCUMENT CATEGORY  ---->
  Future deleteRERADocumentCategory(
    int projectId,
    RERADocumentCategoryModel reraDocumentCategoryModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _reraDocumentCategoryRepository
        .deleteReraDocumentCategory(
          projectRERADocumentCategoryId:
              reraDocumentCategoryModel.projectRERADocumentCategoryId,
          uniqueKey: reraDocumentCategoryModel.uniquekey,
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
          subTitle: "RERA DOCUMENT CATEGORY Deleted Successfully",
        );

        getRERADocumentCategoryList(context, state.currentPage, projectId);
      },
    );
  }

  // ADD RERA DOCUMENT CATEGORY
  Future addRERADocumentCategory({
    required BuildContext context,
    required int index,
    required int projectId,
    required String projectRERADocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectRERADocumentCategoryId": 0,
      "ProjectId": projectId,
      "ProjectRERADocumentCategory": projectRERADocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _reraDocumentCategoryRepository
        .addUpdateReraDocumentCategory(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final newResponse = response['data'][0] as RERADocumentCategoryModel;

        var list = [newResponse, ...state.reraDocumentCategoryList];
        emit(
          state.copyWith(
            documentCategoryList: list,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
        showSuccessMessage(
          context,
          subTitle: 'Week Off Mapping Added Successfully',
        );
      },
    );
  }

  //UPDATE RERA DOCUMENT CATEGORY
  Future updateRERADocumentCategory({
    required int index,
    required BuildContext context,
    required String uniqueKey,
    required int projectDocumentCategoryId,
    required int projectId,
    required String projectRERADocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ProjectRERADocumentCategoryId": projectDocumentCategoryId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "ProjectRERADocumentCategory": projectRERADocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _reraDocumentCategoryRepository
        .addUpdateReraDocumentCategory(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList = response['data'][0] as RERADocumentCategoryModel;

        if (state.reraDocumentCategoryList.isNotEmpty &&
            index < state.reraDocumentCategoryList.length) {
          final updatedListModel = List<RERADocumentCategoryModel>.from(
            state.reraDocumentCategoryList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(documentCategoryList: updatedListModel));
        }

        showSuccessMessage(
          context,
          subTitle: "Week Off Mapping Updated Successfully",
        );
      },
    );
  }
}
