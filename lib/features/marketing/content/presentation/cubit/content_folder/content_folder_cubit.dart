import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/marketing/content/data/model/content_folder.model.dart';
import 'package:k3h_erp_app/features/marketing/content/data/repository/content_repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'content_folder_state.dart';

class ContentFolderCubit extends Cubit<ContentFolderState> {
  ContentFolderCubit() : super(ContentFolderState.initial());

  final ContentRepository _contentRepository =
      serviceLocator<ContentRepository>();

  // SEARCH CONTENT FOLDER
  Future searchContentFolder(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: value, marketingContentFolderList: []));
    await getMarketingFolderList(context, 1, projectId);
  }

  Future applyMarketingFolderFilterAndSort({
    required BuildContext context,
    String? employeeName,
    String? sortColumn,
    String? sortDirection,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByContentName: "",
          currentSortColumn: "Created Date",
          currentSortDirection: "DESC",
          marketingContentFolderList: [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: employeeName ?? state.searchText,

          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
          marketingContentFolderList: [],
        ),
      );
    }
    await getMarketingFolderList(context, 1, getProject().projectId);
  }

  int updateMarketingFolderFilterCount(ContentFolderState state) {
    final hasSort =
        state.currentSortColumn == "Content Name" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterByContentName.trim().isNotEmpty,
      hasSort,
    ]);
  }

  // GET MARKETING FOLDER LIST
  Future getMarketingFolderList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
        ContentFolderCubit();
        emit(state.copyWith(isLoading: false, marketingContentFolderList: []));
      });
      return;
    }
    var result = await _contentRepository.getMarketingContentFolderList(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      queryParams: {
        "MarketingContentFolderName": state.searchText,
        "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      },
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<ContentFolderModel> newData = List<ContentFolderModel>.from(
          response['data'] ?? [],
        );

        final List<ContentFolderModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.marketingContentFolderList, ...newData];
        emit(
          state.copyWith(
            marketingContentFolderList: updatedList,
            currentPage: pageNumber,
            totalNumberOfRecord: response['totalNumberOfRecord'],
            isLoading: false,
          ),
        );
      },
    );
  }

  // DELETE CONTENT FOLDER
  Future deleteContentFolder({
    required BuildContext context,
    required int marketingContentFolderId,
    required int projectId,
    required String uniqueKey,
    required int pageNumber,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _contentRepository.deleteMarketingContentFolder(
      marketingContentFolderId: marketingContentFolderId,
      projectId: projectId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(context);
        if (index != null) {
          final updatedList = List<ContentFolderModel>.from(
            state.marketingContentFolderList,
          );
          updatedList.removeAt(index);
        } else {
          getMarketingFolderList(context, pageNumber, projectId);
        }
      },
    );
  }

  // ADD CONTENT FOLDER
  Future addContentFolder({
    required BuildContext context,
    required int projectId,
    required String marketingContentFolderName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "MarketingContentFolderId": "0",
      "ProjectId": projectId,
      "MarketingContentFolderName": marketingContentFolderName,
    };

    var addResult = await _contentRepository.addUpdateContentFolder(
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();
        var list = [
          response['data'][0] as ContentFolderModel,
          ...state.marketingContentFolderList,
        ];

        emit(state.copyWith(marketingContentFolderList: list));
        showSuccessMessage(context);
      },
    );
  }

  // UPDATE CONTENT FOLDER
  Future updateContentFolder({
    required int index,
    required BuildContext context,
    required int marketingContentFolderId,
    required String uniqueKey,
    required String marketingContentFolderName,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var body = {
      "MarketingContentFolderId": marketingContentFolderId.toString(),
      "Uniquekey": uniqueKey,
      "ProjectId": getProject().projectId.toString(),
      "MarketingContentFolderName": marketingContentFolderName,
    };

    var result = await _contentRepository.addUpdateContentFolder(body: body);
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        goRouter.pop();

        final updatedDepartment = response['data'][0] as ContentFolderModel;

        if (state.marketingContentFolderList.isNotEmpty &&
            index < state.marketingContentFolderList.length) {
          final updatedList = List<ContentFolderModel>.from(
            state.marketingContentFolderList,
          );
          updatedList[index] = updatedDepartment;
          emit(
            state.copyWith(
              marketingContentFolderList: updatedList,
              isLoading: false,
            ),
          );
        }

        showSuccessMessage(context, subTitle: response["message"]);
      },
    );
  }

  Future exportZip(
    BuildContext context,
    int projectId,
    int approvedBankFolderId,
    String contentName,
    int pageSize,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    final result = await _contentRepository.getMarketingContentFolderForExport(
      pageNumber: 1,
      pageSize: pageSize,
      projectId: projectId,
      queryParams: {
        "MarketingContentFolderId": approvedBankFolderId,
        "ExportType": "ZIP",
      },
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) async {
        final successResult = await exportExcelOrPdfMobile(
          success["data"],
          "$contentName ${DateTime.now()}.zip",
        );
        if (context.mounted && successResult) {
          showSuccessMessage(context, subTitle: 'Successfully Exported as ZIP');
        }
      },
    );
  }
}
