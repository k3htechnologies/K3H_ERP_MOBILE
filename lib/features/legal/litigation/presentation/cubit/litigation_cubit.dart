import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_closure.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_document.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/repository/litigation.repository.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

class LitigationCubit extends Cubit<LitigationState> {
  LitigationCubit() : super(LitigationState.initial());
  final LitigationRepository _litigationRepository =
      serviceLocator<LitigationRepository>();

  // FILTER COMPANY
  Future applyLitigationFilterAndSort({
    required BuildContext context,
    String? title,
    String? projectName,
    String? caseNumber,
    String? courtName,
    String? sortColumn,
    String? sortDirection,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          searchText: "",
          filterByProjectName: "",
          filterCaseNumber: "",
          filterByCourtName: "",
          currentSortColumn: "",
          currentSortDirection: "",
        ),
      );
    } else {
      emit(
        state.copyWith(
          searchText: title ?? state.searchText,
          filterByProjectName: projectName ?? state.filterByProjectName,
          filterCaseNumber: caseNumber ?? state.filterCaseNumber,
          filterByCourtName: courtName ?? state.filterByCourtName,
          currentSortColumn: sortColumn ?? state.currentSortColumn,
          currentSortDirection: sortDirection ?? state.currentSortDirection,
        ),
      );
    }

    await getLitigationList(context: context, pageNumber: 1);
  }

  // SEARCH BASED ON LITIGATION TITLE
  void searchLitigation(String value, BuildContext context) {
    emit(
      state.copyWith(
        litigationList: [],
        isLoading: true,
        searchText: value,
        litigationCurrentPage: 1,
      ),
    );
    getLitigationList(context: context, pageNumber: 1);
  }

  /// CHANGE TAB INDEX
  void changeTab(int index) {
    emit(state.copyWith(currentTabIndex: index, isLoading: true));
  }

  /// PULL LITIGATION LIST
  Future<void> getLitigationList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));

    var queryParams = {
      "Title": state.searchText,
      "CaseNumber": state.filterCaseNumber,
      "CourtName": state.filterByCourtName,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
      "ProjectName": state.filterByProjectName,
    };
    final result = await _litigationRepository.pullLitigation(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        final List<LitigationModel> newData = List<LitigationModel>.from(
          response['data'] ?? [],
        );

        final List<LitigationModel> updatedList =
            pageNumber == 1 ? newData : [...state.litigationList, ...newData];
        emit(
          state.copyWith(
            isLoading: false,
            litigationCurrentPage: pageNumber,
            litigationTotalRecords: response['totalNumberOfRecord'],
            litigationList: updatedList,
          ),
        );
      },
    );
  }

  // DELETE LITIGATION
  Future deleteLitigation(
    int index,
    LitigationModel litigationModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _litigationRepository.deleteLitigation(
      litigationId: litigationModel.litigationId,
      uniqueKey: litigationModel.uniquekey,
      projectId: litigationModel.projectId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<LitigationModel>.from(state.litigationList);
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            litigationList: updatedList,
            isLoading: false,
            litigationTotalRecords:
                state.litigationTotalRecords > 0
                    ? state.litigationTotalRecords - 1
                    : 0,
          ),
        );
        showSuccessMessage(
          context,
          subTitle: "Litigation Deleted Successfully",
        );
      },
    );
  }

  // ADD LITIGATION
  Future addLitigation({
    required BuildContext context,
    required Map<String, dynamic> body,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _litigationRepository.addUpdateLitigation(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();
        goRouter.pop();
        showSuccessMessage(context, subTitle: 'Litigation Added Successfully');
      },
    );
  }

  // UPDATE LITIGATION
  Future updateLitigation({
    required BuildContext context,
    required int index,
    required Map<String, dynamic> body,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _litigationRepository.addUpdateLitigation(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        final updatedLitigation = LitigationModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.litigationList.isNotEmpty &&
            index < state.litigationList.length) {
          final updatedList = List<LitigationModel>.from(state.litigationList);

          updatedList[index] = updatedLitigation;

          emit(state.copyWith(isLoading: false, litigationList: updatedList));
        }

        showSuccessMessage(
          context,
          subTitle: 'Litigation Updated Successfully',
        );
      },
    );
  }

  // PULL LITIGATION HEARING
  Future<void> getLitigationHearingList({
    required BuildContext context,
    required int pageNumber,
    required int litigationId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _litigationRepository.pullLitigationHearing(
      pageNumber: pageNumber,
      pageSize: 5,
      projectId: projectId,
      litigationId: litigationId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<LitigationHearingModel> newData =
            List<LitigationHearingModel>.from(response['data'] ?? []);

        final updatedList =
            pageNumber == 1
                ? newData
                : [...state.litigationHearingList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            litigationHearingList: updatedList,
            hearingTotalRecords: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  // ADD LITIGATION HEARING
  Future addLitigationHearing({
    required BuildContext context,
    required Map<String, String> body,
    required MultiFilePickerModel hearingDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < hearingDocument.fileNameList.length; i++) {
      if (hearingDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "HearingAttachementURL",
        "value": hearingDocument.fileBytesList[i],
        "fileName": hearingDocument.fileNameList[i],
      });
    }
    final result = await _litigationRepository.addUpdateLitigationHearing(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        getLitigationList(context: context, pageNumber: 1);
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: 'Litigation Hearing Added Successfully',
        );
      },
    );
  }

  // UPDATE LITIGATION HEARING
  Future updateLitigationHearing({
    required BuildContext context,
    required int index,
    required Map<String, String> body,
    required MultiFilePickerModel hearingDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < hearingDocument.fileNameList.length; i++) {
      if (hearingDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "HearingAttachementURL",
        "value": hearingDocument.fileBytesList[i],
        "fileName": hearingDocument.fileNameList[i],
      });
    }
    final result = await _litigationRepository.addUpdateLitigationHearing(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        final updatedLitigationHearing = LitigationHearingModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.litigationList.isNotEmpty &&
            index < state.litigationList.length) {
          final updatedList = List<LitigationHearingModel>.from(
            state.litigationHearingList,
          );

          updatedList[index] = updatedLitigationHearing;

          emit(
            state.copyWith(
              isLoading: false,
              litigationHearingList: updatedList,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: 'Litigation Hearing Updated Successfully',
        );
      },
    );
  }

  // DELETE LITIGATION HEARING
  Future deleteLitigationHearing(
    int index,
    LitigationHearingModel litigationHearingModel,
    int litigationId,
    int projectId,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _litigationRepository.deleteLitigationHearing(
      litigationId: litigationId,
      uniqueKey: litigationHearingModel.uniquekey,
      projectId: projectId,
      litigationHearingId: litigationHearingModel.litigationHearingId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<LitigationHearingModel>.from(
          state.litigationHearingList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            litigationHearingList: updatedList,
            isLoading: false,
            hearingTotalRecords:
                state.hearingTotalRecords > 0
                    ? state.hearingTotalRecords - 1
                    : 0,
          ),
        );
        showSuccessMessage(
          context,
          subTitle: "Litigation hearing deleted successfully",
        );
      },
    );
  }

  // PULL LITIGATION DOCUMENT
  Future getLitigationDocumentList({
    required BuildContext context,
    required int pageNumber,
    required int litigationId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));
    final result = await _litigationRepository.pullLitigationDocument(
      pageNumber: pageNumber,
      pageSize: 15,
      projectId: projectId,
      litigationId: litigationId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<LitigationDocumentModel> newData =
            List<LitigationDocumentModel>.from(response['data'] ?? []);

        final updatedList =
            pageNumber == 1
                ? newData
                : [...state.litigationDocumentList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            documentCurrentPage: pageNumber,
            litigationDocumentList: updatedList,
            documentTotalRecords: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  // ADD LITIGATION DOCUMENT
  Future addLitigationDocument({
    required BuildContext context,
    required Map<String, String> body,
    required MultiFilePickerModel litigationDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < litigationDocument.fileNameList.length; i++) {
      if (litigationDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "DocumentURL",
        "value": litigationDocument.fileBytesList[i],
        "fileName": litigationDocument.fileNameList[i],
      });
    }
    final result = await _litigationRepository.addUpdateLitigationDocument(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        showSuccessMessage(
          context,
          subTitle: 'Litigation Document Added Successfully',
        );
      },
    );
  }

  // UPDATE LITIGATION DOCUMENT
  Future updateLitigationDocument({
    required BuildContext context,
    required int index,
    required Map<String, String> body,
    required MultiFilePickerModel litigationDocument,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < litigationDocument.fileNameList.length; i++) {
      if (litigationDocument.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "DocumentURL",
        "value": litigationDocument.fileBytesList[i],
        "fileName": litigationDocument.fileNameList[i],
      });
    }
    final result = await _litigationRepository.addUpdateLitigationDocument(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        final updatedLitigationDocument = LitigationDocumentModel.fromJson(
          response['data'][0] as Map<String, dynamic>,
        );

        if (state.litigationDocumentList.isNotEmpty &&
            index < state.litigationDocumentList.length) {
          final updatedList = List<LitigationDocumentModel>.from(
            state.litigationDocumentList,
          );

          updatedList[index] = updatedLitigationDocument;

          emit(
            state.copyWith(
              isLoading: false,
              litigationDocumentList: updatedList,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: 'Litigation Document Updated Successfully',
        );
      },
    );
  }

  // DELETE LITIGATION DOCUMENT
  Future deleteLitigationDocument(
    int index,
    LitigationDocumentModel litigationDocModel,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _litigationRepository.deleteLitigationDocument(
      litigationId: litigationDocModel.litigationId,
      uniqueKey: litigationDocModel.uniquekey,
      projectId: litigationDocModel.projectId,
      litigationDocumentId: litigationDocModel.litigationDocumentId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedList = List<LitigationDocumentModel>.from(
          state.litigationDocumentList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            litigationDocumentList: updatedList,
            isLoading: false,
            documentTotalRecords:
                state.documentTotalRecords > 0
                    ? state.documentTotalRecords - 1
                    : 0,
          ),
        );
        showSuccessMessage(
          context,
          subTitle: "Litigation Document Deleted Successfully",
        );
      },
    );
  }

  // RESET LITIGATION DATA
  void resetLitigationData() {
    clearHearingData();
    clearDocumentData();
  }

  void clearHearingData() {
    emit(state.copyWith(litigationHearingList: [], hearingCurrentPage: 1));
  }

  void clearDocumentData() {
    emit(state.copyWith(litigationDocumentList: [], documentCurrentPage: 1));
  }

  // GET LITIGATION CLOSURE
  Future<void> getLitigationClosureList({
    required BuildContext context,
    required int pageNumber,
    required int litigationId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _litigationRepository.pullLitigationClosure(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: projectId,
      litigationId: litigationId,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<LitigationModel> newData = List<LitigationModel>.from(
          response['data'] ?? [],
        );

        final updatedList =
            pageNumber == 1 ? newData : [...state.litigationList, ...newData];

        emit(
          state.copyWith(
            isLoading: false,
            // currentPage: pageNumber,
            litigationList: updatedList,
            // totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

  // ADD LITIGATION CLOSURE
  Future<void> addLitigationClosure({
    required BuildContext context,
    required int litigationIndex,
    required Map<String, String> body,
    required MultiFilePickerModel litigationClosureDocuments,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < litigationClosureDocuments.fileNameList.length; i++) {
      if (litigationClosureDocuments.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "ClosureAttachementURL",
        "value": litigationClosureDocuments.fileBytesList[i],
        "fileName": litigationClosureDocuments.fileNameList[i],
      });
    }

    final result = await _litigationRepository.addUpdateLitigationClosure(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        final newClosure = LitigationClosureModel.fromJson(response['data'][0]);

        final updatedLitigationList = List<LitigationModel>.from(
          state.litigationList,
        );

        final selectedLitigation = updatedLitigationList[litigationIndex];

        final updatedClosureList = [
          newClosure,
          ...selectedLitigation.litigationClosureData,
        ];

        updatedLitigationList[litigationIndex] = selectedLitigation.copyWith(
          status: "Closed",
          closureDate: newClosure.closureDate,
          litigationClosureData: updatedClosureList,
        );

        emit(state.copyWith(litigationList: updatedLitigationList));

        showSuccessMessage(
          context,
          subTitle: 'Litigation Closure added successfully',
        );
        getLitigationList(context: context, pageNumber: 1);
      },
    );
  }

  // UPDATE LITIGATION CLOSURE
  Future<void> updateLitigationClosure({
    required BuildContext context,
    required int litigationIndex,
    required int closureIndex,
    required Map<String, String> body,
    required MultiFilePickerModel litigationClosureDocuments,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < litigationClosureDocuments.fileNameList.length; i++) {
      if (litigationClosureDocuments.fileNameList[i].contains("http")) continue;

      fileList.add({
        "key": "ClosureAttachementURL",
        "value": litigationClosureDocuments.fileBytesList[i],
        "fileName": litigationClosureDocuments.fileNameList[i],
      });
    }

    final result = await _litigationRepository.addUpdateLitigationClosure(
      body: body,
      fileList: fileList,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        goRouter.pop();

        final updatedClosure = LitigationClosureModel.fromJson(
          response['data'][0],
        );

        /// Update inside litigation list
        final updatedLitigationList = List<LitigationModel>.from(
          state.litigationList,
        );

        final selectedLitigation = updatedLitigationList[litigationIndex];

        final closureData = List<LitigationClosureModel>.from(
          selectedLitigation.litigationClosureData,
        );

        closureData[closureIndex] = updatedClosure;

        updatedLitigationList[litigationIndex] = selectedLitigation.copyWith(
          litigationClosureData: closureData,
        );

        emit(state.copyWith(litigationList: updatedLitigationList));

        showSuccessMessage(
          context,
          subTitle: 'Litigation Closure updated successfully',
        );
        getLitigationList(context: context, pageNumber: 1);
      },
    );
  }

  // UPDATE LITIGATION STATUS TO REOPEN
  Future<void> updateLitigationReopen({
    required BuildContext context,
    required int litigationIndex,
    required int litigationId,
    required String uniqueKey,
    required int projectId,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    var body = {
      "LitigationId": litigationId,
      "Uniquekey": uniqueKey,
      "ProjectId": projectId,
    };

    var result = await _litigationRepository.updateLitigationReopen(body: body);

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (success) {
        final updatedLitigation = LitigationModel.fromJson(success['data'][0]);

        final updatedList = List<LitigationModel>.from(state.litigationList);

        updatedList[litigationIndex] = updatedLitigation;

        emit(state.copyWith(litigationList: updatedList));

        showSuccessMessage(
          context,
          subTitle: "Litigation Reopened Successfully",
        );
      },
    );
  }

  // EXPORT LITIGATION
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _litigationRepository.getLitigationForExport(
      pageNumber: 1,
      pageSize: state.litigationTotalRecords,
      queryParams: {"ExportType": exportType, "Title": state.searchText.trim()},
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (success) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          success["data"],
          exportType.toLowerCase() == "pdf"
              ? "litigation_${DateTime.now()}.pdf"
              : "litigation_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  int updateFilterCount(LitigationState state) {
    final hasSort =
        state.currentSortColumn == "Title" &&
        (state.currentSortDirection == "ASC" ||
            state.currentSortDirection == "DESC");
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterCaseNumber.trim().isNotEmpty,
      state.filterByCourtName.trim().isNotEmpty,
      state.filterByProjectName.trim().isNotEmpty,
      hasSort,
    ]);
  }
}
