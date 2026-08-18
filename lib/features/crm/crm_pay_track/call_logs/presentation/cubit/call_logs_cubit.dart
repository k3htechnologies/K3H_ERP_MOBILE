import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/data/model/pay_track_call_log.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/call_logs/data/repository/call_logs.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';

part 'call_logs_state.dart';

class CallLogsCubit extends Cubit<CallLogsState> {
  CallLogsCubit() : super(CallLogsState.inital());

  final CallLogsRepository _callLogsRepository =
      serviceLocator<CallLogsRepository>();

  Future searchCallLogs(
    BuildContext context,
    int projectId,
    int bookingId,
    String value,
  ) async {
    emit(
      state.copyWith(
        filterByCallLogApplicantName: value,
        payTrackCallLogList: [],
      ),
    );
    await getCallLog(context, 1, projectId, bookingId);
  }

  Future applyCallLogsFilter({
    required int bookingId,
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
          filterByCallLogApplicantName: "",
          filterCallLogApplicantMobileNumber: "",
          filterCallStatus: "",
          filterCallPurpose: "",
          filterCallLogFromDate: null,
          filterCallLogToDate: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          filterByCallLogApplicantName:
              callLogApplicantName ?? state.filterByCallLogApplicantName,
          filterCallLogApplicantMobileNumber:
              callLogApplicantMobileNumber ??
              state.filterCallLogApplicantMobileNumber,
          filterCallStatus: callLogStatus ?? state.filterCallStatus,
          filterCallPurpose: callLogPurpose ?? state.filterCallPurpose,
          filterCallLogFromDate: fromDate,
          filterCallLogToDate: toDate,
        ),
      );
    }
    await getCallLog(context, 1, getProject().projectId, bookingId);
  }

  int updateFilterCount(CallLogsState state) {
    return getActiveFilterCount([
      state.filterByCallLogApplicantName.trim().isNotEmpty,
      state.filterCallStatus.trim().isNotEmpty,
      state.filterCallPurpose.trim().isNotEmpty,
      state.filterCallLogApplicantMobileNumber.trim().isNotEmpty,
      state.filterCallLogFromDate != null,
      state.filterCallLogToDate != null,
    ]);
  }

  Future<void> getCallLog(
    BuildContext context,
    int pageNumber,
    int projectId,
    int bookingId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final Map<String, dynamic> queryParams = {
      "BookingId": bookingId,
      "IsCheckPermission": false,
      "ApplicantName": state.filterByCallLogApplicantName,
      "ApplicantMobileNumber": state.filterCallLogApplicantMobileNumber,
      "CallStatus": state.filterCallStatus,
      "CallPurpose": state.filterCallPurpose,
      "RescheduleDateFromDate": state.filterCallLogFromDate.apiDate,
      "RescheduleDateToDate": state.filterCallLogToDate.apiDate,
    };

    try {
      final result = await _callLogsRepository.getCallLog(
        pageSize: 10,
        pageNumber: pageNumber,
        projectId: projectId,
        queryParams: queryParams,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(isLoading: false));

          showErrorMessage(context, "Error", failure.message);
        },
        (response) {
          final logs = response['data'] as List<PayTrackCallLogModel>;
          final List<PayTrackCallLogModel> updatedList =
              pageNumber == 1 ? logs : [...state.payTrackCallLogList, ...logs];
          emit(
            state.copyWith(
              payTrackCallLogList: updatedList,
              callLogsTotalNumberOfRecord: response['totalNumberOfRecord'] ?? 0,
              isLoading: false,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint("Get PayTrack Call Log Error => $e");
      debugPrintStack(stackTrace: stackTrace);

      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> updateCallLogs(
    BuildContext context, {
    required int projectId,
    required int bookingId,
    required int payTrackCallLogId,
    required String uniquekey,
    required String callStatus,
    required String remark,
    required DateTime? rescheduleDate,
    required DateTime? registrationDate,
    required String callPurpose,
    required double promisedAmount,
  }) async {
    emit(state.copyWith(isLoading: true));

    final body = {
      "ProjectId": projectId,
      "PayTrackCallLogId": payTrackCallLogId,
      "Uniquekey": uniquekey,
      "CallStatus": callStatus,
      "Remark": remark,
      "RescheduleDate": rescheduleDate?.toIso8601String(),
      "RegistrationDate": registrationDate?.toIso8601String(),
      "CallPurpose": callPurpose,
      "PromiseAmount": promisedAmount,
    };

    final result = await _callLogsRepository.updateCallLog(body: body);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));

        showErrorMessage(context, "Error", failure.message);
      },
      (response) async {
        emit(state.copyWith(isLoading: false));

        showSuccessMessage(context, subTitle: response["message"]);
        goRouter.pop();
        await getCallLog(context, 1, projectId, bookingId);
      },
    );
  }

  Future deleteCallLogs(
    int index,
    int payTrackCallLogId,
    String uniquekey,
    int projectId,
    int bookingId,
    BuildContext context,
  ) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _callLogsRepository.deleteCallLogs(
      payTrackCallLogId: payTrackCallLogId,
      uniqueKey: uniquekey,
      projectId: projectId,
      bookingId: bookingId,
    );
    goRouter.pop();
    result.fold(
      (failure) {
        showErrorMessage(context, "Error", failure.message);
        return;
      },
      (response) {
        final updatedList = List<PayTrackCallLogModel>.from(
          state.payTrackCallLogList,
        );
        updatedList.removeAt(index);
        emit(
          state.copyWith(
            payTrackCallLogList: updatedList,
            isLoading: false,
            callLogsTotalNumberOfRecord:
                state.callLogsTotalNumberOfRecord > 0
                    ? state.callLogsTotalNumberOfRecord - 1
                    : 0,
          ),
        );
        showSuccessMessage(context, subTitle: response['message']);
      },
    );
  }

  Future exportCallLogsExcelPdf(
    BuildContext context,
    String exportType, {
    int? projectId,
    int? bookingId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var result = await _callLogsRepository.getCallLogsForExport(
      pageNumber: 1,
      pageSize: state.callLogsTotalNumberOfRecord,
      queryParams: {
        "ProjectId": projectId,
        "BookingId": bookingId,
        "ExportType": exportType,
        'FromDate': fromDate?.apiDate,
        'ToDate': toDate?.apiDate,
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
              ? "Call Log ${DateTime.now()}.pdf"
              : "Call Log ${DateTime.now()}.xlsx",
        );
      },
    );
  }
}
