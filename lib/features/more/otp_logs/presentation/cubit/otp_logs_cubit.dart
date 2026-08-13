import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/more/otp_logs/data/model/otp_logs.model.dart';
import 'package:k3h_erp_app/features/more/otp_logs/data/repository/otp_logs.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

part 'otp_logs_state.dart';

class OtpLogsCubit extends Cubit<OtpLogsState> {
  OtpLogsCubit() : super(OtpLogsState.initial());

  // REPOSITORY
  final OtpLogsRepository _otpLogsRepository =
      serviceLocator<OtpLogsRepository>();

  Future searchOtpLogs(
    BuildContext context,
    String value,
    int projectId,
  ) async {
    emit(state.copyWith(searchText: value, ticketList: []));
    await getCallLogsList(context, 1, projectId);
  }

  int updateFilterCount(OtpLogsState state) {
    return getActiveFilterCount([
      state.searchText.trim().isNotEmpty,
      state.filterMobileNumber.trim().isNotEmpty,
      state.filterModuleName.trim().isNotEmpty,
      state.filterFromDate != null,
      state.filterToDate != null,
    ]);
  }

  Future applyFilterAndSort({
    required BuildContext context,
    String? mobileNumber,
    String? moduleName,
    DateTime? fromDate,
    DateTime? toDate,
    required int projectId,
    bool? isClear,
  }) async {
    if (isClear ?? false) {
      emit(
        state.copyWith(
          filterMobileNumber: "",
          filterModuleName: "",
          filterFromDate: null,
          filterToDate: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          filterMobileNumber: mobileNumber ?? state.filterMobileNumber,
          filterModuleName: moduleName ?? state.filterModuleName,
          filterFromDate: fromDate ?? state.filterFromDate,
          filterToDate: toDate ?? state.filterToDate,
        ),
      );
    }

    await getCallLogsList(
      context,
      1,
      projectId,
      mobileNumber: mobileNumber,
      moduleName: moduleName,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future getCallLogsList(
    BuildContext context,
    int pageNumber,
    int projectId, {
    String? mobileNumber,
    String? moduleName,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(state.copyWith(isLoading: true));
    final queryParams = <String, dynamic>{};

    if ((mobileNumber ?? "").isNotEmpty) {
      queryParams["MobileNumber"] = mobileNumber;
    }

    if ((moduleName ?? "").isNotEmpty) {
      queryParams["Module"] = moduleName;
    }

    if (fromDate != null) {
      queryParams["FromDate"] = fromDate.toIso8601String();
    }

    if (toDate != null) {
      queryParams["ToDate"] = toDate.toIso8601String();
    }
    var result = await _otpLogsRepository.getOTPLogsList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final List<OtpLogsModel> tickets = response['data'];
        final updatedList =
            pageNumber == 1 ? tickets : [...state.ticketList, ...tickets];

        emit(
          state.copyWith(
            ticketList: updatedList,
            currentPage: pageNumber,
            totalNumberOfRecord: response["totalNumberOfRecord"],
            isLoading: false,
          ),
        );
      },
    );
  }

  // EXPORT EXCEL PDF
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);

    Map<String, dynamic> queryParams = {"ExportType": exportType};
    var result = await _otpLogsRepository.exportOTPLogsList(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams: queryParams,
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
              ? "OTP Logs_${DateTime.now().millisecondsSinceEpoch}.pdf"
              : "OTP Logs_${DateTime.now().millisecondsSinceEpoch}.xlsx",
        );
      },
    );
  }
}
