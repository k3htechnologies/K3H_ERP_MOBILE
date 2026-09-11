import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_file.model.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_folder.model.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/repository/approved_bank.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'approved_bank_folder_state.dart';

class ApprovedBankFolderCubit extends Cubit<ApprovedBankFolderState> {
  ApprovedBankFolderCubit() : super(ApprovedBankFolderState.initial());

  final ApprovedBankRepository _approvedBankRepository =
      serviceLocator<ApprovedBankRepository>();

  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // GET APPROVED BANK FOLDER LIST
  Future getApprovedBankFolderList(
    BuildContext context,
    int pageNumber,
    int projectId,
  ) async {
    emit(state.copyWith(isLoading: true, approvedBankFileList: []));
    if (projectId == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorMessage(context, "Error", "Please select a project");
      });
      emit(state.copyWith(isLoading: false));
      return;
    }
    Map<String, dynamic> queryParams = {
      "BankName": state.searchTextFolder,
      "SortBy":
          "${state.currentSortColumnBankFolder} ${state.currentSortDirectionBankFolder}",
    };
    var result = await _approvedBankRepository.getApprovedBankFolderList(
      pageSize: 10,
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
        final newData = response['data'] as List<ApprovedBankFolderModel>;
        final List<ApprovedBankFolderModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.approvedBankFolderList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            approvedBankFolderList: updatedList,
            totalNumberOfRecordBankFolder: response["totalNumberOfRecord"],
            currentPageBankFolder: pageNumber,
          ),
        );
      },
    );
  }

  // GET BANK LIST
  Future getBankList(
    BuildContext context,
    int pageNumber, {
    bool clearSearch = false,
  }) async {
    if (clearSearch) {
      emit(state.copyWith(searchTextBank: "", bankList: []));
    }
    emit(state.copyWith(isLoading: true));

    var result = await _employeeMasterRepository.getBankList(
      pageNumber: pageNumber,
      pageSize: 20,
      query: {'BankName': state.searchTextBank},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<BankListMasterModel> newData =
            response['data'] as List<BankListMasterModel>;

        final List<BankListMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.bankList, ...newData];

        emit(
          state.copyWith(
            bankList: updatedList,
            isLoading: false,
            totalNumberOfRecordBank: response["totalNumberOfRecord"],
            currentPageBank: pageNumber,
          ),
        );
      },
    );
  }

  // SEARCH FOLDER
  Future searchFolder(BuildContext context, String value, int projectId) async {
    emit(state.copyWith(searchTextFolder: value, approvedBankFolderList: []));
    await getApprovedBankFolderList(context, 1, projectId);
  }

  Future searchBank(BuildContext context, String value, int projectId) async {
    emit(
      state.copyWith(searchTextBank: value, bankList: [], currentPageBank: 1),
    );
    await getBankList(context, 1);
  }

  // ADD APPROVED BANK FOLDER
  Future addApproveBankFolder({
    required BuildContext context,
    required int projectId,
    required String bankListMasterId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "ApprovedBankFolderId": 0,
      "ProjectId": projectId,
      "BankListMasterId": bankListMasterId.toString(),
    };
    var addResult = await _approvedBankRepository.addUpdateApprovedBankFolder(
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
        showSuccessMessage(context);
        getApprovedBankFolderList(context, 1, projectId);
      },
    );
  }

  // DELETE APPROVED BANK FOLDER
  Future deleteApprovedBankFolder({
    required BuildContext context,
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _approvedBankRepository.deleteApprovedBankFolder(
      approvedBankFolderId: approvedBankFolderId,
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
        showSuccessMessage(context, subTitle: response['message']);
        final updatedList = List<ApprovedBankFolderModel>.from(
          state.approvedBankFolderList,
        );
        updatedList.removeAt(index);

        emit(
          state.copyWith(
            approvedBankFolderList: updatedList,
            totalNumberOfRecordBankFolder:
                state.totalNumberOfRecordBankFolder == 0
                    ? 0
                    : state.totalNumberOfRecordBankFolder - 1,
          ),
        );
      },
    );
  }

  // ---------------------------

  // GET APPROVED BANK FILE LIST
  Future getApprovedBankFileList(
    BuildContext context,
    int pageNumber,
    int projectId,
    int approvedBankFolderId, {
    bool clearSearch = false,
  }) async {
    if (clearSearch) {
      emit(
        state.copyWith(
          searchTextFile: "",
          approvedBankFileList: [],
          currentSortColumnBankFile: "",
          currentSortDirectionBankFile: "",
        ),
      );
    }
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "ApprovedBankFolderId": approvedBankFolderId,
      "ApprovedBankFileName": state.searchTextFile,
      "SortBy":
          "${state.currentSortColumnBankFile} ${state.currentSortDirectionBankFile}",
    };
    var result = await _approvedBankRepository.getApprovedBankFileList(
      pageSize: 10,
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
        final newData = response['data'] as List<ApprovedBankFileModel>;
        final List<ApprovedBankFileModel> updatedList =
            pageNumber == 1
                ? newData
                : [...state.approvedBankFileList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            approvedBankFileList: updatedList,
            totalNumberOfRecordBankFile: response['totalNumberOfRecord'],
            currentPageBankFile: pageNumber,
          ),
        );
      },
    );
  }

  // ADD APPROVED BANK FILE
  Future<void> addApprovedBankFile({
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
            totalNumberOfRecordBankFile:
                state.totalNumberOfRecordBankFile == -1
                    ? 1
                    : state.totalNumberOfRecordBankFile + 1,
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
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
    await getApprovedBankFileList(context, 1, projectId, approvedBankFolderId);
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
        currentSortColumnBankFile: value,
        currentSortDirectionBankFile: direction,
        approvedBankFileList: [],
      ),
    );
    await getApprovedBankFileList(context, 1, projectId, approvedBankFolderId);
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
              totalNumberOfRecordBankFile:
                  state.totalNumberOfRecordBankFile > 0
                      ? state.totalNumberOfRecordBankFile - 1
                      : 0,
            ),
          );
        } else {
          getApprovedBankFileList(
            context,
            pageNumber,
            projectId,
            approvedBankFolderId,
          );
        }
        return true;
      },
    );
  }

  Future exportZip(
    BuildContext context,
    int projectId,
    int approvedBankFolderId,
  ) async {
    if (state.totalNumberOfRecordBank == 0) {
      showErrorMessage(context, "Error", "No Data Found.");
      return;
    }
    DialogHelper.showProcessingOverlay(context);
    final result = await _approvedBankRepository.getApprovedBankFolderForExport(
      pageNumber: 1,
      pageSize: 1,
      projectId: projectId,
      queryParams: {
        "ExportType": "zip",
        "BankName": state.searchTextFolder,
        "ApprovedBankFolderId": approvedBankFolderId,
      },
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        exportExcelOrPdfMobile(
          success["data"],
          "approved_bank_${DateTime.now()}.zip",
        ).then((_) {
          if (context.mounted) {
            showSuccessMessage(
              context,
              subTitle: 'Successfully Exported as ZIP',
            );
          }
        });
      },
    );
  }

  Future applyFilterAndSortApprovedBankFolder({
    required BuildContext context,
    required String column,
    required String direction,
    required String bankName,
    required int projectId,
  }) async {
    emit(
      state.copyWith(
        searchTextFolder: bankName,
        currentSortColumnBankFolder: column,
        currentSortDirectionBankFolder: direction,
        approvedBankFolderList: [],
      ),
    );
    await getApprovedBankFolderList(context, 1, projectId);
  }

  int updateFilterCountFolder(ApprovedBankFolderState state) {
    final hasSort =
        state.currentSortColumnBankFolder == "BankName" &&
        (state.currentSortDirectionBankFolder == "ASC" ||
            state.currentSortDirectionBankFolder == "DESC");
    return getActiveFilterCount([
      hasSort,
      state.searchTextFolder.trim().isNotEmpty,
    ]);
  }

  Future applyFilterAndSortApprovedBankFile({
    required BuildContext context,
    required String column,
    required String direction,
    required String title,
    required int projectId,
    required int approvedBankFolderId,
  }) async {
    emit(
      state.copyWith(
        searchTextFile: title,
        currentSortColumnBankFile: column,
        currentSortDirectionBankFile: direction,
        approvedBankFileList: [],
      ),
    );
    await getApprovedBankFileList(context, 1, projectId, approvedBankFolderId);
  }

  int updateFilterCountFile(ApprovedBankFolderState state) {
    final hasSort =
        state.currentSortColumnBankFile == "ApprovedBankFileName" &&
        (state.currentSortDirectionBankFile == "ASC" ||
            state.currentSortDirectionBankFile == "DESC");
    return getActiveFilterCount([
      hasSort,
      state.searchTextFile.trim().isNotEmpty,
    ]);
  }
}
