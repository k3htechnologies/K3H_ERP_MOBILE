import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/marketing/content/data/model/content_folder.model.dart';
import 'package:k3h_erp_app/features/marketing/content/data/repository/content_repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'content_folder_state.dart';

class ContentFolderCubit extends Cubit<ContentFolderState> {
  ContentFolderCubit() : super(ContentFolderState.initial());

  final ContentRepository _contentRepository =
      serviceLocator<ContentRepository>();

  // GET MARKETING FOLDER LIST
  Future getMarketingFolderList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }

    var result = await _contentRepository.getMarketingContentFolderList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
      queryParams: {"MarketingContentFolderName": state.searchText},
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<ContentFolderModel> updatedList = List.from(
          state.marketingContentFolderList,
        );
        updatedList = response['data'] as List<ContentFolderModel>;
        emit(
          state.copyWith(
            isLoading: false,
            marketingContentFolderList: updatedList,
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
          getMarketingFolderList(context, pageNumber, pageSize, projectId);
        }
      },
    );
  }

  // SEARCH CONTENT FOLDER
  Future searchContentFolder(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: value, marketingContentFolderList: []));
    await getMarketingFolderList(context, 1, 1000, projectId);
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
}
