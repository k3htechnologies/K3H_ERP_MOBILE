import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_file.model.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/repository/approved_bank.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'approved_bank_file_state.dart';

class ApprovedBankFileCubit extends Cubit<ApprovedBankFileState> {
  ApprovedBankFileCubit() : super(ApprovedBankFileState.initial());

  // REPOSITORY
  final ApprovedBankRepository _approvedBankRepository =
      serviceLocator<ApprovedBankRepository>();

  // RESET STATE
  void resetState() {
    emit(ApprovedBankFileState.initial());
  }

  // GET APPROVED BANK FILE LIST
  Future getApprovedBankFileList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int projectId,
    int approvedBankFolderId,
  ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ApprovedBankFolderId": approvedBankFolderId,
      "ApprovedBankFileName": state.searchTextFile,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _approvedBankRepository.getApprovedBankFileList(
      pageSize: pageSize,
      pageNumber: pageNumber,
      projectId: projectId,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        List<ApprovedBankFileModel> updatedList = List.from(
          state.approvedBankFileList,
        );
        updatedList.addAll(response['data'] as List<ApprovedBankFileModel>);
        emit(
          state.copyWith(
            isLoading: false,
            approvedBankFileList: updatedList,
            totalNumberOfRecord:
                response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                    ? state.totalNumberOfRecord - 1
                    : response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // ADD APPROVED BANK FILE
  Future<bool> addApprovedBankFile({
    required BuildContext context,
    required String projectId,
    required String approvedBankFolderId,
    required String approvedBankFileName,
    required MultiFilePickerModel documentFile,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "ApprovedBankFileId": "0",
      "ProjectId": projectId,
      "ApprovedBankFolderId": approvedBankFolderId,
      "ApprovedBankFileName": approvedBankFileName,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < documentFile.fileBytesList.length; i++) {
      if (documentFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "ApprovedBankFileURL",
        "value": documentFile.fileBytesList[i],
        "fileName": documentFile.fileNameList[i],
      });
    }

    var addResult = await _approvedBankRepository.addUpdateApprovedBankFile(
      fileList: fileList,
      body: requestBody,
    );
    goRouter.pop();
    return addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return false;
      },
      (response) {
        goRouter.pop();
        var list = [
          response['data'][0] as ApprovedBankFileModel,
          ...state.approvedBankFileList,
        ];

        emit(
          state.copyWith(
            approvedBankFileList: list,
            totalNumberOfRecord:
                state.totalNumberOfRecord == -1
                    ? 1
                    : state.totalNumberOfRecord + 1,
          ),
        );
        showSuccessMessage(context);

        // Return true to indicate file was added successfully
        // This will be used by the folder screen to refresh the list
        return true;
      },
    );
  }

  // UPDATE APPROVED BANK FILE
  Future updateApprovedBankFile({
    required BuildContext context,
    required String approvedBankFileId,
    required String uniqueKey,
    required String projectId,
    required String approvedBankFolderId,
    required String approvedBankFileName,
    required MultiFilePickerModel documentFile,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      "ApprovedBankFileId": approvedBankFileId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
      "ApprovedBankFolderId": approvedBankFolderId,
      "ApprovedBankFileName": approvedBankFileName,
      "RemoveApprovedBankFileURL": documentFile.deletedFileList,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < documentFile.fileBytesList.length; i++) {
      if (documentFile.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "ApprovedBankFileURL",
        "value": documentFile.fileBytesList[i],
        "fileName": documentFile.fileNameList[i],
      });
    }

    var addResult = await _approvedBankRepository.addUpdateApprovedBankFile(
      fileList: fileList,
      body: requestBody,
    );
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final updatedList = List<ApprovedBankFileModel>.from(
          state.approvedBankFileList,
        );
        updatedList[index] = (response['data'][0] as ApprovedBankFileModel);
        goRouter.pop();

        emit(state.copyWith(approvedBankFileList: updatedList));
        showSuccessMessage(context);
      },
    );
  }

  // SEARCH FILE
  Future searchFile(
    BuildContext context,
    String value,
    int projectId,
    int approvedBankFolderId,
  ) async {
    emit(state.copyWith(searchTextFile: value, approvedBankFileList: []));
    await getApprovedBankFileList(
      context,
      1,
      1000,
      projectId,
      approvedBankFolderId,
    );
  }

  // SORT FILE
  Future sortFile(
    BuildContext context,
    String value,
    String direction,
    int projectId,
    int approvedBankFolderId,
  ) async {
    emit(
      state.copyWith(
        currentSortColumn: value,
        currentSortDirection: direction,
        approvedBankFileList: [],
      ),
    );
    await getApprovedBankFileList(
      context,
      1,
      1000,
      projectId,
      approvedBankFolderId,
    );
  }

  // DELETE APPROVED BANK FILE
  Future<bool> deleteApprovedBankFile({
    required BuildContext context,
    required int approvedBankFileId,
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
    required int pageNumber,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _approvedBankRepository.deleteApprovedBankFile(
      approvedBankFileId: approvedBankFileId,
      approvedBankFolderId: approvedBankFolderId,
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
          final updatedList = List<ApprovedBankFileModel>.from(
            state.approvedBankFileList,
          );
          updatedList.removeAt(index);

          emit(
            state.copyWith(
              approvedBankFileList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getApprovedBankFileList(
            context,
            pageNumber,
            pageSize,
            projectId,
            approvedBankFolderId,
          );
        }
        return true;
      },
    );
  }
}
