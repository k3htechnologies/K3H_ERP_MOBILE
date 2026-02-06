import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_document.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/repository/litigation.repository.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class LitigationCubit extends Cubit<LitigationState> {
  LitigationCubit() : super(LitigationState.initial());
  final LitigationRepository _litigationRepository =
      serviceLocator<LitigationRepository>();

  /// Pull litigation list (with pagination)
  Future<void> getLitigationList({
    required BuildContext context,
    required int pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));
    var queryParams = {"Title": state.searchText};
    final result = await _litigationRepository.pullLitigation(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
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

        showSuccessMessage(context, subTitle: 'Litigation Added Successfully');
      },
    );
  }

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

  /// Change tab index
  void changeTab(int index) {
    emit(state.copyWith(currentTabIndex: index, isLoading: true));
  }

  // EXPORT LITIGATION
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _litigationRepository.getLitigationForExport(
      pageNumber: 1,
      pageSize: state.litigationTotalRecords,
      queryParams: {
        "ExportType": exportType,
        "Title": state.searchText.trim(),
        "ProjectId": getProject().projectId,
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
          exportType.toLowerCase() == "pdf"
              ? "litigation_${DateTime.now()}.pdf"
              : "litigation_${DateTime.now()}.xlsx",
        );
      },
    );
  }

  Future<void> getLitigationHearingList({
    required BuildContext context,
    required int pageNumber,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _litigationRepository.pullLitigationHearing(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
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
            litigationCurrentPage: pageNumber,
            litigationHearingList: updatedList,
            litigationTotalRecords: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }

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
        goRouter.pop();

        showSuccessMessage(
          context,
          subTitle: 'Litigation Hearing Added Successfully',
        );
      },
    );
  }

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
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _litigationRepository.deleteLitigationHearing(
      litigationId: litigationId,
      uniqueKey: litigationHearingModel.uniquekey,
      projectId: getProject().projectId,
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
          subTitle: "Litigation Deleted Successfully",
        );
      },
    );
  }

  Future<void> getLitigationDocumentList({
    required BuildContext context,
    required int pageNumber,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _litigationRepository.pullLitigationDocument(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
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

  void clearHearingData() {
    emit(
      state.copyWith(
        litigationHearingList: [],
        hearingCurrentPage: 1, // Reset pagination too
      ),
    );
  }

  void clearDocumentData() {
    emit(
      state.copyWith(
        litigationDocumentList: [],
        documentCurrentPage: 1, // Reset pagination too
      ),
    );
  }

  void resetLitigationData() {
    clearHearingData();
    clearDocumentData();
  }

  Future<void> getLitigationClosureList({
    required BuildContext context,
    required int pageNumber,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _litigationRepository.pullLitigationClosure(
      pageNumber: pageNumber,
      pageSize: 10,
      projectId: getProject().projectId,
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

  Future addLitigationClosure({
    required BuildContext context,
    required Map<String, String> body,
    required MultiFilePickerModel litigationClosureDocuments,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < litigationClosureDocuments.fileNameList.length; i++) {
      if (litigationClosureDocuments.fileNameList[i].contains("http")) {
        continue;
      }
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

        showSuccessMessage(
          context,
          subTitle: 'Litigation Closure Added Successfully',
        );
      },
    );
  }

  Future updateLitigationClosure({
    required BuildContext context,
    required int index,
    required Map<String, String> body,
    required MultiFilePickerModel litigationClosureDocuments,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    List<Map<String, dynamic>> fileList = [];
    for (int i = 0; i < litigationClosureDocuments.fileNameList.length; i++) {
      if (litigationClosureDocuments.fileNameList[i].contains("http")) {
        continue;
      }
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

  Future updateLitigationReopen({
    required BuildContext context,
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
        final updatedList = List<LitigationModel>.from(state.litigationList);

        emit(state.copyWith(litigationList: updatedList, isLoading: false));
        showSuccessMessage(context, subTitle: "Litigation Reopen Successfully");
      },
    );
  }
}
