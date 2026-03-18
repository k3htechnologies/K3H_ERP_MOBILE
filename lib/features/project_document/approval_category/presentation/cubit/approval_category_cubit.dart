import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/model/approval_category.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/repository/approval_category.repository.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/presentation/cubit/approval_category_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class ApprovalCategoryCubit extends Cubit<ApprovalCategoryState> {
  ApprovalCategoryCubit() : super(ApprovalCategoryState.initial());

  final ApprovalCategoryRepository _documentCategoryRepository =
      serviceLocator<ApprovalCategoryRepository>();

  // <---- GET APPROVE DOCUMENT CATEGORY LIST ---->
  Future getApprovalapprovalCategoryList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ApprovalDocumentCategory": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _documentCategoryRepository.getApprovalDocumentCategory(
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
        final List<ApprovalDocumentCategoryModel> newData =
            List<ApprovalDocumentCategoryModel>.from(response['data'] ?? []);

        final List<ApprovalDocumentCategoryModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.approvalCategoryList, ...newData];
        emit(
          state.copyWith(
            approvalCategoryList: updatedList,
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
        approvalCategoryList: [],
        currentPage: 1,
      ),
    );
    await getApprovalapprovalCategoryList(context, 1, projectId);
  }

  // <---- CLEAR APPROVE DOCUMENT CATEGORY LIST ---->
  void clearApprovalDocumentCategory() {
    try {
      emit(
        state.copyWith(
          approvalCategoryList: [],
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

  // <---- DELETE APPROVE DOCUMENT CATEGORY  ---->
  Future deleteApprovalDocumentCategory(
    int projectId,
    ApprovalDocumentCategoryModel approvalCategoryModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _documentCategoryRepository
        .deleteApprovalDocumentCategory(
          projectApprovalDocumentCategoryId:
              approvalCategoryModel.approvalDocumentCategoryId,
          uniqueKey: approvalCategoryModel.uniquekey,
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
          subTitle: "Document Category Deleted Successfully",
        );

        getApprovalapprovalCategoryList(context, state.currentPage, projectId);
      },
    );
  }

  // ADD APPROVE DOCUMENT CATEGORY
  Future addApprovalDocumentCategory({
    required BuildContext context,
    required int index,
    required int projectId,
    required String projectApprovalDocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ApprovalDocumentCategoryId": 0,
      "ProjectId": projectId,
      "ApprovalDocumentCategory": projectApprovalDocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _documentCategoryRepository
        .addUpdateApprovalDocumentCategory(body: body);
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
          subTitle: 'Approval Category Added Successfully',
        );
        searchCategory(context, projectId, "");
      },
    );
  }

  //UPDATE APPROVE DOCUMENT CATEGORY
  Future updateApprovalDocumentCategory({
    required int index,
    required BuildContext context,
    required String uniqueKey,
    required int projectApprovalDocumentCategoryId,
    required int projectId,
    required String projectApprovalDocumentCategory,
    required int orderBy,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "ApprovalDocumentCategoryId": projectApprovalDocumentCategoryId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "ApprovalDocumentCategory": projectApprovalDocumentCategory,
      "OrderBy": orderBy,
    };
    var result = await _documentCategoryRepository
        .addUpdateApprovalDocumentCategory(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        final updatedList =
            response['data'][0] as ApprovalDocumentCategoryModel;

        if (state.approvalCategoryList.isNotEmpty &&
            index < state.approvalCategoryList.length) {
          final updatedListModel = List<ApprovalDocumentCategoryModel>.from(
            state.approvalCategoryList,
          );
          updatedListModel[index] = updatedList;
          emit(state.copyWith(approvalCategoryList: updatedListModel));
        }

        showSuccessMessage(
          context,
          subTitle: "Approval Category Updated Successfully",
        );
      },
    );
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(
    BuildContext context,
    String exportType,
    int projectId,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _documentCategoryRepository.exportApprovalCategory(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      projectId: projectId,
      queryParams:
          state.searchText != ""
              ? {
                "ApprovalDocumentCategory": state.searchText,
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
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Approval Category Master ${DateTime.now()}.pdf"
              : "Approval Category Master ${DateTime.now()}.xlsx",
        );
        showSuccessMessage(
          context,
          subTitle: 'Exported as $exportType Successfully',
        );
      },
    );
  }
}
