import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/litigation/data/model/litigation_document.model.dart';
import 'package:k3h_erp_app/features/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/features/litigation/data/repository/litigation.repository.dart';
import 'package:k3h_erp_app/features/litigation/presentation/cubit/litigation_state.dart';
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
    Map<String, dynamic>? queryParams,
  }) async {
    emit(state.copyWith(isLoading: true));

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
    required int litigationId,
    required Map<String, dynamic> body,
  }) async {
    DialogHelper.showProcessingOverlay(context);

    // final body = {
    //   "LitigationId": litigationId,
    //   "Uniquekey": uniqueKey,
    //   "ProjectId": projectId,
    //   "Title": title,
    //   "CaseNumber": caseNumber,
    //   "CaseType": caseType,
    //   "DateOfFilling": dateOfFilling,
    //   "CourtName": courtName,
    //   "CourtLocation": courtLocation,
    //   "CourtType": courtType,
    //   "Plantiff": plantiff,
    //   "Defendant": defendant,
    //   "AssignedRepresentative": assignedRepresentative,
    //   "OpposingRepresentative": opposingRepresentative,
    //   "Remark": remark,
    //   "CaseBrief": caseBrief,
    // };

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
    emit(state.copyWith(currentTabIndex: index));
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

  /*
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
            currentPage: pageNumber,
            litigationList: updatedList,
            totalNumberOfRecord: response['totalNumberOfRecord'],
          ),
        );
      },
    );
  }
*/
}
