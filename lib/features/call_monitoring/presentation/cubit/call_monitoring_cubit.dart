import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/call_monitoring/data/model/call_monitoring.model.dart';
import 'package:k3h_erp_app/features/call_monitoring/data/repository/call_monitoring.repository.dart';
import 'package:k3h_erp_app/features/call_monitoring/presentation/cubit/call_monitoring_state.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

class CallMonitoringCubit extends Cubit<CallMonitoringState> {
  CallMonitoringCubit() : super(CallMonitoringState.inital());

  final CallMonitoringRepository _callMonitoringRepository =
      serviceLocator<CallMonitoringRepository>();

  Future updatePageInfo({required int id, required String pageName}) async {
    emit(state.copyWith(id: id, pageName: pageName));
  }

  void resetState() {
    emit(CallMonitoringState.inital());
  }

  Future<void> searchCallMonitoring(
    BuildContext context,
    int projectId,
    String value,
  ) async {
    emit(state.copyWith(filterByName: value, callMonitoringList: []));

    await getCallMonitoring(
      context: context,
      pageNumber: 1,
      projectId: projectId,
    );
  }

  Future<void> applyCallMonitoringFilter({
    required int id,
    required BuildContext context,
    String? callLogApplicantName,
    String? callLogApplicantMobileNumber,
    String? callLogStatus,
    String? callLogPurpose,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          filterByName: "",
          filterByMobileNumber: "",
          filterByCallStatus: "",
          filterByCallPurpose: "",
          filterByFromDate: null,
          filterByToDate: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          filterByName: callLogApplicantName ?? state.filterByName,
          filterByMobileNumber:
              callLogApplicantMobileNumber ?? state.filterByMobileNumber,
          filterByCallStatus: callLogStatus ?? state.filterByCallStatus,
          filterByCallPurpose: callLogPurpose ?? state.filterByCallPurpose,
          filterByFromDate: fromDate,
          filterByToDate: toDate,
        ),
      );
    }

    await getCallMonitoring(
      context: context,
      pageNumber: 1,
      projectId: getProject().projectId,
    );
  }

  int updateFilterCount(CallMonitoringState state) {
    return getActiveFilterCount([
      state.filterByName.trim().isNotEmpty,
      state.filterByCallStatus.trim().isNotEmpty,
      state.filterByCallPurpose.trim().isNotEmpty,
      state.filterByMobileNumber.trim().isNotEmpty,
      state.filterByFromDate != null,
      state.filterByToDate != null,
    ]);
  }

  Future<void> getCallMonitoring({
    required BuildContext context,
    required int pageNumber,
    required int projectId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> queryParams = {
      "PageName": state.pageName,
      "Name": state.filterByName,
      "MobileNumber": state.filterByMobileNumber,
      "CallStatus": state.filterByCallStatus,
      "CallPurpose": state.filterByCallPurpose,
      "RescheduleDateFromDate": state.filterByFromDate.apiDate,
      "RescheduleDateToDate": state.filterByToDate.apiDate,
    };

    try {
      final result = await _callMonitoringRepository.getCallMonitoring(
        pageSize: 10,
        pageNumber: pageNumber,
        projectId: projectId,
        id: state.id,
        queryParams: queryParams,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(isLoading: false));
          showErrorMessage(context, "Error", failure.message);
        },
        (response) {
          final logs = response['data'] as List<CallMonitoringModel>;

          final List<CallMonitoringModel> updatedList =
              pageNumber == 1 ? logs : [...state.callMonitoringList, ...logs];

          emit(
            state.copyWith(
              callMonitoringList: updatedList,
              totalNumberOfRecord: response['totalNumberOfRecord'] ?? 0,
              isLoading: false,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint("Get Call Monitoring Error => $e");
      debugPrintStack(stackTrace: stackTrace);

      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> updateCallMonitoring(
    BuildContext context, {
    required int index,
    required int projectId,
    required int callMonitoringId,
    required String uniqueKey,
    required String callStatus,
    required String remark,
    required DateTime? rescheduleDate,
    required String callPurpose,
  }) async {
    emit(state.copyWith(isLoading: true));

    final body = {
      "ProjectId": projectId,
      "CallMonitoringId": callMonitoringId,
      "Uniquekey": uniqueKey,
      "CallStatus": callStatus,
      "Remark": remark,
      "RescheduleDate": rescheduleDate?.toIso8601String(),
      "CallPurpose": callPurpose,
    };

    final result = await _callMonitoringRepository.updateCallMonitoring(
      body: body,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        final updatedList = List<CallMonitoringModel>.from(
          state.callMonitoringList,
        );

        updatedList[index] = response['data'][0] as CallMonitoringModel;

        showSuccessMessage(context, subTitle: response["message"]);
        emit(state.copyWith(isLoading: false, callMonitoringList: updatedList));
        goRouter.pop();
      },
    );
  }

  Future<void> deleteCallMonitoring(
    int index,
    int callMonitoringId,
    String uniqueKey,
    int projectId,
    int bookingId,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await _callMonitoringRepository.deleteCallMonitoring(
      callMonitoringId: callMonitoringId,
      uniqueKey: uniqueKey,
      projectId: projectId,
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
      },
      (response) {
        final updatedList = List<CallMonitoringModel>.from(
          state.callMonitoringList,
        );

        updatedList.removeAt(index);

        emit(
          state.copyWith(
            callMonitoringList: updatedList,
            isLoading: false,
            totalNumberOfRecord:
                state.totalNumberOfRecord > 0
                    ? state.totalNumberOfRecord - 1
                    : 0,
          ),
        );

        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future<void> exportCallMonitoringExcelPdf({
  required  BuildContext context,
   required  String exportType,
   required int projectId,
  }) async {
    if (state.totalNumberOfRecord == 0) {
      showErrorMessage(context, 'Error', 'No Data Found');
      return;
    }
    DialogHelper.showProcessingOverlay(context);

    final result = await _callMonitoringRepository.getCallMonitoringForExport(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: {
        "ProjectId": projectId,
        "Id": state.id,
        "PageName": state.pageName,
        "ExportType": exportType,
        "MobileNumber": state.filterByMobileNumber,
        "CallStatus": state.filterByCallStatus,
        "CallPurpose": state.filterByCallPurpose,
        "RescheduleDateFromDate": state.filterByFromDate.apiDate,
        "RescheduleDateToDate": state.filterByToDate.apiDate,
      },
    );

    goRouter.pop();

    result.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );

        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Call Monitoring ${DateTime.now()}.pdf"
              : "Call Monitoring ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
